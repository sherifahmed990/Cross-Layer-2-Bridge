//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "contracts/deb/optimism/contracts/L1/messaging/L1CrossDomainMessenger.sol";
import "contracts/deb/optimism/contracts/L1/messaging/L1StandardBridge.sol";
import "./DestinationDomainSideBridge.sol";
import "./SourceDomainSideBridge.sol";

contract L1DomainSideBridge {
    address constant ETHER_ADDRESS = 0x0000000000000000000000000000000000000000;

    address sourceSideAddress;
    address destinationSideAddress;
    
    
    address l1messenger; 
    address l2TokenBridge;
    address libAddressManager;
    mapping(address => address) sDTokenAddress;
    
    function sendFundsAndClaimBounty(bytes32 _ticket, address[] memory _tokens, 
                uint256[] memory _tokensAmounts, uint256 _firstIdForTicket, 
                uint256 _lastIdForTicket, bytes32 stateRoot) external payable{
        L1CrossDomainMessenger ovmL1CrossDomainMessenger;
        ovmL1CrossDomainMessenger.initialize(libAddressManager);

        L1StandardBridge l1Bridge;
        l1Bridge.initialize(l1messenger, l2TokenBridge);
        //bytes memory _data;

        ovmL1CrossDomainMessenger.sendMessage(
            sourceSideAddress,
            abi.encodeWithSignature(
                "confirmTicketPayed(bytes32,address[],uint256[],uint256,uint256,bytes32,address)",
                _ticket, _tokens, _tokensAmounts, _firstIdForTicket, 
                 _lastIdForTicket, stateRoot, msg.sender
            ),
            1000000 // use whatever gas limit you want
        );

        for (uint n = 0; n < _tokens.length; n++) {
            if(_tokens[n] == ETHER_ADDRESS){
                require(msg.value >= _tokensAmounts[n], "Not enough funds!!");
                l1Bridge.depositETHTo(destinationSideAddress, 1000000, "");
            }else{
                ERC20 token = ERC20(_tokens[n]);
                require(token.balanceOf(address(this)) >= _tokensAmounts[n], "Not enough funds!!");
                token.approve(l1messenger, _tokensAmounts[n]);
                l1Bridge.depositERC20To(_tokens[n], sDTokenAddress[_tokens[n]],
                     destinationSideAddress, _tokensAmounts[n], 1000000, "");
            }
            _ticket = sha256(abi.encodePacked(_ticket,_tokens[0], _tokensAmounts[0]));
        }

        ovmL1CrossDomainMessenger.sendMessage(
            destinationSideAddress,
            abi.encodeWithSignature(
                "approveStateRoot(bytes32)",
                stateRoot
            ),
            1000000 // use whatever gas limit you want
        );
    }

    /*
    function sendFundsAndClaimBounty(bytes32 _ticket, address[] memory _tokens, 
        uint256[] memory _tokensAmounts, uint256 _firstIdForTicket, 
        uint256 _lastIdForTicket, bytes32 stateRoot) public {
        for (uint n = 0; n < _tokens.length; n++) {
            if(_tokens[n] == ETHER_ADDRESS){
                _tokensAmounts[n] = address(this).balance;
            }else{
                ERC20 token = ERC20(_tokens[n]);
                _tokensAmounts[n] = token.balanceOf(address(this));      
            }
            ticket = sha256(abi.encodePacked(ticket,_tokens[0], _tokensAmounts[0]));
        }
    }*/
}