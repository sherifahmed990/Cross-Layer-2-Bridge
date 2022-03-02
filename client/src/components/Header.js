import React, {Component, useContext,useEffect} from "react"
import {GlobalContext, GlobalProvider} from '../context/GlobalState';
import { Link, useLocation } from 'react-router-dom';


export const Header = () => {
    const {connectToWallet,currencies} = useContext(GlobalContext);
    const location = useLocation();

    let acc;
    useEffect(() => {
        acc = connectToWallet();
        console.log("Header")
        console.log(acc)
        
      }, [])
  return (
      <>

      <nav className="navbar navbar-expand-md navbar-light bg-light" aria-label="Fourth navbar example">
    <div className="container-fluid">
      <button className="navbar-toggler collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#navbarsExample04" aria-controls="navbarsExample04" aria-expanded="false" aria-label="Toggle navigation">
        <span className="navbar-toggler-icon"></span>
      </button>
      
      <div className="navbar-collapse collapse" id="navbarsExample04" >
        <ul className="navbar-nav me-auto mb-2 ms-5 mb-md-0">
          <li className="nav-item border-right">
            <Link className={(location.pathname==="/")?"nav-link active":"nav-link"} aria-current="page" to="/">Send Tokens</Link>
          </li>
          <li className="nav-item border-right">
            <Link className={(location.pathname==="/SourceRollupBountyPanel")?"nav-link active":"nav-link"} to="/SourceRollupBountyPanel">Source Rollup Bounty Panel</Link>
          </li>
          <li className="nav-item border-right">
            <Link className={(location.pathname==="/L1TransferBountyPanel")?"nav-link active":"nav-link"} to="/L1TransferBountyPanel">L1 Transfer Bounty Panel</Link>
          </li>
          <li className="nav-item ">
            <Link className={(location.pathname==="/DestinationRollupBountyPanel")?"nav-link active":"nav-link"} to="/DestinationRollupBountyPanel">Destination Rollup Bounty Panel</Link>
          </li>
         
        </ul>
      </div>
    </div>
  </nav>
<hr/>
</>
  )
}
export default Header
