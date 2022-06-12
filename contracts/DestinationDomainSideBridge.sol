//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./deb/ERC20.sol";
import "./deb/ICrossDomainMessenger.sol";

/// @title DestinationDomainSideBridge Contract
/// @author Sherif Abdelmoatty
/// @notice This contract is to be deployed in the destination rollup
contract DestinationDomainSideBridge {
    address constant ETHER_ADDRESS = 0x0000000000000000000000000000000000000000;
    bytes32 rewardHashOnion;
    bytes32[] public rewardHashOnionHistoryList;
    uint256 public claimCount;
    uint256 constant TRANSFERS_PER_ONION = 20;

    struct TransferData {
        address  tokenAddress; 
        address  destination;
        uint256  amount;
        uint256  fee;
        uint256  startTime;
        uint256  feeRampup; //to incentivise lp's to transfer this transaction quickly
        uint256  nonce;
    }

    struct RewardData {
        bytes32  transferDataHash;
        address  tokenAddress; 
        address  claimer;
        uint256  amountPlusFee;
    }

    mapping(bytes32 => bool) claimedTransferHashes;
    uint256 indexReportedHashOnion;
    event Reward(RewardData rewardData, uint nonce);
    event NewHashOnionCreated(bytes32 hash);
    event NewHashOnionDeclaredToL1(bytes32 hash);

    address constant ovmL2CrossDomainMessenger = 0x4200000000000000000000000000000000000007;  //ovmL2CrossDomainMessenger contract address(Optimism)
    address l1DomainSideContractAddress;  //L1DomainSideBridge deployed contract address on mainnet

    /// @param _l1DomainSideContractAddress is the address of the contract in etherium L1
    constructor(address _l1DomainSideContractAddress){
        l1DomainSideContractAddress = _l1DomainSideContractAddress;
    }

    /// @notice liquidity providers can provide lequidity to be transfered to the 
    /// @notice destination address and register a claim to the lequidity fee
    function claim(TransferData memory _transferData) external payable{
        bytes32 transferDataHash = sha256(abi.encode(_transferData));
        require(!claimedTransferHashes[transferDataHash], "Transfer already claimed!!!");
        claimedTransferHashes[transferDataHash] = true;

        uint256 lPfee = getLPFee(_transferData, block.timestamp);
        _transferData.amount = _transferData.amount + (lPfee - _transferData.fee);

        RewardData memory rewardData;
        rewardData.transferDataHash = transferDataHash;
        rewardData.tokenAddress = _transferData.tokenAddress;
        rewardData.claimer = msg.sender;
        rewardData.amountPlusFee = lPfee + _transferData.amount;
        rewardHashOnion = sha256(abi.encode(rewardHashOnion, rewardData));

        emit Reward(rewardData, _transferData.nonce);
        claimCount++;

        if(claimCount % TRANSFERS_PER_ONION == 0){
            rewardHashOnionHistoryList.push(rewardHashOnion);
            emit NewHashOnionCreated(rewardHashOnion);
        }

        if(_transferData.tokenAddress == ETHER_ADDRESS){
            require(msg.value >= _transferData.amount, "Error : Non Suffecient funds!!!!!!!!");
            payable(_transferData.destination).transfer(_transferData.amount);
        }else{
            ERC20 token = ERC20(_transferData.tokenAddress);
            token.transferFrom(msg.sender, _transferData.destination,
                 _transferData.amount);
        }
    }
    
    /// @notice sends new hash onions one by one to the l1 side contract to be sent to the source side contract
    /// @notice this function is rollup dependant - Optimism Kovn
    function declareNewHashOnionHeadToL1() external{
        require(indexReportedHashOnion < rewardHashOnionHistoryList.length, "No new hash onions to report.");
        
        emit NewHashOnionDeclaredToL1(rewardHashOnionHistoryList[indexReportedHashOnion]);
        ICrossDomainMessenger l2cdm = ICrossDomainMessenger(ovmL2CrossDomainMessenger);
        l2cdm.sendMessage(
            l1DomainSideContractAddress,
            abi.encodeWithSignature(
                "declareNewHashOnionHeadToSource(bytes32)",
                rewardHashOnionHistoryList[indexReportedHashOnion]
            ),
            1000000 
        );
        indexReportedHashOnion++;
    }

    /// @notice calculates the liquidity provider fee based on the feeRampup
    function getLPFee(TransferData memory _transferData, uint256 _currentTime) private pure returns (uint256) {
        require(_currentTime >= _transferData.startTime, "Error : currentTime is less than startTime");

        if(_currentTime >= _transferData.startTime + _transferData.feeRampup)
            return _transferData.fee;
        else
            return _transferData.fee * (_currentTime - _transferData.startTime); // feeRampup
    }
}