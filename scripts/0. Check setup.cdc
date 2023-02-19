import OrderBookVaultV9 from 0xOrderBookVaultV9
import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken
import FUSD from 0xFUSD

pub fun main(userAddress: Address): Bool {
    let signer = getAccount(userAddress)

    let vaultRef = signer.getCapability(OrderBookVaultV9.TokenPublicPath)!
        .borrow<&OrderBookVaultV9.TokenBundle{OrderBookVaultV9.TokenBundlePublic}>()
        ?? nil

    let receiverRef = signer.getCapability(/public/fusdReceiver)!
    .borrow<&FUSD.Vault{FungibleToken.Receiver}>()
        ?? nil

    let balanceRef = signer.getCapability(/public/fusdBalance)!
        .borrow<&FUSD.Vault{FungibleToken.Balance}>()
        ?? nil

    return (receiverRef != nil) && (balanceRef != nil) && (vaultRef != nil)
}
`