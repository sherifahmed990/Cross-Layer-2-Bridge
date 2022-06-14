//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/// @title StructLib Library
/// @author Sherif Abdelmoatty
/// @notice a library of shared structs
library StructLib {

    /// @param tokenAddress at destination rollup
    /// @param destination is reciever address at the destination rollup
    /// @param amount is amount to be transfered in kwei
    /// @param fee is the base fee that will be calculated by the source contract(not an input by the user)
    /// @param startTime is a blocknumber in the future that this transaction can only be executed after
    /// @param feeRampup will be multiplied by the fee ramp up if the LP claimed and sent the transfer by the startTime block, and will decrease by one for each block after that
    /// @param nonce will be calculated by the contract(not an input by the user)
    struct TransferData {
        address  tokenAddress;
        address  destination;
        uint256  amount;
        uint256  fee;
        uint256  startTime;
        uint256  feeRampup;
        uint256  nonce;
    }

    /// @param transferDataHash is the hash of the TransferData struct
    /// @param tokenAddress at destination rollup
    /// @param claimer is LP address at the source rollup
    /// @param amountPlusFee is calculated by the destination contract
    struct RewardData {
        bytes32  transferDataHash;
        address  tokenAddress; 
        address  claimer;
        uint256  amountPlusFee;
    }
}