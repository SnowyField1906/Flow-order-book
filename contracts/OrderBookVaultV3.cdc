import FungibleToken from 0x9a0766d93b6608b7
import FUSD from 0xe223d8a629e49c68
import FlowToken from 0x7e60df042a9c0868

pub contract OrderBookVaultV3 {
  pub let TokenStoragePath  : StoragePath
  pub let TokenPublicPath  : PublicPath

  pub var flowBalance: UFix64
  pub var fusdBalance: UFix64

  pub resource interface TokenBundlePublic {
    pub let admins: [Address]
    pub fun depositFlow(flowVault: @FlowToken.Vault, admin: Address)
    pub fun depositFusd(fusdVault: @FUSD.Vault, admin: Address)
    pub fun withdrawFlow(amount: UFix64, admin: Address)
    pub fun withdrawFusd(amount: UFix64, admin: Address)
  }

  pub resource TokenBundle: TokenBundlePublic {
    pub let admins: [Address]
    pub let flowVault: @FlowToken.Vault
    pub let fusdVault: @FUSD.Vault
    
    init(admins: [Address]) {
      self.admins = admins
      self.flowVault <- FlowToken.createEmptyVault() as! @FlowToken.Vault
      self.fusdVault <- FUSD.createEmptyVault() as! @FUSD.Vault
    }

    pub fun depositFlow(flowVault: @FlowToken.Vault, admin: Address) {
      OrderBookVaultV3.flowBalance = OrderBookVaultV3.flowBalance + flowVault.balance
      self.flowVault.deposit(from: <-flowVault)
      if self.admins.contains(admin) == false {
        self.admins.append(admin)
      }
    }

    pub fun depositFusd(fusdVault: @FUSD.Vault, admin: Address) {
      OrderBookVaultV3.fusdBalance = OrderBookVaultV3.fusdBalance + fusdVault.balance
      self.fusdVault.deposit(from: <-fusdVault)
      if self.admins.contains(admin) == false {
        self.admins.append(admin)
      }
    }

    pub fun withdrawFlow(amount: UFix64, admin: Address) {
      pre {
        self.admins.contains(admin): "Only admins can withdraw"
      }
      let receiverFlowVault = getAccount(admin).getCapability(/public/flowTokenReceiver)
        .borrow<&FlowToken.Vault{FungibleToken.Receiver}>()!
      receiverFlowVault.deposit(from: <- self.flowVault.withdraw(amount: amount))
      OrderBookVaultV3.flowBalance = OrderBookVaultV3.flowBalance - amount
    }

    pub fun withdrawFusd(amount: UFix64, admin: Address) {
      pre {
        self.admins.contains(admin): "Only admins can withdraw"
      }
      let receiverFusdVault = getAccount(admin).getCapability(/public/fusdReceiver)
        .borrow<&FUSD.Vault{FungibleToken.Receiver}>()!
      receiverFusdVault.deposit(from: <- self.fusdVault.withdraw(amount: amount))
      OrderBookVaultV3.fusdBalance = OrderBookVaultV3.fusdBalance - amount
    }

    pub fun getFlowBalance(): UFix64 {
      return self.flowVault.balance
    }

    pub fun getFusdBalance(): UFix64 {
      return self.fusdVault.balance
    }

    destroy () {
      destroy self.flowVault
      destroy self.fusdVault
    }
  }

  pub fun createTokenBundle(admins: [Address]): @TokenBundle {
    return <-create TokenBundle(admins: admins)
  }

  init() {
    self.flowBalance = 0.0
    self.fusdBalance = 0.0

    self.TokenPublicPath = /public/OrderBookVaultTokenV3
    self.TokenStoragePath = /storage/OrderBookVaultTokenV3

    self.account.save(<-create TokenBundle(admins: []), to: self.TokenStoragePath)
    self.account.link<&TokenBundle{TokenBundlePublic}>(self.TokenPublicPath, target: self.TokenStoragePath)
  }
}