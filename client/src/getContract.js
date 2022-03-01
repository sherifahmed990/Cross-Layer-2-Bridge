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
        if (chainid < 42) {
          // Wrong Network!
          return
        }
      
      console.log(chainid)
      
      var _chainID = 0;
      if (chainid === 42){
          _chainID = 42;
      }
      if (chainid === 1337){
          _chainID = "dev"
      }
      console.log(_chainID)
      const ssbridge = await loadContract(_chainID,"SourceDomainSideBridge", "0xD904b21D46603e2B6C606f401C412fE413DcAB74")
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