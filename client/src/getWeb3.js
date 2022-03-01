import Web3 from "web3";
import {getEthereum} from "./getEthereum";

export const getWeb3 = async () => {

    const provider = new Web3.providers.HttpProvider(
        "https://kovan.infura.io/v3/188fc537abca4354820a218c0de66475"
    );
    const web3 = new Web3(provider)

    return web3
}