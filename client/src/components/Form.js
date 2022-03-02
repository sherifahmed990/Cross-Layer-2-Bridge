import React, { useState, useContext } from "react"
import {GlobalContext} from '../context/GlobalState';
import {getEthereum} from "../getEthereum"
import {getWeb3} from "../getWeb3"
import {getContract} from "../getContract"

const Form = () => {
  const {currencies, sourceSideContract} = useContext(GlobalContext);
  const [token, setToken] = useState(currencies[0].address);
  const [amountInput, setAmount] = useState(0);
  const [destinationInput, setDestination] = useState('');
  
  
  let setWithdrawal = async (e) => {
    e.preventDefault()
    const value = parseInt(amountInput)
    const ethereum = await getEthereum()
    let ssbridge =  await getContract()
    const web3 = await getWeb3()
    //var gasPrice = await web3.eth.getGasPrice();
    
    const accounts = await ethereum.request({ method: 'eth_requestAccounts' });

    let encodedABI = ssbridge.methods.withdraw(token,
    destinationInput, amountInput, 1, 10, 1).encodeABI()
    
    
       console.log(`encodedABItoken`)
       console.log(token)

    var tx = {
        from: accounts[0],
        to: sourceSideContract,
        data: encodedABI,
        //gasPrice: gasPrice
    };
    
    
    //var gasLimit = 12000;
    //var transactionFee = gasPrice * gasLimit; // calculate the transaction fee

    //tx.gas = String(gasLimit);
    
    if(token !== '0x0000000000000000000000000000000000000000'){
      //tx.value = String(transactionFee); // set the transaction value to the entire balance, less the transaction fee
      
      let minABI = [
        // transfer
        {
          "constant": false,
          "inputs": [
            {
              "name": "_spender",
              "type": "address"
            },
            {
              "name": "_to",
              "type": "uint256"
            }
          ],
          "name": "transfer",
          "outputs": [
            {
              "name": "",
              "type": "bool"
            }
          ],
          "type": "function"
        },{
          "constant": false,
          "inputs": [
            {
              "name": "_spender",
              "type": "address"
            },
            {
              "name": "_value",
              "type": "uint256"
            }
          ],
          "name": "approve",
          "outputs": [
            {
              "name": "",
              "type": "bool"
            }
          ],
          "type": "function"
        }
      ];
      
      // Get ERC20 Token contract instance
      let tokenContract = new web3.eth.Contract(minABI, token);

      await ethereum
      .request({
        method: "eth_sendTransaction",
        params: [
          {
            from: accounts[0],
            to: token,
            data: tokenContract.methods
              .approve('0x4f7459eFf03cD8C19B5a442d7c9b675A05f66fbf', value * 1000000)
              .encodeABI(),
          },
        ],
      })
      .then((result) =>  console.log(result))
      .catch((error) => console.error(error));
      tx.value = String(5000);
    }else {
      tx.value = String(value*1000);
    }
    tx.value = String(value*1000);

    console.log(`Transacton`)
    console.log(tx)
    //const {web3} = this.state

      //const ethereum = await getEthereum()
      const sentTx = await ethereum.request({
        method: 'eth_sendTransaction',
        params: [tx],
      }); 
    
}

  return (
    <form className="needs-validation p-3" onSubmit={(e) => setWithdrawal(e)} noValidate>
      <div className="mb-3">
          <label htmlFor="Token" className="form-label">Token</label>
          <select className="form-select" onChange={(e) => setToken(e.target.value)} required>
          {currencies.map((currency)=>(
                <option key={currency.key} value={currency.address}>{currency.name}</option>
            ))}
          </select>
       </div>
       <div className="mb-3">
          <label htmlFor="Amount" className="form-label">Amount</label>
          <input type="text" className="form-control" name="amountInput" placeholder="" value={amountInput}
          onChange={(e) => setAmount(e.target.value)} required/>
       </div>
       <div className="mb-3">
          <label htmlFor="Destination" className="form-label">Destination Address</label>
          <input type="text" className="form-control"  name="destinationInput" placeholder="" value={destinationInput}
          onChange={(e) => setDestination(e.target.value)} required/>
       </div>
       <button type="submit" className="btn btn-primary">Send</button>
    </form>
  )
}

export default Form
