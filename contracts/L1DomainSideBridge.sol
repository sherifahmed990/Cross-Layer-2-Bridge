//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./deb/optimism/contracts/L1/messaging/L1CrossDomainMessenger.sol";
import "./deb/optimism/contracts/L1/messaging/L1StandardBridge.sol";
import "./DestinationDomainSideBridge.sol";
import "./SourceDomainSideBridge.sol";

/// @title L1DomainSideBridge Contract
/// @author Sherif Abdelmoatty
/// @notice This contract is to be deployed in the mainnet(kovan for testing)
/// @notice It assumes both the source and destination contracts
/// @notice are in the Optimism rollup as it is the only rollup
/// @notice on the Kovan netwrok
contract L1DomainSideBridge {
    address constant ETHER_ADDRESS = 0x0000000000000000000000000000000000000000;

    address sourceSideAddress; //Source Side Contract Address
    address destinationSideAddress; //Destintion Side Contract Address
    address l1messenger;  //Source & Destintion side rollup(Optimism) l1messenger address 
    address l2TokenBridge; //Source & Destintion side rollup(Optimism) l2TokenBridge contract address 
    address libAddressManager;//Source & Destintion side rollup(Optimism) libAddressManager contract address 
    mapping(address => address) sDTokenAddresspair;// mapping between source and domain side tokens addresses
    address governance;//this is the only address that can add sDTokenAddresspair 
    
    /// @notice Constructior function
    /// @notice Intialize the contract initiale values
    constructor(address _l1messenger, address _l2TokenBridge, address _libAddressManager,
        address _governance){
        
        l1messenger = _l1messenger;
        l2TokenBridge = _l2TokenBridge;
        libAddressManager = _libAddressManager;
        governance = _governance;   
    }
    /// @notice onlyGovernance modifier 
    /// @notice allow only the Governor to access
    modifier onlyGovernance {
        require(msg.sender == governance, "Governance: You are not the Governor!!!");
        _;
    }

    /// @notice setContractsAddresses function
    /// @notice is only called once by governor to set the Source and Destination side contracts
    function setContractsAddresses(address _sourceSideAddress, address _destinationSideAddress) onlyGovernance public{
        require(sourceSideAddress == address(0), "Contract Adresses can only be set Once !!!");
        sourceSideAddress = _sourceSideAddress;
        destinationSideAddress = _destinationSideAddress;
    }

    /// @notice sendFundsAndClaimBounty function 
    /// @notice receives all the tokens for the bounty and calculates a ticket hash
    /// @notice based on the function inputs.
    /// @notice then it calls the confirmTicketPayed on the source side contract
    /// @notice with the bounty values and the calculated ticket hash.
    /// @notice the bouty seeker should have previously called the createTicket function
    /// @notice in the domain side contract, and the generated ticket hash from this
    /// @notice function and the ticket hash stored in the source should match so that
    /// @notice the bounty seeker can win the bounty.
    function sendFundsAndClaimBounty(bytes32 _ticket, address[] memory _tokens, 
                uint256[] memory _tokensAmounts, uint256 _firstIdForTicket, 
                uint256 _lastIdForTicket, bytes32 stateRoot) external payable{
        L1CrossDomainMessenger ovmL1CrossDomainMessenger;
        ovmL1CrossDomainMessenger.initialize(libAddressManager);

        L1StandardBridge l1Bridge;
        l1Bridge.initialize(l1messenger, l2TokenBridge);

        ovmL1CrossDomainMessenger.sendMessage(
            sourceSideAddress,
            abi.encodeWithSignature(
                "confirmTicketPayed(bytes32,address[],uint256[],uint256,uint256,bytes32,address)",
                _ticket, _tokens, _tokensAmounts, _firstIdForTicket, 
                 _lastIdForTicket, stateRoot, msg.sender
            ),
            1000000
        );

        for (uint n = 0; n < _tokens.length; n++) {
            if(_tokens[n] == ETHER_ADDRESS){
                require(msg.value >= _tokensAmounts[n], "Not enough funds!!");
                l1Bridge.depositETHTo(destinationSideAddress, 1000000, "");
            }else{
                ERC20 token = ERC20(_tokens[n]);
                require(token.balanceOf(address(this)) >= _tokensAmounts[n], "Not enough funds!!");
                token.approve(l1messenger, _tokensAmounts[n]);
                l1Bridge.depositERC20To(_tokens[n], sDTokenAddresspair[_tokens[n]],
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
            1000000
        );
    }

    /// @notice addSDTokenAddresspair function 
    /// @notice adds a source and destination addresses pair for a given token
    function addSDTokenAddresspair(address sourceToken, address destinationToken) onlyGovernance public{
        if(sDTokenAddresspair[sourceToken] != address(0)){
            return;
        }
        sDTokenAddresspair[sourceToken] = destinationToken;
    }
}