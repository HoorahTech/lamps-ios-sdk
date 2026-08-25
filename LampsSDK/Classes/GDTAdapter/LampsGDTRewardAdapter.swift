#if LampsADAPTER_SEPARATE_MODULE
@_spi(LampsAdapter) import LampsSDK
#endif

import Foundation
import UIKit
import GDTMobSDK

/// 优量汇激励 Adapter。无 bidding token / adm，价格取 eCPM。
final class LampsGDTRewardAdapter: NSObject, LampsRewardAdapting {
    let model: LampsRewardAdModel
    private(set) var isReadyToShow = false
    weak var delegate: LampsRewardAdapterDelegate?

    private weak var viewController: UIViewController?
    private var rewardedAd: GDTRewardVideoAd?
    private var timeoutTimer: DispatchSourceTimer?
    private var startLoadTime = Date()
    private var loadTimeMs = 0
    private var timedOut = false
    private var hasRewarded = false
    private var didShow = false

    init(model: LampsRewardAdModel) {
        self.model = model
        super.init()
    }

    deinit { clearTimer() }

    func load(from viewController: UIViewController?) {
        self.viewController = viewController
        guard !model.slotId.isEmpty else {
            finishLoad(success: false, error: LampsSDKError.invalidConfig("优量汇 slotId 为空").nsError)
            return
        }
        startLoadTime = Date()
        startTimer()

        let options = GDTServerSideVerificationOptions()
        options.userIdentifier = model.userId
        let ad = GDTRewardVideoAd(placementId: model.slotId)
        ad.delegate = self
        ad.videoMuted = false
        ad.serverSideVerificationOptions = options
        rewardedAd = ad
        ad.load()
    }

    func show() {
        guard !didShow else { return }
        guard let rewardedAd, let viewController else {
            delegate?.rewardAdapter(self, didFailToShow: LampsSDKError.rewardShowError("优量汇激励视频或展示控制器为空").nsError)
            return
        }
        didShow = true
        _ = rewardedAd.show(fromRootViewController: viewController)
        LampsRewardMonitorReporter.reportPM(model: model)
    }

    func notifyAuctionWin(secondPrice: CGFloat) {
        guard let rewardedAd else { return }
        // 单位：分。expectCostPrice=本广告胜出价；highestLossPrice=最高失败价（二价）。
        var winInfo: [AnyHashable: Any] = [
            "expectCostPrice": NSNumber(value: Int(max(model.price, 0)))
        ]
        if secondPrice > 0 {
            winInfo["highestLossPrice"] = NSNumber(value: Int(secondPrice))
        }
        rewardedAd.sendWinNotification(withInfo: winInfo)
    }

    func notifyAuctionLoss(winnerPrice: CGFloat, winner: LampsRewardAdModel?) {
        guard let rewardedAd else { return }
        var lossInfo: [AnyHashable: Any] = [
            "lossReason": NSNumber(value: GDTAdBiddingLossReason.lowPrice.rawValue),
            "adnId": gdtLossAdnId(winner: winner)
        ]
        if winnerPrice > 0 {
            lossInfo["winPrice"] = NSNumber(value: Int(winnerPrice))
        }
        rewardedAd.sendLossNotification(withInfo: lossInfo)
    }

    /// GDT_M_ADNID：1=优量汇非 bidding；2=第三方 ADN；4=优量汇其他 bidding。
    private func gdtLossAdnId(winner: LampsRewardAdModel?) -> String {
        guard let winner, winner.channel == .gdt else { return "2" }
        return winner.isPD ? "1" : "4"
    }
}

private extension LampsGDTRewardAdapter {
    func startTimer() {
        clearTimer()
        timedOut = false
        guard model.timeoutMs > 0 else { return }
        let timer = DispatchSource.makeTimerSource(queue: .main)
        timer.schedule(deadline: .now() + .milliseconds(model.timeoutMs), repeating: .never)
        timer.setEventHandler { [weak self] in self?.handleTimeout() }
        timer.resume()
        timeoutTimer = timer
    }

    func handleTimeout() {
        timedOut = true
        clearTimer()
        loadTimeMs = elapsedMs()
        LampsRewardMonitorReporter.reportRM(
            model: model,
            isSuccess: false,
        )
        finishLoad(success: false, error: LampsSDKError.rewardLoadError("优量汇激励请求超时").nsError)
    }

    func clearTimer() {
        timeoutTimer?.cancel()
        timeoutTimer = nil
    }

    func elapsedMs() -> Int {
        Int((Date().timeIntervalSince1970 - startLoadTime.timeIntervalSince1970) * 1000)
    }

    func finishLoad(success: Bool, error: Error?) {
        clearTimer()
        delegate?.rewardAdapter(self, didFinishLoad: success, error: error)
    }

    func markReady() {
        guard !isReadyToShow else { return }
        isReadyToShow = true
        delegate?.rewardAdapterDidBecomeReadyToShow(self)
    }
}

extension LampsGDTRewardAdapter: GDTRewardedVideoAdDelegate {
    func gdt_rewardVideoAdDidLoad(_ rewardedVideoAd: GDTRewardVideoAd) {
        guard !timedOut else { return }
        loadTimeMs = elapsedMs()
        let ecpm = rewardedVideoAd.eCPM()
        if ecpm > 0 {
            model.price = CGFloat(ecpm)
        }
        LampsRewardMonitorReporter.reportRM(model: model, isSuccess: true)
        finishLoad(success: true, error: nil)
    }

    func gdt_rewardVideoAd(_ rewardedVideoAd: GDTRewardVideoAd, didFailWithError error: Error) {
        guard !timedOut else { return }
        loadTimeMs = elapsedMs()
        LampsRewardMonitorReporter.reportRM(
            model: model,
            isSuccess: false,
            error: error
        )
        finishLoad(success: false, error: error)
    }

    func gdt_rewardVideoAdVideoDidLoad(_ rewardedVideoAd: GDTRewardVideoAd) {
        guard !timedOut else { return }
        markReady()
    }

    func gdt_rewardVideoAdDidExposed(_ rewardedVideoAd: GDTRewardVideoAd) {
        delegate?.rewardAdapterDidShow(self)
    }

    func gdt_rewardVideoAdDidClose(_ rewardedVideoAd: GDTRewardVideoAd) {
        rewardedAd = nil
        delegate?.rewardAdapterDidClose(self, hasRewarded: hasRewarded)
    }

    func gdt_rewardVideoAdDidClicked(_ rewardedVideoAd: GDTRewardVideoAd) {
        LampsRewardMonitorReporter.reportCM(model: model)
        delegate?.rewardAdapterDidClick(self)
    }

    func gdt_rewardVideoAdDidRewardEffective(_ rewardedVideoAd: GDTRewardVideoAd, info: [AnyHashable: Any]) {
        hasRewarded = true
        delegate?.rewardAdapterDidReceiveReward(self)
    }
}

@objc(LampsGDTRewardAdapterRegistrar)
final class LampsGDTRewardAdapterRegistrar: NSObject {
    private static var didRegister = false

    @objc static func registerIfNeeded() {
        guard !didRegister else { return }
        didRegister = true
        LampsSDKAdapterCenter.register(channel: .gdt) { LampsGDTRewardAdapter(model: $0) }
    }
}
