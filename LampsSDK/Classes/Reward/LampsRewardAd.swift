import Foundation
import UIKit
import CoreGraphics

@objc enum LampsRewardCallbackName: Int {
    case busy = 0
    case reqError
    case loadSuccess
    case loadError
    case showSuccess
    case showError
    case rewardArrived
    case close

    /// H5 `hoorah.ad.rewardedVideoStatus` 的 callbackName。
    var h5CallbackName: String {
        switch self {
        case .busy: return "onBusy"
        case .reqError: return "onReqError"
        case .loadSuccess: return "onLoadSuccess"
        case .loadError: return "onLoadError"
        case .showSuccess: return "onShowSuccess"
        case .showError: return "onShowError"
        case .rewardArrived: return "onRewardArrived"
        case .close: return "onClose"
        }
    }
}

enum LampsRewardH5Error {
    static let allSDKLoadFailedCode = 2009
    static let allSDKLoadFailedMessage = "all reward ad SDKs failed to load"
}

@objcMembers
final class LampsRewardCallback: NSObject {
    var name: LampsRewardCallbackName = .busy
    var status: Bool = true
    var rewardStatus: Bool = false
    var errCode: Int = 0
    var errMessage: String?
    var channelName: String = ""
    var slotId: String = ""
    var price: CGFloat = 0
}

typealias LampsRewardEventHandler = (LampsRewardCallback) -> Void
typealias LampsRewardCompletion = (Bool, Error?) -> Void

enum LampsRewardState {
    case idle
    case requesting
    case showing

    var isActive: Bool { self != .idle }
}

/// 激励视频编排器（对齐 HCADCommonRewardVideoManager）。模块内部使用，不向宿主开放。
/// 入参使用 config.rewardAdSlots；并行请求已注册 Adapter，竞价后展示赢家。
@objcMembers
final class LampsRewardVideoManager: NSObject {
    static let shared = LampsRewardVideoManager()

    private var state: LampsRewardState = .idle
    private var rewardSession: LampsRewardSession?
    private var closeCompletion: LampsRewardCompletion?

    var isActive: Bool { state.isActive }

    /// 开始激励流程；生命周期事件通过 handler 回调。
    @objc(startFromViewController:handler:)
    func start(from viewController: UIViewController, handler: LampsRewardEventHandler?) {
        start(from: viewController, handler: handler, completion: nil)
    }

    /// 开始激励；`completion` 在 close / 失败结束时回调是否发奖。
    @objc(startFromViewController:handler:completion:)
    func start(
        from viewController: UIViewController,
        handler: LampsRewardEventHandler?,
        completion: LampsRewardCompletion?
    ) {
        start(from: viewController, forwardSource: nil, handler: handler, completion: completion)
    }

    @objc(startFromViewController:forwardSource:handler:completion:)
    func start(
        from viewController: UIViewController,
        forwardSource: String?,
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
        let session = LampsRewardSession(
            viewController: viewController,
            forwardSource: forwardSource ?? ""
        )
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
                    self?.makeCallback(
                        name: .loadError,
                        status: false,
                        code: LampsRewardH5Error.allSDKLoadFailedCode,
                        message: LampsRewardH5Error.allSDKLoadFailedMessage
                    ),
                    from: session,
                    handler: handler,
                    nextState: .idle,
                    finishSuccess: false,
                    finishError: LampsSDKError.api(LampsRewardH5Error.allSDKLoadFailedMessage).nsError
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

/// 激励便捷入口。仅 SDK 内部 / H5 Bridge 使用，不向宿主开放。
@objcMembers
final class LampsRewardAd: NSObject {
    @objc(showFromViewController:completion:)
    static func show(from viewController: UIViewController, completion: LampsRewardCompletion?) {
        LampsRewardVideoManager.shared.start(from: viewController, handler: nil, completion: completion)
    }

    @objc(showFromViewController:handler:completion:)
    static func show(
        from viewController: UIViewController,
        handler: LampsRewardEventHandler?,
        completion: LampsRewardCompletion?
    ) {
        show(from: viewController, forwardSource: nil, handler: handler, completion: completion)
    }

    @objc(showFromViewController:forwardSource:handler:completion:)
    static func show(
        from viewController: UIViewController,
        forwardSource: String?,
        handler: LampsRewardEventHandler?,
        completion: LampsRewardCompletion?
    ) {
        LampsRewardVideoManager.shared.start(
            from: viewController,
            forwardSource: forwardSource,
            handler: handler,
            completion: completion
        )
    }

    static func isAdapterAvailable(_ channel: LampsRewardChannel) -> Bool {
        LampsSDKAdapterCenter.isAvailable(channel)
    }
}
