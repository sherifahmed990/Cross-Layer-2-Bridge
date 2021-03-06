<!-- PROJECT LOGO -->
<div align="center">
<img src="https://user-images.githubusercontent.com/16766656/173248396-850440c1-6d33-4c49-a34e-554a7a5383fb.png" height =200/>
</div>
<div align="center">
  <h1 align="center">Cross Layer 2 Bridge</h1>
</div>

<!-- ABOUT THE PROJECT -->
## About The Project

This project is a cross domain bridge to move ether and tokens between L2 networks(EVM compatible).<br/>
<a href='https://gitcoin.co/issue/gitcoinco/skunkworks/253/100027342'>Gitcoin bounty</a><br/>
<a href='https://notes.ethereum.org/@vbuterin/cross_layer_2_bridges'>Document by @vbuterin descriping the bounty</a>
## Frontend App :
<a href="https://cross-l2-bridge-app.vercel.app/">Link to the deployed Frontend App</a> <br/>
<a href="https://github.com/sherifahmed990/Cross-L2-Bridge-App">Frontend App Github Page</a> 

![bridge-app](https://user-images.githubusercontent.com/16766656/173221194-f38813f1-d170-4113-82f2-ba42bd2c7d9e.png)

## Video Demo :


https://user-images.githubusercontent.com/16766656/173265210-b9a03af5-4b62-459a-a183-fc103bec821b.mp4



## How to use the deployed contracts :
![1](https://user-images.githubusercontent.com/16766656/173248191-b1713005-b532-4302-af32-8caff81dcb04.png)<br/>
![2](https://user-images.githubusercontent.com/16766656/173248195-e324b8f6-ff2a-4e24-9d0e-b13da14c5188.png)<br/>
![3](https://user-images.githubusercontent.com/16766656/173248200-b8b2874a-dffe-4116-9a61-3f9119064f96.png)<br/>
![4](https://user-images.githubusercontent.com/16766656/173248204-1f1b2766-8374-4c35-b70b-8e9e719dda75.png)<br/>
![5](https://user-images.githubusercontent.com/16766656/173248207-94cd72d6-0a80-41be-8b07-646fdaeb80ae.png)<br/>
![6](https://user-images.githubusercontent.com/16766656/173248208-cdb7d7b9-3bbe-4df9-8e85-5ab80ec0a3ac.png)<br/>
![7](https://user-images.githubusercontent.com/16766656/173248210-e8b1a8e9-5e21-426f-9c9f-644c1d6f83f0.png)<br/>
![8](https://user-images.githubusercontent.com/16766656/173249749-497f2cff-6f7f-4c9c-af48-42a3267311c7.png)

## Deployed Contracts :
* <a href="https://kovan.etherscan.io/address/0x8F0F1538e04BD1f61D94BeAd25f2606dBDee203f">L1DomainSideBridge (kovan)</a> = "0x8F0F1538e04BD1f61D94BeAd25f2606dBDee203f"
* <a href="https://kovan-optimistic.etherscan.io/address/0xBb7D1032371486eef0A5e17Ff0279be14078F3E4">SourceDomainSideBridge(OptimismKovan)</a> = "0xBb7D1032371486eef0A5e17Ff0279be14078F3E4"
* <a href="https://kovan-optimistic.etherscan.io/address/0x33323F2B2D204DBa2A55341D099c5bA6B3C952e5">DestinationDomainSideBridge(OptimismKovan)</a> = "0x33323F2B2D204DBa2A55341D099c5bA6B3C952e5"

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
- [X] Create a NextJs Frontend App
- [x] Testing
- [ ] Gas Optimizations
- [ ] Deploying on the Mainnet

<!-- LICENSE -->
## License

Distributed under the MIT License.

<!-- CONTACT -->
## Contact

Sherif Abdelmoatty - [@SherifA990](https://twitter.com/SherifA990) - sherif.ahmed990@gmail.com

<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

* <a href='https://gitcoin.co/issue/gitcoinco/skunkworks/253/100027342'>Gitcoin bounty</a>
* <a href='https://notes.ethereum.org/@vbuterin/cross_layer_2_bridges'>Document by @vbuterin descriping the bounty</a>
