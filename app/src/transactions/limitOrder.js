import * as fcl from "@onflow/fcl";

export default async function limitOrder(price, amount, isBid) {
    return fcl.mutate({
        cadence: OFFER_DETAILS,
        proposer: fcl.currentUser,
        payer: fcl.currentUser,
        authorizations: [fcl.currentUser],
        args: (arg, t) => [
            arg(price.toString(), t.UFix64),
            arg(amount.toString(), t.UFix64),
            arg(isBid, t.Bool),
        ],
    });
}

const OFFER_DETAILS = `
import OrderBookV7 from 0xOrderBookV7
import OrderBookVaultV3 from 0xOrderBookVaultV3
import FlowToken from 0xFlowToken
import FUSD from 0xFUSD

transaction(price: UFix64, amount: UFix64, isBid: Bool) {
    let maker: Address

    prepare(signer: AuthAccount) {
        self.maker = signer.address

        if signer.borrow<&OrderBookVaultV3.TokenBundle>(from: OrderBookVaultV3.TokenStoragePath) == nil {
            signer.save(<- OrderBookVaultV3.createTokenBundle(admins: [signer.address]), to: OrderBookVaultV3.TokenStoragePath)
            signer.link<&OrderBookVaultV3.TokenBundle{OrderBookVaultV3.TokenBundlePublic}>(OrderBookVaultV3.TokenPublicPath, target: OrderBookVaultV3.TokenStoragePath)
       }

        let contractVault = signer.borrow<&OrderBookVaultV3.TokenBundle>(from: OrderBookVaultV3.TokenStoragePath)!

        if isBid {
          let vaultRef = signer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)!
          let userVault <- vaultRef.withdraw(amount: amount) as! @FlowToken.Vault
          contractVault.depositFlow(flowVault: <-userVault, admin: self.maker)
        }
        else {
          let vaultRef = signer.borrow<&FUSD.Vault>(from: /storage/fusdVault)!
          let userVault <- vaultRef.withdraw(amount: amount) as! @FUSD.Vault
          contractVault.depositFusd(fusdVault: <-userVault, admin: self.maker)
        }
    }

    execute {
        OrderBookV7.limitOrder(self.maker, price: price, amount: amount, isBid: isBid)
    }
}
`