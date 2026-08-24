import Foundation

typealias LampsBridgeToH5Callback = ([AnyHashable: Any]) -> Void

/// 一组业务 Bridge。导航、激励视频等各自实现，由 `LampsBridge` 按 method 分发。不对外暴露。
@objc protocol LampsBridgeHandler: AnyObject {
    var bridge: LampsBridge? { get set }

    /// 该 Handler 负责的方法名。
    var supportedMethods: [String] { get }

    /// 处理 H5 调用。success / error 是本次调用的回调，不需要注册。
    func handle(
        method: String,
        data: [AnyHashable: Any],
        success: LampsBridgeToH5Callback?,
        error: LampsBridgeToH5Callback?
    )
}
