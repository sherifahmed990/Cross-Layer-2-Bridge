//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./deb/ICrossDomainMessenger.sol";

/// @title L1DomainSideBridge Contract
/// @author Sherif Abdelmoatty
/// @notice This contract is to be deployed in the mainnet(kovan for testing)
contract L1DomainSideBridge {
    address constant ETHER_ADDRESS = 0x0000000000000000000000000000000000000000;
    address constant public Proxy_OVM_L1CrossDomainMessenger = 0x4361d0F75A0186C05f971c566dC6bEa5957483fD;  //Source & Destintion side rollup(Optimism kovan) l1messenger address 

    address public sourceSideAddress; //Source Side Contract Address
    address public destinationSideAddress; //Destintion Side Contract Address
    
    address public governance;  //governance address - only to initially set the source and destination contract addresses once
    
    /// @notice Constructior function
    /// @notice Intialize the contract initiale values
    constructor(){
        governance = msg.sender;
    }
    /// @notice onlyGovernance modifier 
    /// @notice allow only the Governor to access
    /// @notice only to initialy set the source and destination contract addresses once
    modifier onlyGovernance {
        require(msg.sender == governance, "Governance: You are not the Governor!!!");
        _;
    }

    /// @notice onlyL2Contract modifier
    /// @notice only allows a message from l1DomainSideBridge contract through the L2CrossDomainMessenger bridge
    /// @notice to call the confirmTicketPayed function
    modifier onlyL2Contract() {
        require(
            msg.sender == address(Proxy_OVM_L1CrossDomainMessenger)
            && ICrossDomainMessenger(Proxy_OVM_L1CrossDomainMessenger).xDomainMessageSender() 
            == sourceSideAddress
        );
        _;
    }

    /// @notice setContractsAddresses function
    /// @notice is only called once by governor to set the Source and Destination side contracts address
    /// @param _sourceSideAddress address of the contract deployed at the source rollup
    /// @param _destinationSideAddress address of the contract deployed at the destination rollup
    function setContractsAddresses(address _sourceSideAddress, address _destinationSideAddress) onlyGovernance external{
        // require(sourceSideAddress == address(0), "Contract Adresses can only be set Once !!!");
        sourceSideAddress = _sourceSideAddress;
        destinationSideAddress = _destinationSideAddress;
    }
    
    /// @notice sends new hash onions to the source side contrac
    /// @notice this function is rollup dependant - Optimism Kovan
    function declareNewHashOnionHeadToSource(bytes32 _hashOnion) external{
        ICrossDomainMessenger l1cdm = ICrossDomainMessenger(Proxy_OVM_L1CrossDomainMessenger);
        l1cdm.sendMessage(
            sourceSideAddress,
            abi.encodeWithSignature(
                "addNewKnownHashOnion(bytes32)",
                _hashOnion
            ),
            1000000 // use whatever gas limit you want
        );
    }
}