import Foundation

public typealias LampsStartCompletion = (Bool, Error?) -> Void

/// 对外总入口。宿主 `import LampsSDK` 后调用 `Lamps.start(config:completion:)`。
/// 类名刻意不用 `LampsSDK`，避免与模块名同名导致 `.swiftinterface` 解析冲突。
@objcMembers
public final class Lamps: NSObject {
    /// 与 `LampsSDK.podspec` 的 `s.version` 保持一致。
    public static let sdkVersion = "0.1.0"

    private static var storedConfig: LampsSDKConfig?
    private static var storedRemoteConfig: LampsRemoteConfig?
    private static var started = false

    /// 启动 SDK。
    /// 流程：本地校验 → 初始化已注册广告 SDK → 请求 `/v1/lamps/config` → 回调。
    /// 配置接口失败时仍视为启动成功（`success=true`），可从 `remoteConfig` 判断是否拉到配置。
    @objc(startWithConfig:completion:)
    public static func start(config: LampsSDKConfig, completion: LampsStartCompletion? = nil) {
        guard !config.appId.isEmpty else {
            let error = LampsSDKError.invalidConfig("appId 不能为空").nsError
            LampsSDKLog.debug("start failed: \(error.localizedDescription)")
            completion?(false, error)
            return
        }
        storedConfig = config.copy() as? LampsSDKConfig
        storedRemoteConfig = nil
        started = true
        LampsSDKLog.debug("started local, appId=\(config.appId) env=\(config.environment.rawValue)")
        LampsDeviceInfo.prepareUserAgentIfNeeded()

        guard let effective = storedConfig else {
            completion?(true, nil)
            return
        }

        LampsSDKAdapterCenter.initializeSDKs(config: effective) {
            LampsConfigService.fetch(config: effective) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let remote):
                        storedRemoteConfig = remote
                        LampsSDKLog.debug("start finished with remote config")
                    case .failure(let error):
                        LampsSDKLog.debug("start finished, config failed: \(error.localizedDescription)")
                    }
                    completion?(true, nil)
                }
            }
        }
    }

    public static var isStarted: Bool {
        started
    }

    /// 当前生效配置；未启动时为 nil。
    public static var config: LampsSDKConfig? {
        storedConfig
    }

    /// 远端配置；未拉取成功时为 nil。
    public static var remoteConfig: LampsRemoteConfig? {
        storedRemoteConfig
    }

    /// REM 签名用 key：配置接口返回的 `token`。
    static var effectiveRewardSignKey: String {
        storedRemoteConfig?.token ?? ""
    }
}
