import Foundation
import UIKit

/// 并行请求各家 SDK，全部返回后按真实价格选出最高价；展示由上层 commit 后触发。
final class LampsRewardSDKLoader: NSObject {
    private var requestModels: [LampsRewardAdModel] = []
    private var adapters: [ObjectIdentifier: LampsRewardAdapting] = [:]
    private var hasFinished = false
    private var hasShown = false
    private var loadListener: LampsRewardSDKLoadListener?
    private var interactionListener: LampsRewardInteractionListener?

    var currentAdapters: [ObjectIdentifier: LampsRewardAdapting] {
        adapters
    }

    func load(
        models: [LampsRewardAdModel],
        from viewController: UIViewController?,
        listener: LampsRewardSDKLoadListener
    ) {
        reset()
        requestModels = models
        loadListener = listener
        for model in models {
            model.requestState = .unknown
        }
        guard !models.isEmpty else {
            hasFinished = true
            listener.onFail?()
            return
        }
        for model in models {
            guard let adapter = LampsSDKAdapterCenter.makeAdapter(model: model) else {
                model.requestState = .failure
                checkRequestStateReturnIfFinish()
                continue
            }
            adapter.delegate = self
            adapters[ObjectIdentifier(model)] = adapter
            adapter.load(from: viewController)
        }
    }

    /// 请求已结束并完成竞价后直接展示，不等待视频下载完成。
    func show(_ model: LampsRewardAdModel, listener: LampsRewardInteractionListener) {
        guard !hasShown else { return }
        hasShown = true
        interactionListener = listener
        guard let adapter = adapters[ObjectIdentifier(model)] else {
            LampsSDKLog.debug(
                "reward show skipped: adapter missing slotId=\(model.slotId)",
                category: .reward
            )
            interactionListener?.onAdShowError?(model, -19, "激励视频未就绪")
            return
        }
        adapter.show()
    }

    private func reset() {
        requestModels = []
        adapters.removeAll()
        hasFinished = false
        hasShown = false
        loadListener = nil
        interactionListener = nil
    }

    private func checkFinish(_ model: LampsRewardAdModel, success: Bool) {
        guard !hasFinished else { return }
        model.requestState = success ? .success : .failure
        checkRequestStateReturnIfFinish()
    }

    private func checkRequestStateReturnIfFinish() {
        guard !hasFinished else { return }
        if requestModels.contains(where: { $0.requestState == .unknown }) {
            return
        }
        if let winner = maxPriceSuccessModel() {
            hasFinished = true
            loadListener?.onSuccess?(winner)
        } else {
            hasFinished = true
            loadListener?.onFail?()
        }
    }

    private func maxPriceSuccessModel() -> LampsRewardAdModel? {
        requestModels
            .filter { $0.requestState == .success }
            .max { $0.price < $1.price }
    }
}

extension LampsRewardSDKLoader: LampsRewardAdapterDelegate {
    func rewardAdapter(_ adapter: LampsRewardAdapting, didFinishLoad success: Bool, error: Error?) {
        let model = adapter.model
        if success {
            LampsSDKLog.debug(
                "reward load ok channel=\(model.channel.name) slotId=\(model.slotId) price=\(model.price)",
                category: .reward
            )
        } else {
            LampsSDKLog.debug(
                "reward load fail channel=\(model.channel.name) slotId=\(model.slotId) \(error?.localizedDescription ?? "")",
                category: .reward
            )
        }
        checkFinish(model, success: success)
    }

    func rewardAdapterDidShow(_ adapter: LampsRewardAdapting) {
        let model = adapter.model
        LampsSDKLog.debug(
            "reward show channel=\(model.channel.name) slotId=\(model.slotId)",
            category: .reward
        )
        interactionListener?.onAdShow?(model)
    }

    func rewardAdapter(_ adapter: LampsRewardAdapting, didFailToShow error: Error?) {
        let model = adapter.model
        let nsError = error as NSError?
        LampsSDKLog.debug(
            "reward show fail channel=\(model.channel.name) slotId=\(model.slotId) code=\(nsError?.code ?? 0) \(nsError?.localizedDescription ?? "")",
            category: .reward
        )
        interactionListener?.onAdShowError?(
            model,
            nsError?.code ?? 0,
            nsError?.localizedDescription
        )
    }

    func rewardAdapterDidReceiveReward(_ adapter: LampsRewardAdapting) {
        let model = adapter.model
        LampsSDKLog.debug(
            "reward arrived channel=\(model.channel.name) slotId=\(model.slotId)",
            category: .reward
        )
        interactionListener?.onAdRewardArrived?(model)
    }

    func rewardAdapterDidClose(_ adapter: LampsRewardAdapting, hasRewarded: Bool) {
        let model = adapter.model
        LampsSDKLog.debug(
            "reward close channel=\(model.channel.name) slotId=\(model.slotId) rewarded=\(hasRewarded)",
            category: .reward
        )
        interactionListener?.onAdClose?(model, hasRewarded)
    }

    func rewardAdapterDidClick(_ adapter: LampsRewardAdapting) {
        let model = adapter.model
        LampsSDKLog.debug(
            "reward click channel=\(model.channel.name) slotId=\(model.slotId)",
            category: .reward
        )
        interactionListener?.onAdClick?(model)
    }
}
