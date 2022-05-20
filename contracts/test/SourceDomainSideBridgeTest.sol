//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../deb/ERC20.sol";
import "../deb/ICrossDomainMessenger.sol";

/// @title SourceDomainSideBridgeTest Contract - modified for testing
/// @author Sherif Abdelmoatty
/// @notice This contract is to be deployed in the source rollup
contract SourceDomainSideBridgeTest {

    address constant ETHER_ADDRESS = 0x0000000000000000000000000000000000000000;
    address constant ovmL2CrossDomainMessenger = 0x4200000000000000000000000000000000000007;  //ovmL2CrossDomainMessenger contract address(Optimism)

    uint constant public CONTRACT_FEE_BASIS_POINTS = 5; //fee basis points
    uint constant public FIXED_FEE = 3000 gwei;         //fixed fee - this is added as erc20 tokens value are unknown and to discorage small transactions and acts as a governance fee
    uint constant public MAX_TRADE_LIMIT = 0.1 ether;   //max allowed ether to be transfered

    struct TransferData {
        address  tokenAddress; //rollup dependent
        address  destination;
        uint256  amount;       //amount to be transfered in kwei
        uint256  fee;
        uint256  startTime;
        uint256  feeRampup;
        uint256  nonce;
    }

    struct RewardData {
        bytes32  transferDataHash;
        address  tokenAddress; 
        address  claimer;
        uint256  amountPlusFee;
    }

    mapping(bytes32 => bool) public validTransferHashes;
    mapping(bytes32 => bool) public knownHashOnions;
    bytes32 processedRewardHashOnion;
    address l1DomainSideContractAddress;  //l1DomainSideContract deployed contract address on mainnet
    uint256  currentNonce;
    address public governance;
    uint256 governanceBalance;

    event Transaction(TransferData transferData);
    event ClaimPayed(bytes32 transferDataHash, bool success);
    event NewKnownHashOnionAdded(bytes32 newKnownHashOnions);
    
    /// @notice only allows a message from l1DomainSideBridge contract through the L2CrossDomainMessenger bridge
    modifier onlyL1Contract(){
        ICrossDomainMessenger l2cdm = ICrossDomainMessenger(ovmL2CrossDomainMessenger);
        require(
            msg.sender == address(ovmL2CrossDomainMessenger)
            && l2cdm.xDomainMessageSender() == l1DomainSideContractAddress
        );
        _;
    }

    /// @notice onlyGovernance modifier 
    /// @notice allow only the Governor to access
    modifier onlyGovernance {
        require(msg.sender == governance, "Governance: You are not the Governor!!!");
        _;
    }

    /// @param _l1DomainSideContractAddress is the address of the contract in etherium L1
    constructor(address _l1DomainSideContractAddress){
        l1DomainSideContractAddress = _l1DomainSideContractAddress;
        governance = msg.sender;
    }

    /// @notice transfer the required funds plus fees to be sent to the current contract balance
    function transfer(address _tokenAddress, address _destination, uint256 _amount,
         uint256  _feeRampup) external payable returns(bytes32){
        
        uint256 fee = _amount * CONTRACT_FEE_BASIS_POINTS;
        uint256 amountPlusFee = _amount * 1000 + fee;
        
        require(fee * _feeRampup < _amount * 1000, "feeRampup maximum cost should be less than the total amount");

        if(_tokenAddress == ETHER_ADDRESS){
            require(_amount* 1000 < MAX_TRADE_LIMIT, "Amount higher than maximum trade limit");
            require(msg.value >= amountPlusFee + FIXED_FEE, "No Suffecient ether");
        }else{
            ERC20 token = ERC20(_tokenAddress);
            token.transferFrom(msg.sender, address(this), amountPlusFee);
            require(msg.value >= FIXED_FEE, "No Suffecient ether for the fixed ether fee");
        }

        TransferData memory transferData;
        transferData.tokenAddress = _tokenAddress;
        transferData.destination = _destination;
        transferData.amount = _amount;
        transferData.fee = fee;
        transferData.startTime = block.number;
        transferData.feeRampup = _feeRampup;
        transferData.nonce = currentNonce;

        currentNonce++;
        governanceBalance = governanceBalance + FIXED_FEE;

        bytes32 transferDataHash = sha256(abi.encode(transferData));
        
        validTransferHashes[transferDataHash] = true;

        emit Transaction(transferData);
        
        return transferDataHash;
    }

    /// @notice process the processClaims structs to be paid to the liquidity providers
    /// @param _rewardData is an array of RewardData structs to be paid to liquidity providers
    function processClaims(RewardData[] memory _rewardData) external payable {
        bytes32 newProcessedRewardHashOnion = calculateNewProcessedRewardHashOnion(_rewardData);
        require(knownHashOnions[newProcessedRewardHashOnion], "Invalide RewardData list.");
        processedRewardHashOnion = newProcessedRewardHashOnion;
        for(uint n = 0; n < _rewardData.length; n++) {
            if(validTransferHashes[_rewardData[n].transferDataHash]){
                bool success;
                if(_rewardData[n].tokenAddress == ETHER_ADDRESS){
                    (bool suc, ) = payable(_rewardData[n].claimer).call{value: _rewardData[n].amountPlusFee}("");
                    success = suc;
                }else{
                    ERC20 token = ERC20(_rewardData[n].tokenAddress);  
                    success = token.transferFrom(address(this), _rewardData[n].claimer,
                        _rewardData[n].amountPlusFee);

                    (bool suc, ) = payable(_rewardData[n].claimer).call{value: FIXED_FEE}("");

                    success = success && suc;
                }
                emit ClaimPayed(_rewardData[n].transferDataHash, success);
            }
        }    
    }

    /// @notice this function is only called from the contract at the etherium L1
    /// @notice through the rollup messenger contract to add a new known hash onion
    function addNewKnownHashOnion(bytes32 _newKnownHashOnions) external{
        knownHashOnions[_newKnownHashOnions] = true;
        emit NewKnownHashOnionAdded(_newKnownHashOnions);
    }

    function collectGovernanceFixedFees() external onlyGovernance{
        payable(governance).transfer(governanceBalance);
        governanceBalance = 0;
    }

    /// @notice calculates the new hash onion
    function calculateNewProcessedRewardHashOnion(RewardData[] memory _rewardData) private view returns (bytes32){
        bytes32 newProcessedRewardHashOnion = processedRewardHashOnion;
        for(uint n = 0; n < _rewardData.length; n++) {
            newProcessedRewardHashOnion = 
                sha256(abi.encode(newProcessedRewardHashOnion,_rewardData[n]));
        }
        return newProcessedRewardHashOnion;
    }
}