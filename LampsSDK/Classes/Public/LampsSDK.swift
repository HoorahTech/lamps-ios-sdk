import Foundation

public typealias LampsSDKStartCompletion = (Bool, Error?) -> Void

/// 对外总入口。宿主 `import LampsSDK` 后调用 `LampsSDK.start(config:completion:)`。
@objcMembers
public final class LampsSDK: NSObject {
    private static var storedConfig: LampsSDKConfig?
    private static var started = false

    /// 启动 SDK。应在使用 Web / 激励视频 / 上报之前调用。
    @objc(startWithConfig:completion:)
    public static func start(config: LampsSDKConfig, completion: LampsSDKStartCompletion? = nil) {
        guard !config.appId.isEmpty else {
            let error = LampsSDKError.invalidConfig("appId 不能为空").nsError
            LampsSDKLog.debug("start failed: \(error.localizedDescription)")
            completion?(false, error)
            return
        }
        storedConfig = config.copy() as? LampsSDKConfig
        started = true
        LampsSDKLog.debug("started, appId=\(config.appId)")
        completion?(true, nil)
    }

    public static var isStarted: Bool {
        started
    }

    /// 当前生效配置；未启动时为 nil。
    public static var config: LampsSDKConfig? {
        storedConfig
    }
}
