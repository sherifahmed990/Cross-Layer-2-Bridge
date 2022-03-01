import Form from './Form'
import Transactions from './Transactions'
import React from "react"

const SendTokensPanel = () => {
    return(<>
        <div className="row">
            <Form />
        </div>
        <hr className="mb-4" />
        <div className="row"> 
            <Transactions />
        </div></>
    );
}

export default SendTokensPanel