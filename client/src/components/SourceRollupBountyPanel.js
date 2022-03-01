import React from "react"
import Tickets from "./Tickets";
import {getEthereum} from "../getEthereum"
import {getWeb3} from "../getWeb3"
import {getContract} from "../getContract"

const SourceRollupBountyPanel = () => {

    let createTicket = async (e) => {
        const ethereum = await getEthereum()
        let ssbridge =  await getContract()
        const web3 = await getWeb3()
        var gasPrice = await web3.eth.getGasPrice();
        
        const accounts = await ethereum.request({ method: 'eth_requestAccounts' });
    
        let encodedABI = ssbridge.methods.createTicket().encodeABI()
    
        var tx = {
            from: accounts[0],
            to: "0xD904b21D46603e2B6C606f401C412fE413DcAB74",
            data: encodedABI,
            //gasPrice: gasPrice
        };
        
        console.log(`Transacton`)
        console.log(tx)
        //const {web3} = this.state
    
          //const ethereum = await getEthereum()
          const sentTx = await ethereum.request({
            method: 'eth_sendTransaction',
            params: [tx],
          }); 
        
    }

    return(<>
        <button type="submit" className="btn btn-primary" onClick={createTicket}>Create Ticket</button>
        <hr/>
        <Tickets />
        </>
    );
}

export default SourceRollupBountyPanel