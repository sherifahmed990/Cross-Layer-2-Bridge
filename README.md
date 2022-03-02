<!-- PROJECT LOGO -->
<br />
<div align="center">
  <h3 align="center">Cross Layer 2 Bridge</h3>
</div>

<!-- ABOUT THE PROJECT -->
## About The Project

This project is a cross domain bridge to move tokens between L2 networks (EVM compatible).<br/>
<a href='https://gitcoin.co/issue/gitcoinco/skunkworks/253/100027342'>Gitcoin bounty</a><br/>
<a href='https://notes.ethereum.org/@vbuterin/cross_layer_2_bridges'>Document by @vbuterin descriping the bounty</a>

This project is an implementation for a bridge descriped in this <a href='https://notes.ethereum.org/@vbuterin/cross_layer_2_bridges'>document by @vbuterin </a> with the following modification :<br/>
The destination side contract can't confirm the Merkle root of the source side contract transactions so,
a solution would be to deploy a contract in the mainnet, and the confirmation flow would be the follwing
* The LP provide the required tokens for the bounty on the mainnet contract along with the valid Merkle tree root.
* After the contract receives the tokens it sends a message with the tokens amounts it received to the source side contract through the rollup bridge contract. 
* The source side contract confirms the received funds by hashing the values and comparing it with a "ticket" that
* the LP have created previously on the source side contract, if confirmed it sends the bounty to the LP.
* The LP should provide a valid data to the contract on the mainnet so that it can receive the bounty on the source side rollup.
* The mainnet contract also sends the tokens with the merkle tree that the LP provided to the destination side contract through the rollup bridge contract.
* If the LP provided wrong information to the mainnet contract , he will not receive the bounty and no funds will be missing.
* The destination side contract can receive the funds through the rollup bridge contract along with the merkle tree root.

## Deployed Contracts :
* <a href="https://kovan.etherscan.io/address/0xc0E0De864A64854359D653db7f79302b78125171">L1DomainSideBridge (kovan)</a>
* <a href="https://kovan-optimistic.etherscan.io/address/0x4f7459eFf03cD8C19B5a442d7c9b675A05f66fbf">SourceDomainSideBridge(Optimis)</a>
* <a href="https://kovan-optimistic.etherscan.io/address/0xf67b8dB221236ff53e67a5501ba3d7dfA63d1Df0">DestinationDomainSideBridge(Optimis)</a>

Both SourceDomainSideBridge and DestinationDomainSideBridge are on the same rollup(Optimism) as Arbitrum isn't depolyed in Kovan.<br/>
A React App as a frontend for the bridge : http://3.20.224.37:3000/ (Still work in progress!)

### Built With

This Project is build with:

* [Solidity](soliditylang.org)
* [React.js](https://reactjs.org/)
* [Brownie](https://eth-brownie.readthedocs.io/)

<!-- ROADMAP -->
## Roadmap

- [x] Write Solidity Contracts
- [x] Deploy Contracts
- [x] Create a React front end to interacte with the SourceDomainSideBridge
- [ ] Completing the frontend for the remaining contracts
- [ ] Testing
- [ ] Deploying on the Mainnet

<!-- LICENSE -->
## License

Distributed under the MIT License.

<!-- CONTACT -->
## Contact

Sherif Abdelmoatty - [@SherifA990](https://twitter.com/SherifA990) - sherif.ahmed990@gmail.com

Project Link: [https://github.com/sherifahmed990/l2-crossdomain-bridge](https://github.com/sherifahmed990/Cross-Layer-2-Bridge)

<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

* <a href='https://gitcoin.co/issue/gitcoinco/skunkworks/253/100027342'>Gitcoin bounty</a>
* <a href='https://notes.ethereum.org/@vbuterin/cross_layer_2_bridges'>Document by @vbuterin descriping the bounty</a>
* <a href='https://etherscan.io/address/0x00000000219ab540356cbb839cbe05303d7705fa'>Ethereum 2.0 deposit contract</a>
