import React, {createContext, useReducer} from 'react'
import AppReducer from './AppReducer'

const initialState = {
    currencies :[
        {key:0,
        name:'Ether',
        address:'0x0000000000000000000000000000000000000000'
        },
        {key:1,
            name:'DAI',
        address:'0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1'
        },
        {key:2,
            name:'LINK',
        address:'0x4911b761993b9c8c0d14ba2d86902af6b0074f5b'
        },
      ],
      sourceSideContract:'0x4f7459eFf03cD8C19B5a442d7c9b675A05f66fbf'
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

