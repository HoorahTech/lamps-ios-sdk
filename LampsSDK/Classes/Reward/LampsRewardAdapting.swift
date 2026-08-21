import Foundation
import UIKit
import CoreGraphics

/// 单家 SDK 激励适配器：只 load / show，不负责竞价与自动播放。
public protocol LampsRewardAdapting: AnyObject {
    var model: LampsRewardAdModel { get }
    var isReadyToShow: Bool { get }
    var delegate: LampsRewardAdapterDelegate? { get set }

    func load(from viewController: UIViewController?)
    func show()
    func notifyAuctionWin(secondPrice: CGFloat)
    /// - Parameters:
    ///   - winnerPrice: 胜出价（分）；无胜出方时为 0。
    ///   - winner: 本次竞价胜出候选；`nil` 表示全员失败 / 未参竞。
    func notifyAuctionLoss(winnerPrice: CGFloat, winner: LampsRewardAdModel?)
}

public protocol LampsRewardAdapterDelegate: AnyObject {
    func rewardAdapter(_ adapter: LampsRewardAdapting, didFinishLoad success: Bool, error: Error?)
    func rewardAdapterDidBecomeReadyToShow(_ adapter: LampsRewardAdapting)
    func rewardAdapterDidShow(_ adapter: LampsRewardAdapting)
    func rewardAdapter(_ adapter: LampsRewardAdapting, didFailToShow error: Error?)
    func rewardAdapterDidReceiveReward(_ adapter: LampsRewardAdapting)
    func rewardAdapterDidClose(_ adapter: LampsRewardAdapting, hasRewarded: Bool)
    func rewardAdapterDidClick(_ adapter: LampsRewardAdapting)
}
