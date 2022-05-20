<!-- PROJECT LOGO -->
<br />
<div align="center">
  <h3 align="center">Cross Layer 2 Bridge</h3>
</div>

<!-- ABOUT THE PROJECT -->
## About The Project

This project is a cross domain bridge to move ether and tokens between L2 networks(EVM compatible).
<a href='https://gitcoin.co/issue/gitcoinco/skunkworks/253/100027342'>Gitcoin bounty</a>
<a href='https://notes.ethereum.org/@vbuterin/cross_layer_2_bridges'>Document by @vbuterin descriping the bounty</a>

## How to use the deployed contracts :
1-Call the transfer function in the SourceDomainSideBridge contract passing the TransferData struct
2-A liquidity provider can use the data from the Transaction event emitted from the transfer function to call the claim function at the DestinationDomainSideBridge contract
3-After 20(TRANSFERS_PER_ONION) claims have been maid at the DestinationDomainSideBridge contract, any LP can call declareNewHashOnionHeadToL1 to send the new hashonion to the L1 contract
4-After waiting for the challenge period, you can use the optimism sdk to complete the message transfer to the L1 contract
5-After the declareNewHashOnionHeadToSourcefunction in the L1 contract is called through the Optimism messenger contract, the addNewKnownHashOnion function in the SourceDomainSideBridge contract will be called
6-Now Any lequedity provider can use the data from the Reward event emmited from the claim function at the DestinationDomainSideBridge contract to call the processClaims function and get payed

## Deployed Contracts :
* L1DomainSideBridge (kovan) = "0xcd0291CA071Dbd75f1dB8d04D21fc9f2945196A3"
* SourceDomainSideBridge(OptimismKovan) = "0x04d18666ee55257Ad7f8c3314D5Cce7A30B9921c"
* DestinationDomainSideBridge(OptimismKovan) = "0x1c2728dc77cC04d071F7a6522539a75CA04a2467"

Both SourceDomainSideBridge and DestinationDomainSideBridge are deployed in Optimism as Arbitrum isn't depolyed in Kovan

### Built With

This Project is built with:

* [Solidity](https://soliditylang.org)
* [React.js](https://reactjs.org/)
* [Brownie](https://eth-brownie.readthedocs.io/)

<!-- ROADMAP -->
## Roadmap

- [x] Write Solidity Contracts
- [x] Deploy Contracts to Kovan testnet
- [ ] Create a React Front End App
- [x] Testing
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
