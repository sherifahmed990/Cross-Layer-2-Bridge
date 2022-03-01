import React, {useState,useContext,useEffect} from "react"
import '../../node_modules/bootstrap/dist/css/bootstrap.min.css';
import {getWeb3} from "../getWeb3"
import map from "../artifacts/deployments/map.json"
import {getEthereum} from "../getEthereum"
import {getContract} from "../getContract"
import {GlobalContext} from '../context/GlobalState';


const Transactions =  () => {
  const[transactions, setTransactions] = useState([]);
  const {currencies} = useContext(GlobalContext);


  useEffect(() => {
    async function fetchTransactions(){
      try{
        let contract =  await getContract()
        console.log(contract)
        let events = await contract.getPastEvents("Transaction", { fromBlock: 1})
        console.log(events.map((e) =>e['returnValues'][0]))
        setTransactions(events.map((e) =>e['returnValues'][0]))}
      catch(e){
        console.log(e)
      }
    }
    fetchTransactions()
  }, [])

  return (
    
    <div>
        <h2>Recent Transactions</h2>

        <table className="table table-striped">
          <thead>
              <tr>
                <th scope="col">Token</th>
                <th scope="col">Destination Address</th>
                <th scope="col">Amount</th>
                <th scope="col">Status</th>
              </tr>
          </thead>
          <tbody>
              {transactions.map((transaction,index)=>(
                  <tr key={index}>
                    {GetCurrencyName(currencies,transaction[0])}
                    <td>{transaction[1]}</td>
                    <td>{transaction[2]}</td>
                    <td>Pending Bounty</td>
                  </tr>
              ))}
          </tbody>
        </table>
    </div>
  )
}

function GetCurrencyName(currencies,transaction) {
  return (
    <td>{currencies.find(currency => currency.address === transaction).name}</td>
  );
}

export default Transactions