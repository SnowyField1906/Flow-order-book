import * as fcl from "@onflow/fcl";

export default async function cancelOrder(price, isBid) {
    return fcl.mutate({
        cadence: CANCEL_ORDER,
        proposer: fcl.currentUser,
        payer: fcl.currentUser,
        authorizations: [fcl.currentUser],
        args: (arg, t) => [
            arg(price.toString(), t.UFix64),
            arg(isBid, t.Bool),
        ],
    });
}

const CANCEL_ORDER = `
import OrderBookV10 from 0xOrderBookV10
import OrderBookVaultV8 from 0xOrderBookVaultV8
import FungibleToken from 0xFungibleToken

transaction(price: UFix64, isBid: Bool) {
    let maker: Address

    prepare(signer: AuthAccount) {
        self.maker = signer.address

        if signer.borrow<&OrderBookVaultV8.TokenBundle>(from: OrderBookVaultV8.TokenStoragePath) == nil {
            signer.save(<- OrderBookVaultV8.createTokenBundle(admins: [signer.address]), to: OrderBookVaultV8.TokenStoragePath)
            signer.link<&OrderBookVaultV8.TokenBundle{OrderBookVaultV8.TokenBundlePublic}>(OrderBookVaultV8.TokenPublicPath, target: OrderBookVaultV8.TokenStoragePath)
        }

        let receiveAmount = OrderBookV10.cancelOrder(price: price, isBid: isBid)

        let contractVault = signer.borrow<&OrderBookVaultV8.TokenBundle>(from: OrderBookVaultV8.TokenStoragePath)!
        if isBid {
            let userFlowVault = getAccount(self.maker).getCapability(/public/flowTokenReceiver)
                .borrow<&{FungibleToken.Receiver}>()!
            contractVault.withdrawFlow(amount: receiveAmount, admin: self.maker)
            userFlowVault.deposit(from: <-contractFlowVault)
        }
        else {
            let userFusdVault = getAccount(self.maker).getCapability(/public/fusdReceiver)
                .borrow<&{FungibleToken.Receiver}>()!
            let contractFusdVault <- contractVault.withdrawFusd(amount: receiveAmount, admin: self.maker)
            userFusdVault.deposit(from: <-contractFusdVault)
        }
    }

    execute {
    }
}
`