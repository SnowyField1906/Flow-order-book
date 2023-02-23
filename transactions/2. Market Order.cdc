import OrderBookV21 from 0xOrderBookV21
import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken
import FUSD from 0xFUSD

transaction(quantity: UFix64, isBid: Bool) {
    prepare(signer: AuthAccount) {
        let storageCapability: Capability<&OrderBookV21.Admin{OrderBookV21.AdminPrivate}> = signer.getCapability<&OrderBookV21.Admin{OrderBookV21.AdminPrivate}>(OrderBookV21.AdminCapabilityPath)
        let flowVaultRef = signer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)!
        let fusdVaultRef = signer.borrow<&FUSD.Vault>(from: /storage/fusdVault)!

        let listing = getAccount(0xOrderBookV21).getCapability<&OrderBookV21.Listing{OrderBookV21.ListingPublic}>(OrderBookV21.ListingPublicPath).borrow()!

        listing.marketOrder(addr: signer.address, quantity: quantity, isBid: isBid, storageCapability: storageCapability, flowVaultRef: flowVaultRef, fusdVaultRef: fusdVaultRef)
    }

    execute {
    }
}