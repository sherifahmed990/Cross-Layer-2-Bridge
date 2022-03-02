//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./deb/optimism/contracts/L2/messaging/L2CrossDomainMessenger.sol";


/// @title SourceDomainSideBridge Contract
/// @author Sherif Abdelmoatty
/// @notice This contract is to be deployed in the source rollup
contract SourceDomainSideBridge {
    uint constant DEPOSIT_MERKLE_TREE_DEPTH = 24; //this will allow for 16777216 deposits
    uint constant MAX_DEPOSIT_COUNT = 2**DEPOSIT_MERKLE_TREE_DEPTH - 1;
    uint constant CONTRACT_FEE_BASIS_POINTS = 5;
    address constant ETHER_ADDRESS = 0x0000000000000000000000000000000000000000;

    struct TransferData {
        address  tokenAddress; 
        address  destination;
        uint256  amount;
        uint256  fee;
        uint256  startTime;
        uint256  feeRampup;
    }
    uint256 public nextTransferID;
    address[] tokens;

    mapping(bytes32 => bool) validTicket; //a mapping of valid ticket to prevent reentry
    uint256 public lastPaidByTicketId;
        
    bytes32[DEPOSIT_MERKLE_TREE_DEPTH] private branch; //Merkle Tree Branch
    bytes32[DEPOSIT_MERKLE_TREE_DEPTH] private zero_hashes;

    address ovmL2CrossDomainMessenger;  //ovmL2CrossDomainMessenger contract address(Optimism)
    address l1DomainSideContract;  //l1DomainSideContract deployed contract address on mainnet

    event Transaction(TransferData transferData,SourceDomainSideBridge current,uint256 nextTransferId);
    event Ticket(bytes32 ticket,address[] tokens,uint256[] amounts,
                uint256 firstIdForTicket, uint256 lastIdForTicket, bytes32 stateRoot);

    /// @notice onlyL1Contract modifier
    /// @notice only allows a message from l1DomainSideBridge contract through the L2CrossDomainMessenger bridge
    /// @notice to call the confirmTicketPayed function
    modifier onlyL1Contract() {
        require(
            msg.sender == address(ovmL2CrossDomainMessenger)
            && L2CrossDomainMessenger(ovmL2CrossDomainMessenger).xDomainMessageSender() == l1DomainSideContract
        );
        _;
    }

    /// @notice Constructior function
    /// @notice Intialize the zero_hashes array
    constructor(address _ovmL2CrossDomainMessenger, address _l1DomainSideContract){
        // Compute hashes in empty sparse Merkle tree
        
        for (uint height = 0; height < DEPOSIT_MERKLE_TREE_DEPTH - 1; height++)
            zero_hashes[height + 1] = sha256(abi.encodePacked(zero_hashes[height], zero_hashes[height]));

        ovmL2CrossDomainMessenger = _ovmL2CrossDomainMessenger;
        l1DomainSideContract = _l1DomainSideContract;
    }

    /// @notice get_deposit_root function
    /// @notice calculates the current merkle tree root
    function get_deposit_root()  external view returns (bytes32) {
        bytes32 node;
        uint size = nextTransferID % MAX_DEPOSIT_COUNT;
        //console.log("size %d", size);
        uint count =0;
        for (uint height = 0; height < DEPOSIT_MERKLE_TREE_DEPTH; height++) {
            if ((size & 1) == 1)
                node = sha256(abi.encodePacked(branch[height], node));
            else
                node = sha256(abi.encodePacked(node, zero_hashes[height]));
            size /= 2;
            count += 1;
        }
        return node;
    }

    /// @notice withdraw function
    /// @notice withdraws the required funds plus fees to be sent 
    /// @notice to the domain side rollup
    function withdraw(address _tokenAddress, address _destination, uint256 _amount,
        uint256 _fee, uint256 _startTime, uint256 _feeRampup) external payable returns(bytes32){
        TransferData memory _transferData;
        _transferData.tokenAddress = _tokenAddress;
        _transferData.destination = _destination;
        _transferData.amount = _amount;
        _transferData.fee = _fee;
        _transferData.startTime = _startTime;
        _transferData.feeRampup = _feeRampup;

        uint256 amountPlusFee = _transferData.amount * (1000 + CONTRACT_FEE_BASIS_POINTS);
        
        if(_transferData.tokenAddress == ETHER_ADDRESS){
            require(msg.value >= amountPlusFee, "Error : Non Suffecient funds!!!!!!!!");
        }else{
            ERC20 token = ERC20(_transferData.tokenAddress);
            token.transferFrom(msg.sender, address(this), amountPlusFee);
        }
        
        bytes32 transferDataHash = sha256(abi.encodePacked(_transferData.tokenAddress,_transferData.destination,
                                                            _transferData.amount ,_transferData.fee,
                                                            _transferData.startTime,_transferData.feeRampup));
        bytes32 contractAddressHash = sha256(abi.encodePacked(address(this)));
        bytes32 nexTransferIdHash = sha256(abi.encodePacked(nextTransferID));
        bytes32 node = sha256(abi.encodePacked(transferDataHash, contractAddressHash,nexTransferIdHash));
        //transactionHashs.push(h);

        updateMerkleBranch(node);
        

        emit Transaction(_transferData,this,nextTransferID);
        
        return node;
    }

    /// @notice createTicket function
    /// @notice to win the bountry you need first to create a ticket
    /// @notice on the source rollup, which returns a hash of the
    /// @notice current merkle root, first transaction id and last
    /// @notice transaction id that the bounty covers
    /// @notice the bounty seeker needs to deposit all the required
    /// @notice tokens in a contract in the L1 mainnet, then the L1
    /// @notice contract sends the tokens to the destination side rollup
    /// @notice and calls the confirmTicketPayed function in the source
    /// @notice side rollup, which transfers the bounty to the bounty winner
    function createTicket() external returns(bytes32){
        uint256[] memory tokensAmounts;
        bytes32 ticket;
        for (uint n = 0; n < tokens.length; n++) {
            if(tokens[n] == ETHER_ADDRESS){
                tokensAmounts[n] = address(this).balance;
            }else{
                ERC20 token = ERC20(tokens[n]);
                tokensAmounts[n] = token.balanceOf(address(this));      
            }
            ticket = sha256(abi.encodePacked(ticket,tokens[0], tokensAmounts[0]));
        }
        bytes32 r = this.get_deposit_root();
        ticket = sha256(abi.encodePacked(ticket,lastPaidByTicketId));
        ticket = sha256(abi.encodePacked(ticket,nextTransferID));
        ticket = sha256(abi.encodePacked(ticket,r));
        validTicket[ticket] = true;
        emit Ticket(ticket,tokens,tokensAmounts, lastPaidByTicketId, nextTransferID, r);
        return ticket;
    }

    /// @notice confirmTicketPayed function
    /// @notice this finction is called by the L1 mainnet contract 
    /// @notice it confirms a valid ticket and transfers the bounty to the bounty winner
    function confirmTicketPayed(bytes32 _ticket, address[] memory _tokens,
                uint256[] memory _tokensAmounts, uint256 _firstIdForTicket, 
                uint256 _lastIdForTicket, bytes32 stateRoot,
                 address payable lp) external onlyL1Contract{

        bytes32 ticket;
        for (uint n = 0; n < _tokens.length; n++) {
            ticket = sha256(abi.encodePacked(ticket,_tokens[0], _tokensAmounts[0]));
        }
        ticket = sha256(abi.encodePacked(ticket,lastPaidByTicketId));
        ticket = sha256(abi.encodePacked(ticket,nextTransferID));
        ticket = sha256(abi.encodePacked(ticket,stateRoot));
        require(_firstIdForTicket == lastPaidByTicketId, "Invalid ticket !!");
        require(ticket == _ticket, "Wrong ticket !!");
        require(validTicket[_ticket] == true, "Invalid ticket !!");
        lastPaidByTicketId = _lastIdForTicket;
        validTicket[_ticket] = false;

        for (uint n = 0; n < _tokens.length; n++) {
            if(tokens[n] == ETHER_ADDRESS){
                lp.transfer(_tokensAmounts[n]);
            }else{
                ERC20 token = ERC20(_tokens[n]);
                token.transfer(lp, _tokensAmounts[n]);
            }
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

    /// @notice updateMerkleBranch function
    /// @notice updates the merkle tree branch in the withdraw function
    /// @notice using similar logic to the PoS deposit Ethereum contract
    function updateMerkleBranch(bytes32 node) private{
        // Add deposit data root to Merkle tree (update a single `branch` node)
        nextTransferID += 1;
        uint size = nextTransferID % MAX_DEPOSIT_COUNT;
        for (uint height = 0; height < DEPOSIT_MERKLE_TREE_DEPTH; height++) {
            if ((size & 1) == 1) {
                branch[height] = node;
                return;
            }
            node = sha256(abi.encodePacked(branch[height], node));
            size /= 2;
        }
        // As the loop should always end prematurely with the `return` statement,
        // this code should be unreachable. We assert `false` just to be safe.
        assert(false);
    }
   
}