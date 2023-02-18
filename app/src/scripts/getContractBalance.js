import * as fcl from "@onflow/fcl";

export default async function getContractBalance() {
    return fcl.query({
        cadence: CONTRACT_BALANCE,
    });
}

const CONTRACT_BALANCE = `
import OrderBookVaultV8 from 0xOrderBookVaultV8
import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken
import FUSD from 0xFUSD

pub fun main() : {String: UFix64} {
    let tokenBundle = getAccount(0xOrderBookVaultV8).getCapability(OrderBookVaultV8.TokenPublicPath).borrow<&OrderBookVaultV8.TokenBundle{OrderBookVaultV8.TokenBundlePublic}>()!

    return {"Flow": tokenBundle.getFlowBalance(), "FUSD": tokenBundle.getFusdBalance()}
}
`