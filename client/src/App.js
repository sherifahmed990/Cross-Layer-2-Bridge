import React, {Component, useContext, useEffect} from "react"
import './App.css'
import SendTokensPanel from './components/SendTokensPanel'
import SourceRollupBountyPanel from './components/SourceRollupBountyPanel'
import L1TransferBountyPanel from './components/L1TransferBountyPanel'
import DestinationRollupBountyPanel from './components/DestinationRollupBountyPanel'
import Header from './components/Header'
import '../node_modules/bootstrap/dist/css/bootstrap.min.css';
import '../node_modules/bootstrap/dist/js/bootstrap.js';
import {GlobalContext, GlobalProvider} from './context/GlobalState';
import {BrowserRouter as Router, Routes, Route} from "react-router-dom";

function App(){
    
    return(<GlobalProvider>
            <Router>
        <div className="App bg-light">
                <div className="container">
                    <Header />
                    <div className="py-5 text-center">
                        <h1>Cross Layer2 Bridge(Kovan) - Beta</h1>
                        <h3>Source Rollup : Optimism - Destination Rollup : Optimism </h3>
                    </div>
                    <Routes>
                        <Route path="/" element={<SendTokensPanel />} />
                        <Route path="/SourceRollupBountyPanel" element={<SourceRollupBountyPanel />} />
                        <Route path="/L1TransferBountyPanel" element={<L1TransferBountyPanel />} />
                        <Route path="/DestinationRollupBountyPanel" element={<DestinationRollupBountyPanel />} />
                    </Routes>
                </div>

        </div>
        </Router>
        </GlobalProvider>);
}

export default App
