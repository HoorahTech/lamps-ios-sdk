import Foundation
import UIKit

/// 并行请求各家 SDK，全部返回后按真实价格选出最高价；展示由上层 commit 后触发。
final class LampsRewardSDKLoader: NSObject {
    private var requestModels: [LampsRewardAdModel] = []
    private var adapters: [ObjectIdentifier: LampsRewardAdapting] = [:]
    private var hasFinished = false
    private var hasShown = false
    private var committedWinner: LampsRewardAdModel?
    private var loadListener: LampsRewardSDKLoadListener?
    private var interactionListener: LampsRewardInteractionListener?
    private var showWaitTimer: DispatchSourceTimer?

    var currentAdapters: [ObjectIdentifier: LampsRewardAdapting] {
        adapters
    }

    deinit {
        clearShowWaitTimer()
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

    func show(_ model: LampsRewardAdModel, listener: LampsRewardInteractionListener) {
        committedWinner = model
        interactionListener = listener
        showCommittedWinnerIfNeeded()
        startShowWaitTimerIfNeeded()
    }

    private func reset() {
        requestModels = []
        adapters.removeAll()
        hasFinished = false
        hasShown = false
        committedWinner = nil
        loadListener = nil
        interactionListener = nil
        clearShowWaitTimer()
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

    private func showCommittedWinnerIfNeeded() {
        guard hasFinished, !hasShown, let winner = committedWinner else { return }
        guard let adapter = adapters[ObjectIdentifier(winner)], adapter.isReadyToShow else { return }
        hasShown = true
        clearShowWaitTimer()
        adapter.show()
    }

    private func startShowWaitTimerIfNeeded() {
        guard !hasShown, committedWinner != nil else { return }
        clearShowWaitTimer()
        let timer = DispatchSource.makeTimerSource(queue: .main)
        timer.schedule(deadline: .now() + .seconds(8), repeating: .never)
        timer.setEventHandler { [weak self] in
            self?.handleShowWaitTimeout()
        }
        timer.resume()
        showWaitTimer = timer
    }

    private func handleShowWaitTimeout() {
        guard !hasShown, let winner = committedWinner else { return }
        hasShown = true
        clearShowWaitTimer()
        interactionListener?.onAdShowError?(winner, -19, "激励视频未就绪")
    }

    private func clearShowWaitTimer() {
        showWaitTimer?.cancel()
        showWaitTimer = nil
    }
}

extension LampsRewardSDKLoader: LampsRewardAdapterDelegate {
    func rewardAdapter(_ adapter: LampsRewardAdapting, didFinishLoad success: Bool, error: Error?) {
        checkFinish(adapter.model, success: success)
    }

    func rewardAdapterDidBecomeReadyToShow(_ adapter: LampsRewardAdapting) {
        showCommittedWinnerIfNeeded()
    }

    func rewardAdapterDidShow(_ adapter: LampsRewardAdapting) {
        interactionListener?.onAdShow?(adapter.model)
    }

    func rewardAdapter(_ adapter: LampsRewardAdapting, didFailToShow error: Error?) {
        let nsError = error as NSError?
        interactionListener?.onAdShowError?(
            adapter.model,
            nsError?.code ?? 0,
            nsError?.localizedDescription
        )
    }

    func rewardAdapterDidReceiveReward(_ adapter: LampsRewardAdapting) {
        interactionListener?.onAdRewardArrived?(adapter.model)
    }

    func rewardAdapterDidClose(_ adapter: LampsRewardAdapting, hasRewarded: Bool) {
        interactionListener?.onAdClose?(adapter.model, hasRewarded)
    }

    func rewardAdapterDidClick(_ adapter: LampsRewardAdapting) {}
}
