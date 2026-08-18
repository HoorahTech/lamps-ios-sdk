import Foundation
import UIKit

/// 单次激励会话：config.rewardAdSlots → 并行 SDK → 竞价 → 展示赢家。
final class LampsRewardSession: NSObject {
    private let viewController: UIViewController
    private var sdkLoader: LampsRewardSDKLoader?
    private var models: [LampsRewardAdModel] = []
    private var loadListener: LampsRewardLoadListener?
    private var interactionListener: LampsRewardInteractionListener?

    init(viewController: UIViewController) {
        self.viewController = viewController
        super.init()
    }

    func start(
        loadListener: LampsRewardLoadListener,
        interactionListener: LampsRewardInteractionListener
    ) {
        self.loadListener = loadListener
        self.interactionListener = wrap(interactionListener)

        guard LampsSDK.isStarted else {
            loadListener.onReqError?(-1002, "请先调用 LampsSDK.start")
            return
        }
        let slots = LampsSDK.remoteConfig?.rewardAdSlots ?? []
        guard !slots.isEmpty else {
            loadListener.onReqError?(0, "rewardAdSlots 为空")
            return
        }

        let timeout = LampsSDK.config?.rewardTimeoutMs ?? 5000
        let userId = LampsSDK.config?.rewardUserId ?? ""
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
            built.append(
                LampsRewardAdModel(
                    slot: slot,
                    channel: channel,
                    timeoutMs: timeout,
                    userId: userId
                )
            )
        }

        guard !built.isEmpty else {
            loadListener.onLoadError?()
            return
        }

        models = built
        let loader = LampsRewardSDKLoader()
        sdkLoader = loader
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
