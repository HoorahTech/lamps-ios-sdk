import UIKit
import WebKit

/// 带 Lamps JSBridge 的 WKWebView。仅 SDK 内部使用，宿主请走 `Lamps.showGameCenter(from:)`。
/// 主文档加载失败时，在页面上方盖原生失败页。无网用网络文案，其他错误用通用文案。
/// 有 `closeHandler` 时失败页提供关闭；内嵌未设置时只提供重试。
final class LampsWebView: WKWebView {
    var bridge: LampsBridge!
    var closeHandler: (() -> Void)?
    /// 失败页点重试时调用。页面容器走 `reloadPage()`，内嵌容器按原地址再加载。
    var reloadHandler: (() -> Void)?
    /// 透传给 H5 的展示形态，见 `LampsBridgeClientInfo.DisplayMode`。未设置时为空。
    let displayMode: String
    /// 日夜间。未设置时由 Bridge 回落到 `LampsSDKConfig.dayNightMode`。
    var dayNightMode: LampsDayNightMode?
    /// 是否隐藏 H5 标题栏。来自本次 `LampsGameCenterConfig`，未设置时不隐藏。
    var hideTitle: Bool
    private let loadGuard = LampsWebLoadGuard()

    init(displayMode: String = "", dayNightMode: LampsDayNightMode? = nil, hideTitle: Bool = false) {
        self.displayMode = displayMode
        self.dayNightMode = dayNightMode
        self.hideTitle = hideTitle
        super.init(frame: .zero, configuration: LampsWebView.makeConfiguration())
        commonSetup()
    }

    required init?(coder: NSCoder) {
        displayMode = ""
        dayNightMode = nil
        hideTitle = false
        super.init(coder: coder)
        commonSetup()
    }

    deinit {
        bridge?.uninstall()
    }

    func applyDayNightMode(_ mode: LampsDayNightMode) {
        dayNightMode = mode
        applyPageBackgroundColor()
        loadGuard.applyDayNightMode()
        LampsSDKLog.debug("nightMode change night=\(mode.bridgeNightValue)")
        bridge.send(
            method: LampsBridgeClientInfo.nightModeChangeMethod,
            data: ["night": mode.bridgeNightValue]
        )
    }

    func notifyContainerWillAppear() {
        bridge?.notifyContainerWillAppear()
    }

    func notifyContainerWillDisappear() {
        bridge?.notifyContainerWillDisappear()
    }

    @discardableResult
    func load(urlString: String) -> Bool {
        guard let url = Self.makeURL(from: urlString) else {
            LampsSDKLog.debug("load skipped: invalid url=\(urlString)")
            return false
        }
        LampsSDKLog.debug("load url=\(url.absoluteString)")
        load(URLRequest(url: url))
        return true
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        loadGuard.webViewDidMoveToSuperview()
    }

    static func makeURL(from string: String) -> URL? {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let url = URL(string: trimmed), url.scheme != nil, url.host != nil else {
            return nil
        }
        return url
    }

    /// 写入 UA 的 SDK 标记，形如 `LampsSDK/0.0.1`。
    static var userAgentApplicationName: String {
        "LampsSDK/\(Lamps.sdkVersion)"
    }

    static func makeConfiguration() -> WKWebViewConfiguration {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.applicationNameForUserAgent = userAgentApplicationName
        if #available(iOS 13.0, *) {
            let webpage = WKWebpagePreferences()
            webpage.preferredContentMode = .mobile
            config.defaultWebpagePreferences = webpage
        }
        return config
    }

    /// 默认 UA 后追加 `LampsSDK/x.x.x`，让 `navigator.userAgent` 一定能读到。
    static func makeCustomUserAgent(base: String) -> String {
        let token = userAgentApplicationName
        if base.contains(token) {
            return base
        }
        if base.isEmpty {
            return token
        }
        return "\(base) \(token)"
    }
}

private extension LampsWebView {
    func commonSetup() {
        isOpaque = false
        applyPageBackgroundColor()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        translatesAutoresizingMaskIntoConstraints = false
        applyCustomUserAgent()
        uiDelegate = self
        navigationDelegate = self
        loadGuard.attach(self)
        let bridge = LampsBridge(webView: self)
        self.bridge = bridge
        bridge.install()
        bridge.addHandler(LampsRewardBridgeHandler())
        bridge.addHandler(LampsRequestBridgeHandler())
        bridge.addHandler(LampsTrackBridgeHandler())
        bridge.addHandler(LampsReadyBridgeHandler())
        bridge.addHandler(LampsGamePageBridgeHandler())
        bridge.addHandler(LampsUIBridgeHandler())
    }

    func applyCustomUserAgent() {
        let token = Self.userAgentApplicationName
        if let current = customUserAgent, current.contains(token) {
            return
        }
        let base: String
        if let current = customUserAgent, !current.isEmpty {
            base = current
        } else {
            base = LampsDeviceInfo.userAgent
        }
        customUserAgent = Self.makeCustomUserAgent(base: base)
        LampsSDKLog.debug("customUserAgent=\(customUserAgent ?? "")")
    }

    func applyPageBackgroundColor() {
        let color: UIColor
        switch Lamps.resolvedDayNightMode(dayNightMode) {
        case .day:
            color = LampsColor.color(fromHex: "#FFFFFF") ?? .white
        case .night:
            color = LampsColor.color(fromHex: "#141218") ?? .black
        }
        backgroundColor = color
        if #available(iOS 15.0, *) {
            underPageBackgroundColor = color
        }
    }
}

extension LampsWebView: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        loadGuard.willNavigate(navigationAction)
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        loadGuard.didStartNavigation(navigation)
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        loadGuard.didCommitNavigation(navigation)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadGuard.didFinishNavigation(navigation)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        loadGuard.didFailNavigation(navigation, error: error)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loadGuard.didFailNavigation(navigation, error: error)
    }
}

extension LampsWebView: WKUIDelegate {
    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        if navigationAction.targetFrame == nil, let url = navigationAction.request.url {
            webView.load(URLRequest(url: url))
        }
        return nil
    }
}
