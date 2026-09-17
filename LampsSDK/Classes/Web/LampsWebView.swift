import UIKit
import WebKit

/// 带 Lamps JSBridge 的 WKWebView。仅 SDK 内部使用，宿主请走 `Lamps.showGameCenter(from:)`。
final class LampsWebView: WKWebView {
    var bridge: LampsBridge!
    var closeHandler: (() -> Void)?
    /// 透传给 H5 的展示形态，见 `LampsBridgeClientInfo.DisplayMode`。未设置时为空。
    var displayMode: String = ""
    /// 日夜间。未设置时由 Bridge 回落到 `LampsSDKConfig.dayNightMode`。
    var dayNightMode: LampsDayNightMode?

    convenience init() {
        self.init(frame: .zero, configuration: LampsWebView.makeConfiguration())
    }

    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        commonSetup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonSetup()
    }

    deinit {
        bridge?.uninstall()
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
        applyCustomUserAgent()
        uiDelegate = self
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
