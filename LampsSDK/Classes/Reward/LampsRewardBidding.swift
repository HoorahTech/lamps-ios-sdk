import Foundation
import CoreGraphics

/// 激励竞价：在成功加载的 SDK 候选中取最高价；向落败方回告 loss。
enum LampsRewardBidding {
    static func decide(
        models: [LampsRewardAdModel],
        adapters: [ObjectIdentifier: LampsRewardAdapting],
        sdkWinner: LampsRewardAdModel
    ) -> LampsRewardAdModel {
        notifyAuctionResult(models: models, adapters: adapters, winner: sdkWinner)
        return sdkWinner
    }

    static func notifyAllLoss(
        models: [LampsRewardAdModel],
        adapters: [ObjectIdentifier: LampsRewardAdapting]
    ) {
        notifyAuctionResult(models: models, adapters: adapters, winner: nil)
    }

    private static func notifyAuctionResult(
        models: [LampsRewardAdModel],
        adapters: [ObjectIdentifier: LampsRewardAdapting],
        winner: LampsRewardAdModel?
    ) {
        let secondPrice = secondPrice(among: models, excluding: winner)
        for model in models {
            guard let adapter = adapters[ObjectIdentifier(model)] else { continue }
            if let winner, model === winner {
                adapter.notifyAuctionWin(secondPrice: secondPrice)
            } else {
                let lossPrice = winner?.price ?? model.bidfloor
                adapter.notifyAuctionLoss(winnerPrice: lossPrice)
            }
        }
    }

    private static func secondPrice(
        among models: [LampsRewardAdModel],
        excluding winner: LampsRewardAdModel?
    ) -> CGFloat {
        models
            .filter { $0.requestState == .success && $0 !== winner }
            .map(\.price)
            .max() ?? 0
    }
}
