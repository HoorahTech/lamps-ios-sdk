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
    public static let sdkVersion = "1.0.2"

    /// 支付宝支付回跳 Scheme。宿主写入 Info.plist 的 `CFBundleURLSchemes`，不要带 `://`。
    /// 这个值由 SDK 固定，不通过 `LampsSDKConfig` 设置。
    public static let alipayURLScheme = "lampsalipay"

    /// 埋点回调。`access` / `click` / `exposure` 都在 SDK 自行上报之前于主线程调用。
    ///
    /// 请在主线程设置。回调与 SDK 自己的 `/api/v1/event/report` 并行，不表示服务端已收到。
    /// 未设置时只走 SDK 自己的上报。回调里不要做耗时操作。
    public static var trackHandler: LampsTrackHandler?

    /// 游戏中心 / 游戏行为回传。页面视图加载时回传打开成功，页面真正关闭时回传退出，都在主线程调用。
    ///
    /// 参数是 `LampsBehavior`：`event`、`pageType`、`data`、`trackParams`。
    /// 请在主线程设置。未设置时不回调。回调里不要做耗时操作。
    /// ObjC 请用 `setBehaviorHandler:`。
    /// `@nonobjc`：避免和下面的 `setBehaviorHandler:` 抢同一个 Objective-C setter。
    @nonobjc
    public static var behaviorHandler: LampsBehaviorHandler?

    /// ObjC 设置行为回传。传 `nil` 清除。Swift 请直接设置 `behaviorHandler`。
    @objc(setBehaviorHandler:)
    public static func setBehaviorHandler(_ handler: ((LampsBehavior) -> Void)?) {
        behaviorHandler = handler
    }

    /// ObjC 取埋点事件名。Swift 用 `event.name`。
    @objc(behaviorNameForEvent:)
    public static func behaviorName(for event: LampsBehaviorEvent) -> String {
        event.name
    }

    /// ObjC 取页面类型文案。Swift 用 `pageType.name`。
    @objc(behaviorPageTypeNameForPageType:)
    public static func behaviorPageTypeName(for pageType: LampsBehaviorPageType) -> String {
        pageType.name
    }

    private static var storedConfig: LampsSDKConfig?
    private static var storedRemoteConfig: LampsRemoteConfig?
    private static var storedUserInfo: LampsUserInfo?
    /// 最近一次 Config 接口成功时间。失败不更新；没有成功记录时视为过期。
    private static var configUpdatedAt: Date?
    /// Config 请求进行中。`start`、切环境和进游戏容器共用，避免并发重入。
    private static var isFetchingConfig = false
    /// 未下发 `autoReloadTime` 时的 Config 刷新间隔。
    private static let defaultConfigRefreshInterval: TimeInterval = 5 * 60
    /// 进游戏容器时，距上次成功超过该间隔才再请求。优先用配置下发的 `autoReloadTime`（秒）。
    private static var configRefreshInterval: TimeInterval {
        let interval = storedRemoteConfig?.autoReloadTime ?? defaultConfigRefreshInterval
        return interval > 0 ? interval : defaultConfigRefreshInterval
    }
    private static var started = false
    private static var didInitializeAdSDKs = false

    /// 启动 SDK。请在打开活动页之前调用，重复调用不会重新初始化广告 SDK。
    ///
    /// 会校验 `appId`、读取本地配置缓存并请求远端配置，再按 `initializeCSJEnabled` / `initializeYlhEnabled` / `initializeNoahEnabled` 初始化已接入的广告 SDK。
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
            LampsSDKLog.debug("start failed: \(error.localizedDescription)", category: .startup)
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
            "started local, appId=\(config.appId) env=\(environment.logName) cache=\(storedRemoteConfig != nil)",
            category: .startup
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

    /// 传入当前登录用户。可重复调用覆盖。SDK 会拷贝一份，之后修改原对象不会生效。
    ///
    /// 只保存在内存中。`bridgeReady` 用 `userId` / `nickname` / `avatar` 回传 `uid` / `nickname` / `avatar`。
    /// 退出登录请调用 `clearUserInfo`。请在主线程调用。
    @objc(setUserInfo:)
    public static func setUserInfo(_ userInfo: LampsUserInfo) {
        let copy = LampsUserInfo()
        copy.userId = userInfo.userId
        copy.nickname = userInfo.nickname
        copy.avatar = userInfo.avatar
        storedUserInfo = copy
        LampsSDKLog.debug(
            "set user idLen=\(copy.userId.count) nickLen=\(copy.nickname.count) avatarLen=\(copy.avatar.count)"
        )
    }

    /// 清除当前用户。之后 `bridgeReady` 的 `uid` / `nickname` / `avatar` 为空。请在主线程调用。
    @objc(clearUserInfo)
    public static func clearUserInfo() {
        storedUserInfo = nil
        LampsSDKLog.debug("clear user")
    }

    /// 把支付宝 App 支付回跳交给 SDK。请在 `application(_:open:options:)` 或 Scene 的 `openURLContexts` 里调用，宿主不用判断 Scheme。
    ///
    /// 仅当 `url.scheme` 为 `alipayURLScheme`、`url.host` 为 `safepay`，且存在进行中的 `lamps.thirdPartyPay.order` 时返回 `true`。
    /// 内部以空的 standbyCallback 调用支付宝，结果回到本次 Bridge 回调。
    /// 返回 `false` 时，宿主继续处理自己的 URL，包括宿主自己的支付宝支付。
    @discardableResult
    @objc(handleOpenURL:)
    public static func handleOpenURL(_ url: URL) -> Bool {
        LampsAlipayPay.handleOpenURL(url)
    }

    /// 在宿主导航栈中打开游戏中心。请先 `start` 成功。
    ///
    /// 当前页有导航栈则 `push`，否则全屏 `present`。关闭由 H5 触发，或调用页内关闭。
    /// 若希望独立全屏打开、不进入宿主导航栈，请用 `presentGameCenter`。
    ///
    /// - Parameters:
    ///   - viewController: 起始页面，可不传；未传时 SDK 取当前最上层页面。
    ///   - config: 本次展示配置。`urlQuery` 拼到游戏中心链接上，`trackParams` 并入后续行为回传。不传则用 `LampsSDKConfig` 中的对应字段。
    ///   - completion: 打开结果。失败时 `error` 的 `domain` 为 `LampsSDKErrorDomain`，`code` 见 `LampsSDKErrorCode`。
    @objc(showGameCenterFromViewController:config:completion:)
    public static func showGameCenter(
        from viewController: UIViewController? = nil,
        config: LampsGameCenterConfig? = nil,
        completion: LampsShowGameCenterCompletion? = nil
    ) {
        let trackParams = sanitizedTrackParams(config?.trackParams)
        switch prepareGameCenter(from: viewController, config: config, trackParams: trackParams) {
        case .ready(let host, let page):
            LampsNavigator.pushOrPresent(page, from: host)
            completion?(true, nil)
        case .failure(let error):
            completeGameCenter(error, trackParams: trackParams, completion: completion)
        }
    }

    /// 全屏打开游戏中心，不进入宿主导航栈。请先 `start` 成功。
    ///
    /// SDK 会用自有导航容器 present，系统导航栏默认隐藏。从游戏中心再打开具体游戏时，仍在该容器内跳转。
    ///
    /// - Parameters:
    ///   - viewController: 起始页面，可不传；未传时 SDK 取当前最上层页面。
    ///   - config: 本次展示配置。`urlQuery` 拼到游戏中心链接上，`trackParams` 并入后续行为回传。不传则用 `LampsSDKConfig` 中的对应字段。
    ///   - completion: 打开结果。失败时 `error` 的 `domain` 为 `LampsSDKErrorDomain`，`code` 见 `LampsSDKErrorCode`。
    @objc(presentGameCenterFromViewController:config:completion:)
    public static func presentGameCenter(
        from viewController: UIViewController? = nil,
        config: LampsGameCenterConfig? = nil,
        completion: LampsShowGameCenterCompletion? = nil
    ) {
        let trackParams = sanitizedTrackParams(config?.trackParams)
        switch prepareGameCenter(from: viewController, config: config, trackParams: trackParams) {
        case .ready(let host, let page):
            LampsNavigator.presentInNavigationController(page, from: host)
            completion?(true, nil)
        case .failure(let error):
            completeGameCenter(error, trackParams: trackParams, completion: completion)
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
    ///   - config: 本次打开配置。`urlQuery` 拼到游戏页链接上，`trackParams` 并入后续行为回传。
    ///   - completion: 打开结果。失败时 `error` 的 `domain` 为 `LampsSDKErrorDomain`，`code` 见 `LampsSDKErrorCode`。
    @objc(showGameWithGameId:fromViewController:config:completion:)
    public static func showGame(
        gameId: String,
        from viewController: UIViewController? = nil,
        config: LampsGameConfig? = nil,
        completion: LampsShowGameCenterCompletion? = nil
    ) {
        let trackParams = sanitizedTrackParams(config?.trackParams)
        switch prepareGamePage(gameId: gameId, from: viewController, config: config, trackParams: trackParams) {
        case .ready(let host, let page):
            LampsNavigator.pushOrPresent(page, from: host)
            completion?(true, nil)
        case .failure(let error):
            completeGame(error, gameId: gameId, trackParams: trackParams, completion: completion)
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
    ///   - config: 本次打开配置。`urlQuery` 拼到游戏页链接上，`trackParams` 并入后续行为回传。
    ///   - completion: 打开结果。失败时 `error` 的 `domain` 为 `LampsSDKErrorDomain`，`code` 见 `LampsSDKErrorCode`。
    @objc(presentGameWithGameId:fromViewController:config:completion:)
    public static func presentGame(
        gameId: String,
        from viewController: UIViewController? = nil,
        config: LampsGameConfig? = nil,
        completion: LampsShowGameCenterCompletion? = nil
    ) {
        let trackParams = sanitizedTrackParams(config?.trackParams)
        switch prepareGamePage(gameId: gameId, from: viewController, config: config, trackParams: trackParams) {
        case .ready(let host, let page):
            LampsNavigator.presentInNavigationController(page, from: host)
            completion?(true, nil)
        case .failure(let error):
            completeGame(error, gameId: gameId, trackParams: trackParams, completion: completion)
        }
    }

    /// 使用配置下发的 `gameCenterPage` 创建可内嵌视图。请先 `start` 成功。
    /// 返回 `LampsGameCenterView`；地址不可用时返回 `nil`。
    /// 请由宿主加入自己的视图层级并设置约束。
    /// 宿主自有日夜间变化时调用 `updateDayNightMode`，无需重建本视图。
    /// 从该视图内再打开具体游戏时，SDK 会全屏 present，不进入宿主导航栈。
    ///
    /// - Parameters:
    ///   - config: 本次展示配置。`urlQuery` 拼到游戏中心链接上。内嵌视图本身不回传行为，`trackParams` 会带给从这里打开的游戏。不传则用 `LampsSDKConfig` 中的对应字段。
    @objc(makeGameCenterViewWithConfig:)
    public static func makeGameCenterView(
        config: LampsGameCenterConfig? = nil
    ) -> LampsGameCenterView? {
        guard case .success(let urlString) = resolveGameCenterPageURL(
            dayNightMode: resolvedDayNightMode(config?.dayNightMode),
            urlQuery: config?.urlQuery
        ) else { return nil }
        let webView = LampsWebView(
            displayMode: LampsBridgeClientInfo.DisplayMode.embed,
            dayNightMode: resolvedDayNightMode(config?.dayNightMode),
            hideTitle: config?.hideTitle ?? false
        )
        webView.behaviorTrackParams = sanitizedTrackParams(config?.trackParams)
        webView.reloadHandler = { [weak webView] in
            webView?.load(urlString: urlString)
        }
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

    /// 配置接口下发的客户端 ID。请求头 `L-CID` 与 `bridgeReady.cid` 使用。未下发时为空。
    static var clientId: String {
        storedRemoteConfig?.cid ?? ""
    }

    /// 媒体传入的用户 ID。`bridgeReady.uid` 使用；非空时写入命中域名请求的 `L-UID`。未传入或已清除时为空。
    static var userId: String {
        storedUserInfo?.userId ?? ""
    }

    /// 媒体传入的昵称。`bridgeReady.nickname` 使用。
    static var userNickname: String {
        storedUserInfo?.nickname ?? ""
    }

    /// 媒体传入的头像地址。`bridgeReady.avatar` 使用。
    static var userAvatar: String {
        storedUserInfo?.avatar ?? ""
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
        LampsSDKLog.debug("switch env=\(environment.logName)", category: .startup)
        configUpdatedAt = nil
        guard started, let config = storedConfig else {
            storedRemoteConfig = nil
            LampsSDKLog.debug("switch env saved, waiting for start", category: .startup)
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
        userIdLen: \(storedUserInfo?.userId.count ?? 0)
        nicknameLen: \(storedUserInfo?.nickname.count ?? 0)
        avatarLen: \(storedUserInfo?.avatar.count ?? 0)
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
        let cid = remote?.cid ?? ""
        return """
        remoteConfig: \(remote == nil ? "nil" : "ok")
        tokenLen: \(remote?.token.count ?? 0)
        cid: \(cid.isEmpty ? "-" : cid)
        clientIp: \(remote?.clientIp ?? "-")
        channels(\(remote?.channelList.count ?? 0)): \(channels)
        slots(\(remote?.rewardAdSlots.count ?? 0)): \(slots)
        gameCenterPage: \(gameCenter.isEmpty ? "-" : gameCenter)
        gamePageUrl: \(gamePage.isEmpty ? "-" : gamePage)
        personalizedRecommend: \(config?.personalizedRecommendEnabled ?? true)
        shakeAds: \(config?.shakeAdsEnabled ?? true)
        allowLocation: \(config?.allowLocation ?? false)
        initCSJ: \(config?.initializeCSJEnabled ?? true)
        initYlh: \(config?.initializeYlhEnabled ?? true)
        initNoah: \(config?.initializeNoahEnabled ?? true)
        """
    }

    /// 进入游戏容器时调用。距上次 Config 成功超过刷新间隔才后台再请求；不阻塞进页。
    static func refreshConfigIfNeededOnGameEnter() {
        guard started, let config = storedConfig else { return }
        if isFetchingConfig {
            LampsSDKLog.debug("config refresh skipped: in flight", category: .startup)
            return
        }
        if let configUpdatedAt, Date().timeIntervalSince(configUpdatedAt) < configRefreshInterval {
            LampsSDKLog.debug("config refresh skipped: fresh", category: .startup)
            return
        }
        LampsSDKLog.debug("config refresh: game enter stale", category: .startup)
        applyRemoteConfigFetch(config: config, completion: nil)
    }

    private static func applyRemoteConfigFetch(
        config: LampsSDKConfig,
        completion: LampsStartCompletion?
    ) {
        isFetchingConfig = true
        LampsConfigService.fetch(config: config) { result in
            DispatchQueue.main.async {
                isFetchingConfig = false
                switch result {
                case .success(let remote):
                    storedRemoteConfig = remote
                    configUpdatedAt = Date()
                    LampsSDKLog.debug("config fetch ok env=\(LampsEnvironmentStore.current.logName)", category: .startup)
                    initializeAdSDKsIfNeeded(config: config) {
                        completion?(true, nil)
                    }
                case .failure(let error):
                    if storedRemoteConfig != nil {
                        LampsSDKLog.debug(
                            "config fetch failed keep cache: \(error.localizedDescription)",
                            category: .startup
                        )
                        initializeAdSDKsIfNeeded(config: config) {
                            completion?(true, nil)
                        }
                    } else {
                        LampsSDKLog.debug(
                            "config fetch failed and no cache: \(error.localizedDescription)",
                            category: .startup
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
        config: LampsGameCenterConfig?,
        trackParams: [String: String]
    ) -> GameCenterPrepareResult {
        switch resolveGameCenterPageURL(
            dayNightMode: resolvedDayNightMode(config?.dayNightMode),
            urlQuery: config?.urlQuery
        ) {
        case .success(let url):
            guard let host = viewController ?? LampsNavigator.currentHostViewController() else {
                return .failure(.noHostViewController("找不到可用于打开游戏中心的页面"))
            }
            let page = LampsWebViewController(urlString: url)
            page.displayMode = LampsBridgeClientInfo.DisplayMode.page
            page.dayNightMode = resolvedDayNightMode(config?.dayNightMode)
            page.hideTitle = config?.hideTitle ?? false
            page.beginBehaviorVisit(kind: .center, trackParams: trackParams)
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
        trackParams: [String: String],
        completion: LampsShowGameCenterCompletion?
    ) {
        let nsError = error.nsError
        LampsSDKLog.debug("showGameCenter failed: \(nsError.localizedDescription)")
        LampsBehaviorTracker.shared.reportOpenFailure(
            kind: .center,
            gameId: nil,
            error: nsError,
            trackParams: trackParams
        )
        completion?(false, nsError)
    }

    /// 只负责解析游戏页地址和宿主，不跳转、不回调。
    private static func prepareGamePage(
        gameId: String,
        from viewController: UIViewController?,
        config: LampsGameConfig?,
        trackParams: [String: String]
    ) -> GamePagePrepareResult {
        switch resolveGamePageURL(gameId: gameId, urlQuery: config?.urlQuery) {
        case .success(let url):
            guard let host = viewController ?? LampsNavigator.currentHostViewController() else {
                return .failure(.noHostViewController("找不到可用于打开游戏页的页面"))
            }
            let page = LampsGameWebViewController(urlString: url)
            page.beginBehaviorVisit(kind: .game, gameId: gameId, trackParams: trackParams)
            return .ready(host: host, page: page)
        case .failure(let error):
            return .failure(error)
        }
    }

    private static func completeGame(
        _ error: LampsSDKError,
        gameId: String,
        trackParams: [String: String],
        completion: LampsShowGameCenterCompletion?
    ) {
        let nsError = error.nsError
        LampsSDKLog.debug("showGame failed: \(nsError.localizedDescription)")
        LampsBehaviorTracker.shared.reportOpenFailure(
            kind: .game,
            gameId: gameId,
            error: nsError,
            trackParams: trackParams
        )
        completion?(false, nsError)
    }

    private static func resolveGameCenterPageURL(
        dayNightMode: LampsDayNightMode,
        urlQuery: [String: String]?
    ) -> GameCenterPageResult {
        guard started else {
            LampsSDKLog.debug("gameCenterPage skipped: not started")
            return .failure(.notStarted("尚未调用 Lamps.start"))
        }
        let url = storedRemoteConfig?.gameCenterPage.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !url.isEmpty, LampsWebView.makeURL(from: url) != nil else {
            LampsSDKLog.debug("gameCenterPage unavailable url=\(url)")
            return .failure(.gameCenterUnavailable("游戏中心地址不可用"))
        }
        let pageURL = appendingQuery(["night": "\(dayNightMode.bridgeNightValue)"], to: url)
        return .success(appendingQuery(urlQuery, to: pageURL))
    }

    private static func resolveGamePageURL(
        gameId: String,
        urlQuery: [String: String]?
    ) -> GameCenterPageResult {
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
        return .success(appendingQuery(urlQuery, to: url))
    }

    /// 丢掉空白键，避免空名字写进行为回传。值保持原样。
    private static func sanitizedTrackParams(_ raw: [String: String]?) -> [String: String] {
        guard let raw, !raw.isEmpty else { return [:] }
        var result: [String: String] = [:]
        for (key, value) in raw {
            let name = key.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !name.isEmpty else { continue }
            result[name] = value
        }
        return result
    }

    /// 把字典拼到链接末尾。整段链接里已有 `?` 时用 `&`，否则用 `?`。游戏页参数写在 `#` 后面，直接拼在末尾即可落在同一段。
    /// 同名参数不再追加，保留链接原值。
    private static func appendingQuery(_ params: [String: String]?, to urlString: String) -> String {
        guard let query = queryString(from: params, excluding: existingQueryKeys(in: urlString)) else {
            return urlString
        }
        let separator = urlString.contains("?") ? "&" : "?"
        return urlString + separator + query
    }

    /// 按整段链接里的每个 `?` 收集已有参数名，不单独处理 `#`。
    private static func existingQueryKeys(in urlString: String) -> Set<String> {
        let sections = urlString.split(separator: "?", omittingEmptySubsequences: true)
        guard sections.count > 1 else { return [] }
        var keys = Set<String>()
        for section in sections.dropFirst() {
            for pair in section.split(separator: "&", omittingEmptySubsequences: true) {
                let rawKey = String(pair.split(separator: "=", maxSplits: 1).first ?? "")
                let trimmed = rawKey.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { continue }
                keys.insert(trimmed)
                if let decoded = trimmed.removingPercentEncoding {
                    let decodedName = decoded.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !decodedName.isEmpty {
                        keys.insert(decodedName)
                    }
                }
            }
        }
        return keys
    }

    private static func queryString(from params: [String: String]?, excluding existingKeys: Set<String> = []) -> String? {
        guard let params, !params.isEmpty else { return nil }
        let pairs = params.keys.sorted().compactMap { key -> String? in
            let name = key.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !name.isEmpty, !existingKeys.contains(name) else { return nil }
            let value = params[key] ?? ""
            return "\(percentEncodingQueryComponent(name))=\(percentEncodingQueryComponent(value))"
        }
        guard !pairs.isEmpty else { return nil }
        return pairs.joined(separator: "&")
    }

    /// 与 JS `encodeURIComponent` 对齐，避免 `&`、`=`、`?`、`#` 破坏原链接。
    private static func percentEncodingQueryComponent(_ string: String) -> String {
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-_.!~*'()")
        return string.addingPercentEncoding(withAllowedCharacters: allowed) ?? string
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
