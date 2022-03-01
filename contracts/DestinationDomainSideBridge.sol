//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "contracts/deb/optimism/contracts/L1/messaging/L1CrossDomainMessenger.sol";
import "contracts/deb/optimism/contracts/L1/messaging/L1StandardBridge.sol";

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

    function changeOwner(TransferData memory transferData, uint256 transferID, 
        address payable newOwner)public {
        require((transferOwners[transferID] == address(0) 
                && transferData.destination == msg.sender) ||
                transferOwners[transferID] == msg.sender, 
                "Can only be called by owner or destination if there is no owner.");
        transferOwners[transferID] = newOwner;
    }

    function buy(TransferData memory transferData, uint256 transferID) public payable{
        require(transferOwners[transferID] == address(0),"Owner is non zero");
        uint256 fee = getLPFee(transferData, block.timestamp);
        require(msg.value >= fee, "Error : Non Suffecient funds!!!!!!!!");
        transferFee[transferID] = fee;
    }

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

    function getLPFee(TransferData memory _transferData, uint256 _currentTime) private pure returns (uint256) {
        if(_currentTime < _transferData.startTime)
            return 0;
        else if(_currentTime >= _transferData.startTime + _transferData.feeRampup)
            return _transferData.fee;
        else
            return _transferData.fee * (_currentTime - _transferData.startTime); // feeRampup
    }

    function checkProof(TransferData memory transferData, uint256 transferID, 
        bytes32[] memory stateRootProof, bytes32 stateRoot) private pure returns (bool) {
        return true;
    }

    function approveStateRoot(bytes32 stateRoot)external {/*
        L1CrossDomainMessenger ovmL1CrossDomainMessenger;
        ovmL1CrossDomainMessenger.initialize(libAddressManager);
        require(
            msg.sender == address(ovmL2CrossDomainMessenger)
            && ovmL2CrossDomainMessenger.xDomainMessageSender() == l1contract
        );*/

        approvedStateRoots[stateRoot] = true;
    }
    
}