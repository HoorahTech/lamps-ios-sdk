import UIKit
import WebKit

/// 带 Lamps JSBridge 的 WKWebView。仅 SDK 内部使用，宿主请走 `Lamps.showGameCenter(from:)`。
final class LampsWebView: WKWebView {
    var bridge: LampsBridge!
    var closeHandler: (() -> Void)?

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

    static func makeConfiguration() -> WKWebViewConfiguration {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        if #available(iOS 13.0, *) {
            let webpage = WKWebpagePreferences()
            webpage.preferredContentMode = .mobile
            config.defaultWebpagePreferences = webpage
        }
        return config
    }
}

private extension LampsWebView {
    func commonSetup() {
        uiDelegate = self
        let bridge = LampsBridge(webView: self)
        self.bridge = bridge
        bridge.install()
        bridge.addHandler(LampsRewardBridgeHandler())
        bridge.addHandler(LampsRequestBridgeHandler())
        bridge.addHandler(LampsTrackBridgeHandler())
        bridge.addHandler(LampsReadyBridgeHandler())
        bridge.addHandler(LampsGamePageBridgeHandler())
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
