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
    /// 流程：本地校验 → 读 config 磁盘缓存 → 初始化已注册广告 SDK → 请求 `/v1/lamps/config` → 回调。
    /// 配置接口失败时：有缓存则仍成功（继续用缓存）；无缓存则回调失败。
    /// 配置环境默认正式；测试环境请在 `LampsDevTools` 中切换。
    @objc(startWithConfig:completion:)
    public static func start(config: LampsSDKConfig, completion: LampsStartCompletion? = nil) {
        guard !config.appId.isEmpty else {
            let error = LampsSDKError.invalidConfig("appId 不能为空").nsError
            LampsSDKLog.debug("start failed: \(error.localizedDescription)")
            completion?(false, error)
            return
        }
        storedConfig = config.copy() as? LampsSDKConfig
        let environment = LampsEnvironmentStore.current
        storedRemoteConfig = LampsConfigCache.load(
            appId: config.appId,
            environment: environment
        )
        started = true
        LampsSDKLog.debug(
            "started local, appId=\(config.appId) env=\(environment.logName) cache=\(storedRemoteConfig != nil)"
        )
        LampsDeviceInfo.prepareUserAgentIfNeeded()

        guard let effective = storedConfig else {
            completion?(true, nil)
            return
        }

        LampsSDKAdapterCenter.initializeSDKs(config: effective) {
            applyRemoteConfigFetch(config: effective, completion: completion)
        }
    }

    public static var isStarted: Bool {
        started
    }

    /// 当前生效配置；未启动时为 nil。
    public static var config: LampsSDKConfig? {
        storedConfig
    }

    /// 远端配置；未拉取成功时为 nil。仅 SDK 内部使用。
    static var remoteConfig: LampsRemoteConfig? {
        storedRemoteConfig
    }

    /// REM 签名用 key：配置接口返回的 `token`。仅 SDK 内部使用。
    static var effectiveRewardSignKey: String {
        storedRemoteConfig?.token ?? ""
    }

    /// 当前配置环境。宿主普通 import 不可见。
    @_spi(LampsDevTools)
    public static var debugEnvironment: LampsSDKEnvironment {
        LampsEnvironmentStore.current
    }

    /// 切换配置环境：写入本机记忆，并按新环境读缓存、重新请求配置。
    @_spi(LampsDevTools)
    public static func debugSwitchEnvironment(
        _ environment: LampsSDKEnvironment,
        completion: LampsStartCompletion? = nil
    ) {
        LampsEnvironmentStore.current = environment
        LampsSDKLog.debug("switch env=\(environment.logName)")
        guard started, let config = storedConfig else {
            storedRemoteConfig = nil
            LampsSDKLog.debug("switch env saved, waiting for start")
            completion?(true, nil)
            return
        }
        storedRemoteConfig = LampsConfigCache.load(
            appId: config.appId,
            environment: environment
        )
        applyRemoteConfigFetch(config: config, completion: completion)
    }

    /// 清除当前环境的 Config 磁盘缓存。宿主普通 import 不可见。
    @_spi(LampsDevTools)
    public static func debugClearConfigCache() -> Bool {
        guard let appId = storedConfig?.appId else { return false }
        return LampsConfigCache.clear(appId: appId, environment: LampsEnvironmentStore.current)
    }

    /// 调试页展示用，宿主普通 import 不可见。
    @_spi(LampsDevTools)
    public static var debugStatusText: String {
        let config = storedConfig
        let remote = storedRemoteConfig
        let slots = remote?.rewardAdSlots.map { "\($0.channelName)/\($0.slotId)" }.joined(separator: ", ") ?? "-"
        return """
        sdkVersion: \(sdkVersion)
        started: \(started)
        appId: \(config?.appId ?? "-")
        env: \(LampsEnvironmentStore.current.logName)
        debugLog: \(config?.debugLogEnabled ?? false)
        remoteConfig: \(remote == nil ? "nil" : "ok")
        tokenLen: \(remote?.token.count ?? 0)
        clientIp: \(remote?.clientIp ?? "-")
        slots(\(remote?.rewardAdSlots.count ?? 0)): \(slots)
        """
    }

    private static func applyRemoteConfigFetch(
        config: LampsSDKConfig,
        completion: LampsStartCompletion?
    ) {
        LampsConfigService.fetch(config: config) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let remote):
                    storedRemoteConfig = remote
                    LampsSDKLog.debug("config fetch ok env=\(LampsEnvironmentStore.current.logName)")
                    completion?(true, nil)
                case .failure(let error):
                    if storedRemoteConfig != nil {
                        LampsSDKLog.debug(
                            "config fetch failed keep cache: \(error.localizedDescription)"
                        )
                        completion?(true, nil)
                    } else {
                        LampsSDKLog.debug(
                            "config fetch failed and no cache: \(error.localizedDescription)"
                        )
                        completion?(false, error)
                    }
                }
            }
        }
    }
}
