#if LampsADAPTER_SEPARATE_MODULE
@_spi(LampsAdapter) import LampsSDK
#endif

import Foundation
import UIKit
import BUAdSDK

/// 穿山甲激励 Adapter。BD 用服务端竞价 adm 加载；PD 走 loadData。加载成功后都读 mediaExt 价格。
final class LampsCSJRewardAdapter: NSObject, LampsRewardAdapting {
    let model: LampsRewardAdModel
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
        if model.isBD {
            loadServerBid()
        } else {
            startTimer()
            loadFromClient()
        }
    }

    func show() {
        guard !didShow else { return }
        guard let expressAd, let viewController else {
            delegate?.rewardAdapter(self, didFailToShow: LampsSDKError.rewardShowError("穿山甲激励视频或展示控制器为空").nsError)
            return
        }
        didShow = true
        _ = expressAd.show(fromRootViewController: viewController)
        LampsRewardMonitorReporter.reportPM(model: model)
    }

    func notifyAuctionWin(secondPrice: CGFloat) {
    }

    func notifyAuctionLoss(winnerPrice: CGFloat, winner: LampsRewardAdModel?) {
        _ = winner
    }
}

private extension LampsCSJRewardAdapter {
    func loadFromClient() {
        makeRewardedAd().loadData()
    }

    /// BD：竞价请求单独超时。adm 返回后再启动与 PD 相同的 SDK 超时。
    func loadServerBid() {
        let token = biddingToken(slotId: model.slotId)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !token.isEmpty else {
            failServerBid(LampsSDKError.rewardLoadError("穿山甲竞价 token 为空").nsError)
            return
        }
        LampsRewardServerBid.fetch(ttToken: token, slotId: model.slotId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self, !self.timedOut else { return }
                switch result {
                case .success(let bid):
                    self.applySDKPriceIfValid(bid.price)
                    self.startTimer()
                    self.makeRewardedAd().setAdMarkup(bid.adm)
                case .failure(let error):
                    self.failServerBid(error)
                }
            }
        }
    }

    func makeRewardedAd() -> BUNativeExpressRewardedVideoAd {
        let rewardedModel = BURewardedVideoModel()
        rewardedModel.userId = model.userId
        let ad = BUNativeExpressRewardedVideoAd(slotID: model.slotId, rewardedVideoModel: rewardedModel)
        ad.delegate = self
        expressAd = ad
        return ad
    }

    func failServerBid(_ error: Error) {
        guard !timedOut else { return }
        loadTimeMs = elapsedMs()
        LampsRewardMonitorReporter.reportRM(model: model, isSuccess: false, error: error)
        finishLoad(success: false, error: error)
    }

    /// 激励视频 bidding token。不区分信息流混出代码位。
    func biddingToken(slotId: String) -> String {
        let slot = BUAdSlot()
        slot.position = .fullscreen
        slot.imgSize = BUSize(by: .drawFullScreen)
        slot.id = slotId
        slot.adType = .rewardVideo
        return BUNativeExpressAdManager(
            slot: slot,
            adSize: CGSize(width: UIScreen.main.bounds.width, height: 0)
        ).biddingToken()
    }

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
        finishLoad(success: false, error: LampsSDKError.rewardLoadError("穿山甲激励请求超时").nsError)
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

    func updatePrice(from ad: BUNativeExpressRewardedVideoAd) {
        if let mediaExt = ad.mediaExt as? [AnyHashable: Any] {
            if let number = mediaExt["price"] as? NSNumber {
                applySDKPriceIfValid(CGFloat(truncating: number))
            } else if let text = mediaExt["price"] as? String, let value = Double(text) {
                applySDKPriceIfValid(CGFloat(value))
            } else if let number = mediaExt["ecpm"] as? NSNumber {
                applySDKPriceIfValid(CGFloat(truncating: number))
            }
        }
    }

    private func applySDKPriceIfValid(_ sdkPrice: CGFloat) {
        guard sdkPrice > 0 else { return }
        model.price = sdkPrice
    }
}

extension LampsCSJRewardAdapter: BUNativeExpressRewardedVideoAdDelegate {
    func nativeExpressRewardedVideoAdDidLoad(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
        guard !timedOut else { return }
        loadTimeMs = elapsedMs()
        updatePrice(from: rewardedVideoAd)
        LampsRewardMonitorReporter.reportRM(model: model, isSuccess: true)
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
            error: error
        )
        finishLoad(success: false, error: error)
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

@objc(LampsCSJRewardAdapterRegistrar)
final class LampsCSJRewardAdapterRegistrar: NSObject {
    private static var didRegister = false

    @objc static func registerIfNeeded() {
        guard !didRegister else { return }
        didRegister = true
        LampsSDKAdapterCenter.register(channel: .csj) { LampsCSJRewardAdapter(model: $0) }
    }
}
