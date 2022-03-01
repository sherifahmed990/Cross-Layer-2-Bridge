import React, {createContext, useReducer} from 'react'
import AppReducer from './AppReducer'

const initialState = {
    currencies :[
        {key:0,
        name:'Ether',
        address:'0x0000000000000000000000000000000000000000'
        },
        {key:1,
            name:'WBTC',
        address:'0xD1B98B6607330172f1D991521145A22BCe793277'
        },
        {key:2,
            name:'LINK',
        address:'0xa36085F69e2889c224210F603D836748e7dC0088'
        },
      ]
}

export const GlobalContext = createContext(initialState);

export const GlobalProvider = ({children}) => {
    const [state, dispatch] = useReducer(AppReducer, initialState);

    function connectToWallet(){
        dispatch({
            type: 'CONNECT_TO_WALLET'
        });
    }

    return (<GlobalContext.Provider 
        value={{currencies:state.currencies,connectToWallet}}>
        {children}
        </GlobalContext.Provider>);
}

