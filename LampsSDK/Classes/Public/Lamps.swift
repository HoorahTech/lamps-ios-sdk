import Foundation
import UIKit

/// SDK 启动完成回调，在主线程调用。
/// - Parameters:
///   - success: 是否已具备可用配置。远端失败但本地有缓存时仍为 `true`。
///   - error: 失败原因，`domain` 为 `LampsSDKErrorDomain`，`code` 见 `LampsSDKErrorCode`。
public typealias LampsStartCompletion = (Bool, Error?) -> Void

/// Lamps SDK 入口。接入方 `import LampsSDK` 后先 `start`，再 `showGameCent   er(from:)` 打开游戏中心，或 `makeGameCenterView()` 嵌入页面。
/// 类名不用 `LampsSDK`，避免与模块名冲突。
@objcMembers
public final class Lamps: NSObject {
    /// 当前 SDK 版本号。
    public static let sdkVersion = "0.0.1"

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

    /// 打开配置下发的游戏中心页。请先 `start` 成功。
    ///
    /// 参数可以是 `UINavigationController`，也可以是栈内任意页面：有导航栈则 `push`，否则全屏 `present`。
    /// - Returns: 已发起跳转为 `true`；未 start、地址为空或 URL 不合法为 `false`。
    @discardableResult
    @objc(showGameCenterFromViewController:)
    public static func showGameCenter(from viewController: UIViewController) -> Bool {
        guard let urlString = resolvedGameCenterPageURL() else { return false }
        let page = LampsWebViewController(urlString: urlString)
        pushOrPresent(page, from: viewController)
        return true
    }

    /// 使用配置下发的 `gameCenterPage` 创建可内嵌视图。请先 `start` 成功。
    /// 返回的是内部 WebView，类型对外为 `UIView`。地址不可用时返回 `nil`。
    /// 请由宿主加入自己的视图层级并设置约束。
    @objc(makeGameCenterView)
    public static func makeGameCenterView() -> UIView? {
        guard let urlString = resolvedGameCenterPageURL() else { return nil }
        let webView = LampsWebView()
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        guard webView.load(urlString: urlString) else { return nil }
        return webView
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
        [debugBasicStatusText, debugConfigStatusText].joined(separator: "\n")
    }

    /// 调试页「基本信息」分区。仅调试工具使用。
    @_spi(LampsDevTools)
    @nonobjc
    public static var debugBasicStatusText: String {
        let config = storedConfig
        return """
        sdkVersion: \(sdkVersion)
        started: \(started)
        appId: \(config?.appId ?? "-")
        env: \(LampsEnvironmentStore.current.logName)
        debugLog: \(config?.debugLogEnabled ?? false)
        """
    }

    /// 调试页「全局配置」分区。仅调试工具使用。
    @_spi(LampsDevTools)
    @nonobjc
    public static var debugConfigStatusText: String {
        let config = storedConfig
        let remote = storedRemoteConfig
        let slots = remote?.rewardAdSlots.map { "\($0.channelName)/\($0.slotId)" }.joined(separator: ", ") ?? "-"
        let channels = remote?.channelList.map { "\($0.channelId)/\($0.channelAppId)" }.joined(separator: ", ") ?? "-"
        let gameCenter = remote?.gameCenterPage ?? ""
        return """
        remoteConfig: \(remote == nil ? "nil" : "ok")
        tokenLen: \(remote?.token.count ?? 0)
        clientIp: \(remote?.clientIp ?? "-")
        channels(\(remote?.channelList.count ?? 0)): \(channels)
        slots(\(remote?.rewardAdSlots.count ?? 0)): \(slots)
        gameCenterPage: \(gameCenter.isEmpty ? "-" : gameCenter)
        personalizedRecommend: \(config?.personalizedRecommendEnabled ?? true)
        shakeAds: \(config?.shakeAdsEnabled ?? true)
        allowLocation: \(config?.allowLocation ?? false)
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

    private static func resolvedGameCenterPageURL() -> String? {
        let url = storedRemoteConfig?.gameCenterPage.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard started else {
            LampsSDKLog.debug("gameCenterPage skipped: not started")
            return nil
        }
        guard !url.isEmpty, LampsWebView.makeURL(from: url) != nil else {
            LampsSDKLog.debug("gameCenterPage unavailable url=\(url)")
            return nil
        }
        return url
    }

    /// 有导航栈则 `push`，否则全屏 `present`。游戏中心与游戏页共用。
    static func pushOrPresent(_ page: UIViewController, from host: UIViewController) {
        if let nav = host as? UINavigationController {
            nav.pushViewController(page, animated: true)
        } else if let nav = host.navigationController {
            nav.pushViewController(page, animated: true)
        } else {
            page.modalPresentationStyle = .fullScreen
            host.present(page, animated: true)
        }
    }
}
