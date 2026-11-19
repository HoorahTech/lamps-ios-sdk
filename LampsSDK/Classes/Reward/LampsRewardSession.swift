import Foundation
import UIKit

/// 单次激励会话：config.rewardAdSlots → 并行 SDK → 竞价 → 展示赢家。
final class LampsRewardSession: NSObject {
    private weak var viewController: UIViewController?
    private let forwardSource: String
    private weak var behaviorVisit: LampsBehaviorVisit?
    private var sdkLoader: LampsRewardSDKLoader?
    private var models: [LampsRewardAdModel] = []
    private var loadListener: LampsRewardLoadListener?
    private var interactionListener: LampsRewardInteractionListener?

    init(
        viewController: UIViewController,
        forwardSource: String = "",
        behaviorVisit: LampsBehaviorVisit? = nil
    ) {
        self.viewController = viewController
        self.forwardSource = forwardSource
        self.behaviorVisit = behaviorVisit
        super.init()
    }

    func recordAdRequest() {
        behaviorVisit?.recordRequest()
    }

    func recordAdShow(price: CGFloat) {
        behaviorVisit?.recordShow(price: price)
    }

    func recordAdClick() {
        behaviorVisit?.recordClick()
    }

    func start(
        loadListener: LampsRewardLoadListener,
        interactionListener: LampsRewardInteractionListener
    ) {
        self.loadListener = loadListener
        self.interactionListener = wrap(interactionListener)

        guard Lamps.isStarted else {
            loadListener.onReqError?(-1002, "请先调用 Lamps.start")
            return
        }
        let slots = Lamps.remoteConfig?.rewardAdSlots ?? []
        guard !slots.isEmpty else {
            loadListener.onReqError?(0, "rewardAdSlots 为空")
            return
        }

        let timeout = 1500
        let requestId = UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
        LampsSDKLog.debug("reward session start requestId=\(requestId)")
        var built: [LampsRewardAdModel] = []
        for slot in slots {
            guard let channel = LampsRewardChannel.from(channelId: slot.channelId) else {
                LampsSDKLog.debug("reward skip unknown channelId=\(slot.channelId)")
                continue
            }
            guard LampsSDKAdapterCenter.isAvailable(channel) else {
                LampsSDKLog.debug("reward skip unavailable adapter=\(channel.name)")
                continue
            }
            let model = LampsRewardAdModel(
                slot: slot,
                channel: channel,
                timeoutMs: timeout,
                userId: "",
                requestId: requestId
            )
            // 先用接口下发价；SDK 回传有效价后再覆盖。
            model.price = slot.price
            model.forwardSource = forwardSource
            built.append(model)
        }

        guard !built.isEmpty else {
            loadListener.onLoadError?()
            return
        }

        models = built
        let loader = LampsRewardSDKLoader()
        sdkLoader = loader
        recordAdRequest()
        loader.load(
            models: built,
            from: viewController,
            listener: LampsRewardSDKLoadListener(
                onSuccess: { [weak self] sdkWinner in
                    self?.finishWithSDKWinner(sdkWinner)
                },
                onFail: { [weak self] in
                    self?.finishAfterAllSDKFailed()
                }
            )
        )
    }

    private func wrap(_ listener: LampsRewardInteractionListener) -> LampsRewardInteractionListener {
        LampsRewardInteractionListener(
            onAdShow: { model in
                listener.onAdShow?(model)
            },
            onAdShowError: { model, code, message in
                listener.onAdShowError?(model, code, message)
            },
            onAdRewardArrived: { model in
                LampsRewardMonitorReporter.reportREM(model: model)
                listener.onAdRewardArrived?(model)
            },
            onAdClose: { model, hasRewarded in
                listener.onAdClose?(model, hasRewarded)
            },
            onAdClick: { model in
                listener.onAdClick?(model)
            }
        )
    }

    private func finishWithSDKWinner(_ sdkWinner: LampsRewardAdModel) {
        guard let loader = sdkLoader else { return }
        let winner = LampsRewardBidding.decide(
            models: models,
            adapters: loader.currentAdapters,
            sdkWinner: sdkWinner
        )
        LampsRewardMonitorReporter.reportWM(model: winner)
        loadListener?.onLoadSuccess?(winner)
        loader.show(
            winner,
            listener: interactionListener ?? LampsRewardInteractionListener()
        )
    }

    private func finishAfterAllSDKFailed() {
        if let loader = sdkLoader {
            LampsRewardBidding.notifyAllLoss(
                models: models,
                adapters: loader.currentAdapters
            )
        }
        loadListener?.onLoadError?()
    }
}
