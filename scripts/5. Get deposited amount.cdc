import OrderBookV21 from 0xOrderBookV21

pub fun main(userAddress: Address) : {String: UFix64} {
    let admin = getAccount(userAddress).getCapability(OrderBookV21.AdminPublicPath)!.borrow<&OrderBookV21.Admin{OrderBookV21.AdminPublic}>()!

    return {"Flow": admin.flowDeposited(), "FUSD": admin.fusdDeposited()}
}