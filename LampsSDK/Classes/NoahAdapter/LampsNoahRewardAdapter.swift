#if LampsADAPTER_SEPARATE_MODULE
import LampsSDK
#endif

#if canImport(NoahSDK)
import Foundation
import UIKit
import NoahSDK

/// 汇川激励 Adapter。价格取 SDK 返回；竞价后 win/loss 回告。
final class LampsNoahRewardAdapter: NSObject, LampsRewardAdapting {
    let model: LampsRewardAdModel
    private(set) var isReadyToShow = false
    weak var delegate: LampsRewardAdapterDelegate?

    private weak var viewController: UIViewController?
    private var rewardedAd: RewardedVideoAd?
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
        hasRewarded = false
        startLoadTime = Date()
        startTimer()

        let requestInfo = RequestInfo()
        requestInfo.slotKey = model.slotId
        requestInfo.timeoutInterval = model.timeoutMs > 0
            ? Double(model.timeoutMs) / 1000.0
            : 5
        RewardedVideoAd.load(withReqInfo: requestInfo, adDelegate: self)
    }

    func show() {
        guard !didShow else { return }
        guard let rewardedAd, let viewController else {
            delegate?.rewardAdapter(self, didFailToShow: LampsSDKError.api("汇川激励视频或展示控制器为空").nsError)
            return
        }
        didShow = true
        rewardedAd.show(in: viewController)
    }

    func notifyAuctionWin(secondPrice: CGFloat) {
        rewardedAd?.sendWinNotification(Double(model.price))
        _ = secondPrice
    }

    func notifyAuctionLoss(winnerPrice: CGFloat) {
        let price = winnerPrice > 0 ? winnerPrice : model.bidfloor
        rewardedAd?.sendLossNotification(Double(price), reason: .lowPrice)
    }
}

private extension LampsNoahRewardAdapter {
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
        let error = LampsSDKError.api("汇川激励请求超时").nsError
        LampsRewardMonitorReporter.reportRM(
            model: model,
            isSuccess: false,
            error: error
        )
        finishLoad(success: false, error: error)
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
        isReadyToShow = true
        delegate?.rewardAdapterDidBecomeReadyToShow(self)
    }

    func notifyRewardIfNeeded() {
        guard !hasRewarded else { return }
        hasRewarded = true
        delegate?.rewardAdapterDidReceiveReward(self)
    }
}

extension LampsNoahRewardAdapter: NoahSdkRewardedVideoListener {
    func onReVidoAdLoaded(_ ad: RewardedVideoAd) {
        guard !timedOut else { return }
        loadTimeMs = elapsedMs()
        rewardedAd = ad
        model.price = CGFloat(ad.price)

        if model.bidfloor > 0, model.price < model.bidfloor {
            let error = LampsSDKError.api("汇川出价低于底价").nsError
            LampsRewardMonitorReporter.reportRM(
                model: model,
                isSuccess: false,
                error: error
            )
            finishLoad(success: false, error: error)
            return
        }

        LampsRewardMonitorReporter.reportRM(model: model, isSuccess: true)
        finishLoad(success: true, error: nil)
        markReady()
    }

    func onReVidoAdLoadFail(_ reqInfo: RequestInfo, error: AdError?) {
        guard !timedOut else { return }
        loadTimeMs = elapsedMs()
        let message = error?.getMessage() ?? error?.toString() ?? "汇川激励视频加载失败"
        let code = Int(error?.getCode() ?? -1)
        let requestError = NSError(
            domain: LampsSDKErrorDomain,
            code: code,
            userInfo: [NSLocalizedDescriptionKey: message]
        )
        LampsRewardMonitorReporter.reportRM(
            model: model,
            isSuccess: false,
            error: requestError
        )
        finishLoad(success: false, error: requestError)
    }

    func onReVidoAdShown(_ ad: RewardedVideoAd) {
        LampsRewardMonitorReporter.reportPM(model: model)
        delegate?.rewardAdapterDidShow(self)
    }

    func onReVidoAdClosed(_ ad: RewardedVideoAd) {
        delegate?.rewardAdapterDidClose(self, hasRewarded: hasRewarded)
        rewardedAd = nil
    }

    func onReVidoStart(_ ad: RewardedVideoAd) {}
    func onReVidoEnd(_ ad: RewardedVideoAd) {}

    func onReVidoAdClicked(_ ad: RewardedVideoAd) {
        LampsRewardMonitorReporter.reportCM(model: model)
        delegate?.rewardAdapterDidClick(self)
    }

    func onReVidoRewarded(_ ad: RewardedVideoAd) {
        notifyRewardIfNeeded()
    }

    func onReVidoRewarded(_ ad: RewardedVideoAd, rewardInfo: [AnyHashable: Any]) {
        notifyRewardIfNeeded()
    }
}

#endif

@objc(LampsNoahRewardAdapterRegistrar)
public final class LampsNoahRewardAdapterRegistrar: NSObject {
    private static var didRegister = false

    @objc public static func registerIfNeeded() {
        guard !didRegister else { return }
        didRegister = true
        #if canImport(NoahSDK)
        LampsSDKAdapterCenter.register(channel: .noah) { LampsNoahRewardAdapter(model: $0) }
        #endif
    }
}
