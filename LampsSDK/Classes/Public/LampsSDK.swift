import Foundation

public typealias LampsSDKStartCompletion = (Bool, Error?) -> Void

/// 对外总入口。宿主 `import LampsSDK` 后调用 `LampsSDK.start(config:completion:)`。
@objcMembers
public final class LampsSDK: NSObject {
    private static var storedConfig: LampsSDKConfig?
    private static var storedRemoteConfig: LampsRemoteConfig?
    private static var started = false

    /// 启动 SDK。
    /// 流程：本地校验 → 初始化已注册广告 SDK → 请求 `/v1/lamps/config` → 回调。
    /// 配置接口失败时仍视为启动成功（`success=true`），可从 `remoteConfig` 判断是否拉到配置。
    @objc(startWithConfig:completion:)
    public static func start(config: LampsSDKConfig, completion: LampsSDKStartCompletion? = nil) {
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
                        if !remote.token.isEmpty, let cfg = storedConfig, cfg.rewardSignKey.isEmpty {
                            cfg.rewardSignKey = remote.token
                        }
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

    /// REM 签名用 key：优先本地 `rewardSignKey`，否则用远端 `token`。
    static var effectiveRewardSignKey: String {
        if let key = storedConfig?.rewardSignKey, !key.isEmpty {
            return key
        }
        return storedRemoteConfig?.token ?? ""
    }
}
