import Foundation
import UIKit
import CoreGraphics

@objc public enum LampsRewardCallbackName: Int {
    case busy = 0
    case reqError
    case loadSuccess
    case loadError
    case showSuccess
    case showError
    case rewardArrived
    case close
}

@objcMembers
public final class LampsRewardCallback: NSObject {
    public var name: LampsRewardCallbackName = .busy
    public var status: Bool = true
    public var rewardStatus: Bool = false
    public var errCode: Int = 0
    public var errMessage: String?
    public var channelName: String = ""
    public var slotId: String = ""
    public var price: CGFloat = 0
}

public typealias LampsRewardEventHandler = (LampsRewardCallback) -> Void
public typealias LampsRewardCompletion = (Bool, Error?) -> Void

enum LampsRewardState {
    case idle
    case requesting
    case showing

    var isActive: Bool { self != .idle }
}

/// 激励视频编排器（对齐 HCADCommonRewardVideoManager）。
/// 入参使用 config.rewardAdSlots；并行请求已注册 Adapter，竞价后展示赢家。
@objcMembers
public final class LampsRewardVideoManager: NSObject {
    public static let shared = LampsRewardVideoManager()

    private var state: LampsRewardState = .idle
    private var rewardSession: LampsRewardSession?
    private var closeCompletion: LampsRewardCompletion?

    public var isActive: Bool { state.isActive }

    /// 开始激励流程；生命周期事件通过 handler 回调。
    @objc(startFromViewController:handler:)
    public func start(from viewController: UIViewController, handler: LampsRewardEventHandler?) {
        start(from: viewController, handler: handler, completion: nil)
    }

    /// 开始激励；`completion` 在 close / 失败结束时回调是否发奖。
    @objc(startFromViewController:handler:completion:)
    public func start(
        from viewController: UIViewController,
        handler: LampsRewardEventHandler?,
        completion: LampsRewardCompletion?
    ) {
        guard !state.isActive else {
            let busy = makeCallback(name: .busy, status: false, message: "激励视频进行中")
            handler?(busy)
            completion?(false, LampsSDKError.api("激励视频进行中").nsError)
            return
        }
        guard Lamps.isStarted else {
            let error = LampsSDKError.notStarted("请先调用 Lamps.start").nsError
            handler?(makeCallback(name: .reqError, status: false, code: error.code, message: error.localizedDescription))
            completion?(false, error)
            return
        }

        state = .requesting
        closeCompletion = completion
        let session = LampsRewardSession(viewController: viewController)
        rewardSession = session
        session.start(
            loadListener: makeLoadListener(session: session, handler: handler),
            interactionListener: makeInteractionListener(session: session, handler: handler)
        )
    }

    private func makeLoadListener(
        session: LampsRewardSession,
        handler: LampsRewardEventHandler?
    ) -> LampsRewardLoadListener {
        LampsRewardLoadListener(
            onReqError: { [weak self] code, message in
                self?.deliver(
                    self?.makeCallback(name: .reqError, status: false, code: code, message: message),
                    from: session,
                    handler: handler,
                    nextState: .idle,
                    finishSuccess: false,
                    finishError: LampsSDKError.api(message ?? "请求失败").nsError
                )
            },
            onLoadSuccess: { [weak self] model in
                self?.deliver(
                    self?.makeCallback(name: .loadSuccess, model: model),
                    from: session,
                    handler: handler,
                    nextState: nil,
                    finishSuccess: nil,
                    finishError: nil
                )
            },
            onLoadError: { [weak self] in
                self?.deliver(
                    self?.makeCallback(name: .loadError, status: false, message: "激励视频加载失败"),
                    from: session,
                    handler: handler,
                    nextState: .idle,
                    finishSuccess: false,
                    finishError: LampsSDKError.api("激励视频加载失败").nsError
                )
            }
        )
    }

    private func makeInteractionListener(
        session: LampsRewardSession,
        handler: LampsRewardEventHandler?
    ) -> LampsRewardInteractionListener {
        LampsRewardInteractionListener(
            onAdShow: { [weak self] model in
                self?.deliver(
                    self?.makeCallback(name: .showSuccess, model: model),
                    from: session,
                    handler: handler,
                    nextState: .showing,
                    finishSuccess: nil,
                    finishError: nil
                )
            },
            onAdShowError: { [weak self] model, code, message in
                self?.deliver(
                    self?.makeCallback(
                        name: .showError,
                        model: model,
                        status: false,
                        code: code,
                        message: message
                    ),
                    from: session,
                    handler: handler,
                    nextState: .idle,
                    finishSuccess: false,
                    finishError: LampsSDKError.api(message ?? "展示失败").nsError
                )
            },
            onAdRewardArrived: { [weak self] model in
                self?.deliver(
                    self?.makeCallback(name: .rewardArrived, model: model, rewardStatus: true),
                    from: session,
                    handler: handler,
                    nextState: .showing,
                    finishSuccess: nil,
                    finishError: nil
                )
            },
            onAdClose: { [weak self] model, hasRewarded in
                self?.deliver(
                    self?.makeCallback(name: .close, model: model, rewardStatus: hasRewarded),
                    from: session,
                    handler: handler,
                    nextState: .idle,
                    finishSuccess: hasRewarded,
                    finishError: nil
                )
            }
        )
    }

    private func deliver(
        _ callback: LampsRewardCallback?,
        from session: LampsRewardSession,
        handler: LampsRewardEventHandler?,
        nextState: LampsRewardState?,
        finishSuccess: Bool?,
        finishError: Error?
    ) {
        if let callback {
            handler?(callback)
        }
        guard rewardSession === session else { return }
        guard let nextState else { return }
        state = nextState
        guard nextState == .idle else { return }

        let completion = closeCompletion
        closeCompletion = nil
        if let finishSuccess {
            completion?(finishSuccess, finishError)
        }
        DispatchQueue.main.async { [weak self] in
            guard let self, self.rewardSession === session else { return }
            self.rewardSession = nil
        }
    }

    private func makeCallback(
        name: LampsRewardCallbackName,
        model: LampsRewardAdModel? = nil,
        status: Bool = true,
        rewardStatus: Bool = false,
        code: Int = 0,
        message: String? = nil
    ) -> LampsRewardCallback {
        let callback = LampsRewardCallback()
        callback.name = name
        callback.status = status
        callback.rewardStatus = rewardStatus
        callback.errCode = code
        callback.errMessage = message
        callback.channelName = model?.channel.name ?? ""
        callback.slotId = model?.slotId ?? ""
        callback.price = model?.price ?? 0
        return callback
    }
}

/// 对外便捷入口。
@objcMembers
public final class LampsRewardAd: NSObject {
    @objc(showFromViewController:completion:)
    public static func show(from viewController: UIViewController, completion: LampsRewardCompletion?) {
        LampsRewardVideoManager.shared.start(from: viewController, handler: nil, completion: completion)
    }

    @objc(showFromViewController:handler:completion:)
    public static func show(
        from viewController: UIViewController,
        handler: LampsRewardEventHandler?,
        completion: LampsRewardCompletion?
    ) {
        LampsRewardVideoManager.shared.start(from: viewController, handler: handler, completion: completion)
    }

    public static func isAdapterAvailable(_ channel: LampsRewardChannel) -> Bool {
        LampsSDKAdapterCenter.isAvailable(channel)
    }
}
