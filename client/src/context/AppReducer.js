import {getWeb3} from "../getWeb3"
import {getEthereum} from "../getEthereum"

export default (state, action) =>{
    switch(action.type){
        case 'CONNECT_TO_WALLET':
            return{
                ...state,
                accounts: connectToW()
            }
        default:
            return state;
    }
}

async function connectToW(){
    // Get network provider and web3 instance.
    const web3 = await getWeb3()

    // Try and enable accounts (connect metamask)
    const ethereum = await getEthereum()
    try {
        //const ethereum = await getEthereum()
        ethereum.enable()
        console.log(`Metamask`)

        const accounts = await ethereum.request({ method: 'eth_requestAccounts' });

        // Get the current chain id
        const chainid = parseInt(await web3.eth.getChainId())
        console.log(accounts)
        return accounts
    } catch (e) {
        console.log(`Could not enable accounts. Interaction with contracts not available.
        Use a modern browser with a Web3 plugin to fix this issue.`)
        console.log(e)
        return []
    }

    //const accounts = await ethereum.request({ method: 'eth_requestAccounts' });

    // Get the current chain id
    //const chainid = parseInt(await web3.eth.getChainId())
    
}