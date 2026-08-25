import Foundation

/// SDK 启动完成回调，在主线程调用。
/// - Parameters:
///   - success: 是否已具备可用配置。远端失败但本地有缓存时仍为 `true`。
///   - error: 失败原因，`domain` 为 `LampsSDKErrorDomain`，`code` 见 `LampsSDKErrorCode`。
public typealias LampsStartCompletion = (Bool, Error?) -> Void

/// Lamps SDK 入口。接入方 `import LampsSDK` 后调用 `start`，再用 `LampsWebViewController` 打开活动页。
/// 类名不用 `LampsSDK`，避免与模块名冲突。
@objcMembers
public final class Lamps: NSObject {
    /// 当前 SDK 版本号。
    public static let sdkVersion = "0.1.0"

    private static var storedConfig: LampsSDKConfig?
    private static var storedRemoteConfig: LampsRemoteConfig?
    private static var started = false
    private static var didInitializeAdSDKs = false

    /// 启动 SDK。请在打开活动页之前调用，重复调用不会重新初始化广告 SDK。
    ///
    /// 会校验 `appId`、读取本地配置缓存并请求远端配置，再按配置初始化已接入的广告 SDK。
    /// 配置请求失败时：有磁盘缓存则仍回调成功并继续使用缓存；无缓存则回调失败。
    /// 默认正式环境；测试环境请用 `LampsDevTools` 切换。
    ///
    /// - Parameters:
    ///   - config: 初始化配置，`appId` 必填。SDK 会拷贝一份，之后修改原对象不会生效。
    ///   - completion: 启动完成回调，主线程。
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
        applyRemoteConfigFetch(config: effective, completion: completion)
    }

    /// 是否已调用过 `start`。
    public static var isStarted: Bool {
        started
    }

    /// 最近一次 `start` 使用的配置；尚未启动时为 `nil`。
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

    /// 当前配置环境。仅调试工具使用。
    @_spi(LampsDevTools)
    @nonobjc
    public static var debugEnvironment: LampsSDKEnvironment {
        LampsEnvironmentStore.current
    }

    /// 切换配置环境：写入本机记忆，并按新环境读缓存、重新请求配置。仅调试工具使用。
    @_spi(LampsDevTools)
    @nonobjc
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

    /// 清除当前环境的 Config 磁盘缓存。仅调试工具使用。
    @_spi(LampsDevTools)
    @nonobjc
    public static func debugClearConfigCache() -> Bool {
        guard let appId = storedConfig?.appId else { return false }
        return LampsConfigCache.clear(appId: appId, environment: LampsEnvironmentStore.current)
    }

    /// 调试页状态文案。仅调试工具使用。
    @_spi(LampsDevTools)
    @nonobjc
    public static var debugStatusText: String {
        let config = storedConfig
        let remote = storedRemoteConfig
        let slots = remote?.rewardAdSlots.map { "\($0.channelName)/\($0.slotId)" }.joined(separator: ", ") ?? "-"
        let channels = remote?.channelList.map { "\($0.channelId)/\($0.channelAppId)" }.joined(separator: ", ") ?? "-"
        return """
        sdkVersion: \(sdkVersion)
        started: \(started)
        appId: \(config?.appId ?? "-")
        env: \(LampsEnvironmentStore.current.logName)
        debugLog: \(config?.debugLogEnabled ?? false)
        remoteConfig: \(remote == nil ? "nil" : "ok")
        tokenLen: \(remote?.token.count ?? 0)
        clientIp: \(remote?.clientIp ?? "-")
        channels(\(remote?.channelList.count ?? 0)): \(channels)
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
                    initializeAdSDKsIfNeeded(config: config) {
                        completion?(true, nil)
                    }
                case .failure(let error):
                    if storedRemoteConfig != nil {
                        LampsSDKLog.debug(
                            "config fetch failed keep cache: \(error.localizedDescription)"
                        )
                        initializeAdSDKsIfNeeded(config: config) {
                            completion?(true, nil)
                        }
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

    private static func initializeAdSDKsIfNeeded(config: LampsSDKConfig, completion: @escaping () -> Void) {
        if didInitializeAdSDKs {
            completion()
            return
        }
        didInitializeAdSDKs = true
        LampsSDKAdapterCenter.initializeSDKs(config: config, completion: completion)
    }
}
