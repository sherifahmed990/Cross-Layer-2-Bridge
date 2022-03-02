//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./deb/optimism/contracts/L1/messaging/L1CrossDomainMessenger.sol";
import "./deb/optimism/contracts/L1/messaging/L1StandardBridge.sol";
import "./deb/optimism/contracts/L2/messaging/L2CrossDomainMessenger.sol";

/// @title DestinationDomainSideBridge Contract
/// @author Sherif Abdelmoatty
/// @notice This contract is to be deployed in the destination rollup
contract DestinationDomainSideBridge {
    mapping(uint256 => address payable) transferOwners;
    mapping(uint256 => uint256) transferFee;
    address constant ETHER_ADDRESS = 0x0000000000000000000000000000000000000000;

    struct TransferData {
        address  tokenAddress;
        address  destination;
        uint256  amount;
        uint256  fee;
        uint256  startTime;
        uint256  feeRampup;
    }
    address l1messenger; 
    address l2TokenBridge;
    address l1contract;

    mapping(bytes32 => bool) approvedStateRoots;

    address ovmL2CrossDomainMessenger;  //ovmL2CrossDomainMessenger contract address(Optimism)
    address l1DomainSideContract;  //L1DomainSideBridge deployed contract address on mainnet
    address sourceSideAddress; //Source Side Contract Address


    /// @notice onlyL1Contract modifier
    /// @notice only allows a message from l1DomainSideBridge contract through the L2CrossDomainMessenger bridge
    /// @notice to call the approveStateRoot function
    modifier onlyL1Contract() {
        require(
            msg.sender == address(ovmL2CrossDomainMessenger)
            && L2CrossDomainMessenger(ovmL2CrossDomainMessenger).xDomainMessageSender() == l1DomainSideContract
        );
        _;
    }

    /// @notice Constructior function
    /// @notice Intialize variables
    constructor(address _ovmL2CrossDomainMessenger, address _l1DomainSideContract, address _sourceSideAddress){
        ovmL2CrossDomainMessenger = _ovmL2CrossDomainMessenger;
        l1DomainSideContract = _l1DomainSideContract;
        sourceSideAddress = _sourceSideAddress;
    }

    /// @notice changeOwner function
    /// @notice if the owner is zero, the destination address can transfer ownership to the newOwner
    /// @notice Also the woner can transfer ownership to the newOwner
    function changeOwner(TransferData memory transferData, uint256 transferID, 
        address payable newOwner)public {
        require((transferOwners[transferID] == address(0) 
                && transferData.destination == msg.sender) ||
                transferOwners[transferID] == msg.sender, 
                "Can only be called by owner or destination if there is no owner.");
        transferOwners[transferID] = newOwner;
    }

    /// @notice buy function
    /// @notice if the owner is zero, anyone can call this function paying the required tokens
    /// @notice and claiming ownership
    function buy(TransferData memory transferData, uint256 transferID) public payable{
        require(transferOwners[transferID] == address(0),"Owner is non zero");
        uint256 fee = getLPFee(transferData, block.timestamp);
        require(msg.value >= fee, "Error : Non Suffecient funds!!!!!!!!");
        transferFee[transferID] = fee;
    }

    /// @notice withdraw function
    /// @notice if the contract has enough balance, the owner(or the destination if the owner is zero)
    /// @notice can call this function, the function will confirm the transfer with the state root
    /// @notice and if the transfer is confirmed, the transfer value will be transfered to the 
    /// @notice destination address
    /// @param stateRootProof should be calculated offline
    function withdraw(TransferData memory transferData, uint256 transferID, 
        bytes32[] memory stateRootProof, bytes32 stateRoot) public{

        require((transferOwners[transferID] == address(0) 
                && transferData.destination == msg.sender) ||
                transferOwners[transferID] == msg.sender, 
                "Can only be called by owner or destination if there is no owner.");
        require(checkProof(transferData, transferID, stateRootProof, stateRoot),
            "Wrong state root or proof.");
        transferOwners[transferID].transfer(transferFee[transferID]);
        if(transferData.tokenAddress == ETHER_ADDRESS){
            require(transferData.amount <= address(this).balance,
             "Contract doesn't have enough funds yet.");

        }else{
            ERC20 token = ERC20(transferData.tokenAddress);
            require(transferData.amount <= token.balanceOf(address(this)),
             "Contract doesn't have enough funds yet.");
            token.transferFrom(address(this), msg.sender, transferData.amount);
        }       
    }

    /// @notice getLPFee function
    /// @notice calculates the liquidity provider fee.
    function getLPFee(TransferData memory _transferData, uint256 _currentTime) private pure returns (uint256) {
        if(_currentTime < _transferData.startTime)
            return 0;
        else if(_currentTime >= _transferData.startTime + _transferData.feeRampup)
            return _transferData.fee;
        else
            return _transferData.fee * (_currentTime - _transferData.startTime); // feeRampup
    }

    /// @notice getLPFee function
    /// @notice check the transferData proof with the stateRoot
    function checkProof(TransferData memory _transferData, uint256 transferID, 
        bytes32[] memory stateRootProof, bytes32 stateRoot) private returns (bool) {

         bytes32 transferDataHash = sha256(abi.encodePacked(_transferData.tokenAddress,_transferData.destination,
                                                            _transferData.amount ,_transferData.fee,
                                                            _transferData.startTime,_transferData.feeRampup));
        bytes32 contractAddressHash = sha256(abi.encodePacked(sourceSideAddress));
        bytes32 nexTransferIdHash = sha256(abi.encodePacked(transferID));
        bytes32 node = sha256(abi.encodePacked(transferDataHash, contractAddressHash,nexTransferIdHash));

        bytes32 value = node;
        for(uint n = 0; n < stateRootProof.length; n++) {
            if(((n / (2**n)) % 2) == 1)
                value = sha256(abi.encodePacked(stateRootProof[n], value));
            else
                value = sha256(abi.encodePacked(value, stateRootProof[n]));
        }
       return (value == stateRoot);
    }

    /// @notice approveStateRoot function
    /// @notice receives the approved state root message from l1DomainSideBridge contract through the L2CrossDomainMessenger bridge
    function approveStateRoot(bytes32 stateRoot)external onlyL1Contract{
        approvedStateRoots[stateRoot] = true;
    }
    
}