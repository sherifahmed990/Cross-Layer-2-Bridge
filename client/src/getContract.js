import React, {useState,useContext,useEffect} from "react"
import '../node_modules/bootstrap/dist/css/bootstrap.min.css';
import {getWeb3} from "./getWeb3"
import map from "./artifacts/deployments/map.json"
import {getEthereum} from "./getEthereum"
import {GlobalContext} from './context/GlobalState';


let loadContract = async (chain, contractName, address) => {
    // Load a deployed contract instance into a web3 contract object
    const web3 = await getWeb3()

    // Load the artifact with the specified address
    let contractArtifact
    try {
        contractArtifact = await import(`./artifacts/deployments/${chain}/${address}.json`)
    } catch (e) {
        console.log(`Failed to load contract artifact "./artifacts/deployments/${chain}/${address}.json"`)
        return undefined
    }

    return new web3.eth.Contract(contractArtifact.abi, address)
}
export const getContract = async () => {

    const web3 = await getWeb3()
    
    
    // Try and enable accounts (connect metamask)
    const ethereum = await getEthereum()
    try {
        //const ethereum = await getEthereum()
        ethereum.enable()
        console.log(`Metamask 2`)
        
        const accounts = await ethereum.request({ method: 'eth_requestAccounts' });
        
        // Get the current chain id
        const chainid = parseInt(await web3.eth.getChainId())
        
        // <=42 to exclude Kovan, <42 to include kovan
        if (ethereum.networkVersion != 69) {
            try {
                await ethereum.request({
                  method: 'wallet_switchEthereumChain',
                  params: [{ chainId: web3.utils.toHex(69) }],
                });
              } catch (switchError) {
                // This error code indicates that the chain has not been added to MetaMask.
                if (switchError.code === 4902) {
                  try {
                    await ethereum.request({
                      method: 'wallet_addEthereumChain',
                      params: [
                        {
                            chainId: web3.utils.toHex(69),
                            chainName: 'Optimism Kovan',
                            rpcUrls: ['https://kovan.optimism.io'],
                            blockExplorerUrls: ['https://kovan-optimistic.etherscan.io'],
                        },
                      ],
                    });
                  } catch (addError) {
                    console.log(addError)
                  }
                }
                // handle other "switch" errors
              }

        }
      
        const chainIdHex = ethereum.networkVersion;
        const chainIdDec = await web3.eth.getChainId();
        console.log('ChainId Hex and decimal')
        console.log(chainIdHex);
        console.log('ChainId Hex and decimal2')
        console.log(chainIdDec);
        console.log('ChainId Hex and decimal3')
      
      var _chainID = 0;
      if (chainid === 42){
          _chainID = 42;
      }
      if (chainid === 1337){
          _chainID = "dev"
      }
      if (chainid === 69){
        _chainID = 69;
    }
      console.log(_chainID)
      const ssbridge = await loadContract(_chainID,"SourceDomainSideBridge", "0x4f7459eFf03cD8C19B5a442d7c9b675A05f66fbf")
      //let root = await ssbridge.methods.get_deposit_root().call()
      console.log('ssbridge')
      console.log(ssbridge)
      if (!ssbridge) {
          return
      }
     
      return ssbridge
    } catch (e) {
        console.log(`Could not enable accounts. Interaction with contracts not available.
        Use a modern browser with a Web3 plugin to fix this issue.`)
        console.log(e)
    }

}