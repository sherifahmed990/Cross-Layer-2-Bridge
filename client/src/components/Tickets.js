import React, {useState,useContext,useEffect} from "react"
import '../../node_modules/bootstrap/dist/css/bootstrap.min.css';
import {getWeb3} from "../getWeb3"
import map from "../artifacts/deployments/map.json"
import {getEthereum} from "../getEthereum"
import {getContract} from "../getContract"
import {GlobalContext} from '../context/GlobalState';


const Tickets =  () => {
  const[transactions, setTransactions] = useState([]);
  useEffect(() => {
    async function fetchTransactions(){
      try{
        let contract =  await getContract()
        console.log(contract)
        let events = await contract.getPastEvents("Ticket", { fromBlock: 1})
        console.log(events.map((e) =>e['returnValues']))
        setTransactions(events.map((e) =>e['returnValues']))
      }catch(e){
        console.log(e)
      }
    }
      fetchTransactions()
  }, [])

  return (
    
    <div>
        <h3>Recent Tickets</h3>
        <table className="table table-striped">
          <thead>
              <tr>
                <th scope="col">Ticket</th>
                <th scope="col">First Transaction Id</th>
                <th scope="col">Last Transaction Id</th>
                <th scope="col">State Root</th>
              </tr>
          </thead>
          <tbody>
              {transactions.map((transaction,index)=>(
                  <tr key={index}>
                    <td>{transaction['ticket']}</td>
                    <td>{transaction['firstIdForTicket']}</td>
                    <td>{transaction['lastIdForTicket']}</td>
                    <td>{transaction['stateRoot']}</td>
                  </tr>
              ))}
          </tbody>
        </table>
    </div>
  )
}

export default Tickets