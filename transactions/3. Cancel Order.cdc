import OrderBookV18 from 0xOrderBookV18
import OrderBookVaultV12 from 0xOrderBookVaultV12
import FungibleToken from 0xFungibleToken

transaction(price: UFix64, isBid: Bool) {
    let maker: Address

    prepare(signer: AuthAccount) {
        let storageCapability: Capability<&OrderBookV18.Admin{OrderBookV18.AdminPrivate}> = signer.getCapability<&OrderBookV18.Admin{OrderBookV18.AdminPrivate}>(OrderBookV18.AdminCapabilityPath)

        let listing = getAccount(0xOrderBookV18).getCapability<&OrderBookV18.Listing{OrderBookV18.ListingPublic}>(OrderBookV18.ListingPublicPath).borrow()!

        listing.cancelOrder(price: price, isBid: isBid, storage: storageCapability)
    }

    execute {
    }
}