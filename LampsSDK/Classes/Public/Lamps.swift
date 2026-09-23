import Foundation
import UIKit

/// SDK 启动完成回调，在主线程调用。
/// - Parameters:
///   - success: 是否已具备可用配置。远端失败但本地有缓存时仍为 `true`。
///   - error: 失败原因，`domain` 为 `LampsSDKErrorDomain`，`code` 见 `LampsSDKErrorCode`。
public typealias LampsStartCompletion = (Bool, Error?) -> Void

/// 打开游戏中心结果回调。
/// - Parameters:
///   - success: 已发起跳转为 `true`。
///   - error: 失败原因，`domain` 为 `LampsSDKErrorDomain`，`code` 见 `LampsSDKErrorCode`。
public typealias LampsShowGameCenterCompletion = (Bool, Error?) -> Void

/// Lamps SDK 入口。接入方 `import LampsSDK` 后先 `start`，再 `showGameCenter(from:)` 打开游戏中心，`showGame(gameId:)` 打开具体游戏，或 `makeGameCenterView()` 嵌入 `LampsGameCenterView`。
/// 类名不用 `LampsSDK`，避免与模块名冲突。
@objcMembers
public final class Lamps: NSObject {
    /// 当前 SDK 版本号。
    public static let sdkVersion = "0.0.5"

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

    /// 在宿主导航栈中打开游戏中心。请先 `start` 成功。
    ///
    /// 当前页有导航栈则 `push`，否则全屏 `present`。关闭由 H5 触发，或调用页内关闭。
    /// 若希望独立全屏打开、不进入宿主导航栈，请用 `presentGameCenter`。
    ///
    /// - Parameters:
    ///   - viewController: 起始页面，可不传；未传时 SDK 取当前最上层页面。
    ///   - config: 本次展示配置；不传则用 `LampsSDKConfig` 中的对应字段。
    ///   - completion: 打开结果。失败时 `error` 的 `domain` 为 `LampsSDKErrorDomain`，`code` 见 `LampsSDKErrorCode`。
    @objc(showGameCenterFromViewController:config:completion:)
    public static func showGameCenter(
        from viewController: UIViewController? = nil,
        config: LampsGameCenterConfig? = nil,
        completion: LampsShowGameCenterCompletion? = nil
    ) {
        switch prepareGameCenter(from: viewController, config: config) {
        case .ready(let host, let page):
            LampsNavigator.pushOrPresent(page, from: host)
            completion?(true, nil)
        case .failure(let error):
            completeGameCenter(error, completion: completion)
        }
    }

    /// 全屏打开游戏中心，不进入宿主导航栈。请先 `start` 成功。
    ///
    /// SDK 会用自有导航容器 present，系统导航栏默认隐藏。从游戏中心再打开具体游戏时，仍在该容器内跳转。
    ///
    /// - Parameters:
    ///   - viewController: 起始页面，可不传；未传时 SDK 取当前最上层页面。
    ///   - config: 本次展示配置；不传则用 `LampsSDKConfig` 中的对应字段。
    ///   - completion: 打开结果。失败时 `error` 的 `domain` 为 `LampsSDKErrorDomain`，`code` 见 `LampsSDKErrorCode`。
    @objc(presentGameCenterFromViewController:config:completion:)
    public static func presentGameCenter(
        from viewController: UIViewController? = nil,
        config: LampsGameCenterConfig? = nil,
        completion: LampsShowGameCenterCompletion? = nil
    ) {
        switch prepareGameCenter(from: viewController, config: config) {
        case .ready(let host, let page):
            LampsNavigator.presentInNavigationController(page, from: host)
            completion?(true, nil)
        case .failure(let error):
            completeGameCenter(error, completion: completion)
        }
    }

    /// 在宿主导航栈中打开具体游戏页。请先 `start` 成功。
    ///
    /// 使用配置下发的 `gamePageUrl`，将链接中的 `__GAMEID__` 替换为 `gameId` 后加载。
    /// 当前页有导航栈则 `push`，否则全屏 `present`。容器为 `LampsGameWebViewController`。
    /// 若希望独立全屏打开、不进入宿主导航栈，请用 `presentGame`。
    ///
    /// - Parameters:
    ///   - gameId: 游戏 ID，替换 `gamePageUrl` 中的 `__GAMEID__`。
    ///   - viewController: 起始页面，可不传；未传时 SDK 取当前最上层页面。
    ///   - completion: 打开结果。失败时 `error` 的 `domain` 为 `LampsSDKErrorDomain`，`code` 见 `LampsSDKErrorCode`。
    @objc(showGameWithGameId:fromViewController:completion:)
    public static func showGame(
        gameId: String,
        from viewController: UIViewController? = nil,
        completion: LampsShowGameCenterCompletion? = nil
    ) {
        switch prepareGamePage(gameId: gameId, from: viewController) {
        case .ready(let host, let page):
            LampsNavigator.pushOrPresent(page, from: host)
            completion?(true, nil)
        case .failure(let error):
            completeGame(error, completion: completion)
        }
    }

    /// 全屏打开具体游戏页，不进入宿主导航栈。请先 `start` 成功。
    ///
    /// 使用配置下发的 `gamePageUrl`，将链接中的 `__GAMEID__` 替换为 `gameId` 后加载。
    /// SDK 会用自有导航容器 present，系统导航栏默认隐藏。
    ///
    /// - Parameters:
    ///   - gameId: 游戏 ID，替换 `gamePageUrl` 中的 `__GAMEID__`。
    ///   - viewController: 起始页面，可不传；未传时 SDK 取当前最上层页面。
    ///   - completion: 打开结果。失败时 `error` 的 `domain` 为 `LampsSDKErrorDomain`，`code` 见 `LampsSDKErrorCode`。
    @objc(presentGameWithGameId:fromViewController:completion:)
    public static func presentGame(
        gameId: String,
        from viewController: UIViewController? = nil,
        completion: LampsShowGameCenterCompletion? = nil
    ) {
        switch prepareGamePage(gameId: gameId, from: viewController) {
        case .ready(let host, let page):
            LampsNavigator.presentInNavigationController(page, from: host)
            completion?(true, nil)
        case .failure(let error):
            completeGame(error, completion: completion)
        }
    }

    /// 使用配置下发的 `gameCenterPage` 创建可内嵌视图。请先 `start` 成功。
    /// 返回 `LampsGameCenterView`；地址不可用时返回 `nil`。
    /// 请由宿主加入自己的视图层级并设置约束。
    /// 宿主自有日夜间变化时调用 `updateDayNightMode`，无需重建本视图。
    /// 从该视图内再打开具体游戏时，SDK 会全屏 present，不进入宿主导航栈。
    ///
    /// - Parameter config: 本次展示配置；不传则用 `LampsSDKConfig` 中的对应字段。
    @objc(makeGameCenterViewWithConfig:)
    public static func makeGameCenterView(config: LampsGameCenterConfig? = nil) -> LampsGameCenterView? {
        guard let urlString = resolvedGameCenterPageURL(
            dayNightMode: resolvedDayNightMode(config?.dayNightMode)
        ) else { return nil }
        let webView = LampsWebView(
            displayMode: LampsBridgeClientInfo.DisplayMode.embed,
            dayNightMode: resolvedDayNightMode(config?.dayNightMode)
        )
        guard webView.load(urlString: urlString) else { return nil }
        return LampsGameCenterView(webView: webView)
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
        dayNight: \(config?.dayNightMode.logName ?? "-")
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
        let gamePage = remote?.gamePlayPageTemplate ?? ""
        return """
        remoteConfig: \(remote == nil ? "nil" : "ok")
        tokenLen: \(remote?.token.count ?? 0)
        clientIp: \(remote?.clientIp ?? "-")
        channels(\(remote?.channelList.count ?? 0)): \(channels)
        slots(\(remote?.rewardAdSlots.count ?? 0)): \(slots)
        gameCenterPage: \(gameCenter.isEmpty ? "-" : gameCenter)
        gamePageUrl: \(gamePage.isEmpty ? "-" : gamePage)
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

    /// 只负责解析地址和宿主，不跳转、不回调。
    private static func prepareGameCenter(
        from viewController: UIViewController?,
        config: LampsGameCenterConfig?
    ) -> GameCenterPrepareResult {
        switch resolveGameCenterPageURL(dayNightMode: resolvedDayNightMode(config?.dayNightMode)) {
        case .success(let url):
            guard let host = viewController ?? LampsNavigator.currentHostViewController() else {
                return .failure(.noHostViewController("找不到可用于打开游戏中心的页面"))
            }
            let page = LampsWebViewController(urlString: url)
            page.displayMode = LampsBridgeClientInfo.DisplayMode.page
            page.dayNightMode = resolvedDayNightMode(config?.dayNightMode)
            return .ready(host: host, page: page)
        case .failure(let error):
            return .failure(error)
        }
    }

    /// 本次展示配置优先，否则用初始化配置，默认日间。
    static func resolvedDayNightMode(_ mode: LampsDayNightMode?) -> LampsDayNightMode {
        mode ?? storedConfig?.dayNightMode ?? .day
    }

    private static func completeGameCenter(
        _ error: LampsSDKError,
        completion: LampsShowGameCenterCompletion?
    ) {
        let nsError = error.nsError
        LampsSDKLog.debug("showGameCenter failed: \(nsError.localizedDescription)")
        completion?(false, nsError)
    }

    /// 只负责解析游戏页地址和宿主，不跳转、不回调。
    private static func prepareGamePage(
        gameId: String,
        from viewController: UIViewController?
    ) -> GamePagePrepareResult {
        switch resolveGamePageURL(gameId: gameId) {
        case .success(let url):
            guard let host = viewController ?? LampsNavigator.currentHostViewController() else {
                return .failure(.noHostViewController("找不到可用于打开游戏页的页面"))
            }
            return .ready(host: host, page: LampsGameWebViewController(urlString: url))
        case .failure(let error):
            return .failure(error)
        }
    }

    private static func completeGame(
        _ error: LampsSDKError,
        completion: LampsShowGameCenterCompletion?
    ) {
        let nsError = error.nsError
        LampsSDKLog.debug("showGame failed: \(nsError.localizedDescription)")
        completion?(false, nsError)
    }

    private static func resolvedGameCenterPageURL(dayNightMode: LampsDayNightMode) -> String? {
        switch resolveGameCenterPageURL(dayNightMode: dayNightMode) {
        case .success(let url):
            return url
        case .failure:
            return nil
        }
    }

    private static func resolveGameCenterPageURL(dayNightMode: LampsDayNightMode) -> GameCenterPageResult {
        guard started else {
            LampsSDKLog.debug("gameCenterPage skipped: not started")
            return .failure(.notStarted("尚未调用 Lamps.start"))
        }
        let url = storedRemoteConfig?.gameCenterPage.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !url.isEmpty, LampsWebView.makeURL(from: url) != nil else {
            LampsSDKLog.debug("gameCenterPage unavailable url=\(url)")
            return .failure(.gameCenterUnavailable("游戏中心地址不可用"))
        }
        let separator = url.contains("?") ? "&" : "?"
        return .success(url + separator + "night=\(dayNightMode.bridgeNightValue)")
    }

    private static func resolveGamePageURL(gameId: String) -> GameCenterPageResult {
        guard started else {
            LampsSDKLog.debug("gamePageUrl skipped: not started")
            return .failure(.notStarted("尚未调用 Lamps.start"))
        }
        let trimmedId = gameId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedId.isEmpty else {
            LampsSDKLog.debug("gamePageUrl skipped: empty gameId")
            return .failure(.invalidConfig("gameId 不能为空"))
        }
        let template = storedRemoteConfig?.gamePlayPageTemplate.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let url = template.replacingOccurrences(of: "__GAMEID__", with: trimmedId)
        guard !url.isEmpty, LampsWebView.makeURL(from: url) != nil else {
            LampsSDKLog.debug("gamePageUrl unavailable url=\(url)")
            return .failure(.gamePageUnavailable("游戏页地址不可用"))
        }
        return .success(url)
    }
}

private enum GameCenterPageResult {
    case success(String)
    case failure(LampsSDKError)
}

private enum GameCenterPrepareResult {
    case ready(host: UIViewController, page: LampsWebViewController)
    case failure(LampsSDKError)
}

private enum GamePagePrepareResult {
    case ready(host: UIViewController, page: LampsGameWebViewController)
    case failure(LampsSDKError)
}
