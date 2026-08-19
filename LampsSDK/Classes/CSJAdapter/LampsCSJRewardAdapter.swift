#if LampsADAPTER_SEPARATE_MODULE
import LampsSDK
#endif

#if canImport(BUAdSDK)
import Foundation
import UIKit
import BUAdSDK

/// 穿山甲激励 Adapter。无 adm，客户端竞价读 mediaExt.price。
final class LampsCSJRewardAdapter: NSObject, LampsRewardAdapting {
    let model: LampsRewardAdModel
    private(set) var isReadyToShow = false
    weak var delegate: LampsRewardAdapterDelegate?

    private weak var viewController: UIViewController?
    private var expressAd: BUNativeExpressRewardedVideoAd?
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
            finishLoad(success: false, error: LampsSDKError.invalidConfig("穿山甲 slotId 为空").nsError)
            return
        }
        startLoadTime = Date()
        startTimer()

        let rewardedModel = BURewardedVideoModel()
        rewardedModel.userId = model.userId
        let ad = BUNativeExpressRewardedVideoAd(slotID: model.slotId, rewardedVideoModel: rewardedModel)
        ad.delegate = self
        expressAd = ad
        ad.loadData()
    }

    func show() {
        guard !didShow else { return }
        guard let expressAd, let viewController else {
            delegate?.rewardAdapter(self, didFailToShow: LampsSDKError.api("穿山甲激励视频或展示控制器为空").nsError)
            return
        }
        didShow = true
        _ = expressAd.show(fromRootViewController: viewController)
        LampsRewardMonitorReporter.reportPM(model: model)
    }

    func notifyAuctionWin(secondPrice: CGFloat) {
        expressAd?.win(secondPrice > 0 ? NSNumber(value: Double(secondPrice)) : nil)
    }

    func notifyAuctionLoss(winnerPrice: CGFloat) {
        expressAd?.loss(
            winnerPrice > 0 ? NSNumber(value: Double(winnerPrice)) : nil,
            lossReason: "2",
            winBidder: nil
        )
    }
}

private extension LampsCSJRewardAdapter {
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
            filterReason: "18",
            delayTimeMs: loadTimeMs
        )
        finishLoad(success: false, error: LampsSDKError.api("穿山甲激励请求超时").nsError)
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

    func updatePrice(from ad: BUNativeExpressRewardedVideoAd) {
        if let mediaExt = ad.mediaExt as? [AnyHashable: Any] {
            if let number = mediaExt["price"] as? NSNumber {
                model.price = CGFloat(truncating: number)
            } else if let text = mediaExt["price"] as? String, let value = Double(text) {
                model.price = CGFloat(value)
            } else if let number = mediaExt["ecpm"] as? NSNumber {
                model.price = CGFloat(truncating: number)
            }
        }
    }
}

extension LampsCSJRewardAdapter: BUNativeExpressRewardedVideoAdDelegate {
    func nativeExpressRewardedVideoAdDidLoad(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
        guard !timedOut else { return }
        loadTimeMs = elapsedMs()
        updatePrice(from: rewardedVideoAd)
        LampsRewardMonitorReporter.reportRM(model: model, isSuccess: true, delayTimeMs: loadTimeMs)
        finishLoad(success: true, error: nil)
    }

    func nativeExpressRewardedVideoAd(
        _ rewardedVideoAd: BUNativeExpressRewardedVideoAd,
        didFailWithError error: Error?
    ) {
        guard !timedOut else { return }
        loadTimeMs = elapsedMs()
        LampsRewardMonitorReporter.reportRM(
            model: model,
            isSuccess: false,
            delayTimeMs: loadTimeMs,
            error: error
        )
        finishLoad(success: false, error: error)
    }

    func nativeExpressRewardedVideoAdDidDownLoadVideo(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
        guard !timedOut else { return }
        markReady()
    }

    func nativeExpressRewardedVideoAdViewRenderFail(
        _ rewardedVideoAd: BUNativeExpressRewardedVideoAd,
        error: Error?
    ) {
        delegate?.rewardAdapter(self, didFailToShow: error)
    }

    func nativeExpressRewardedVideoAdDidVisible(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
        delegate?.rewardAdapterDidShow(self)
    }

    func nativeExpressRewardedVideoAdDidClose(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
        expressAd = nil
        delegate?.rewardAdapterDidClose(self, hasRewarded: hasRewarded)
    }

    func nativeExpressRewardedVideoAdDidClick(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
        LampsRewardMonitorReporter.reportCM(model: model)
        delegate?.rewardAdapterDidClick(self)
    }

    func nativeExpressRewardedVideoAdServerRewardDidSucceed(
        _ rewardedVideoAd: BUNativeExpressRewardedVideoAd,
        verify: Bool
    ) {
        hasRewarded = true
        delegate?.rewardAdapterDidReceiveReward(self)
    }
}

#endif

@objc(LampsCSJRewardAdapterRegistrar)
public final class LampsCSJRewardAdapterRegistrar: NSObject {
    private static var didRegister = false

    @objc public static func registerIfNeeded() {
        guard !didRegister else { return }
        didRegister = true
        #if canImport(BUAdSDK)
        LampsSDKAdapterCenter.register(channel: .csj) { LampsCSJRewardAdapter(model: $0) }
        #endif
    }
}
