import UIKit
import WebKit

/// 带 Lamps JSBridge 的 WKWebView。可单独嵌入业务页面；全屏活动请优先用 `LampsWebViewController`。
@objcMembers
public class LampsWebView: WKWebView {
    /// 仅 SDK 内部使用。
    @nonobjc
    var bridge: LampsBridge!

    /// H5 通过 Bridge 调用 `close` 时触发。
    /// 使用 `LampsWebViewController` 时无需设置；自行承载时请在此关闭当前页面。
    public var closeHandler: (() -> Void)?

    /// 使用 SDK 默认配置创建 WebView。
    public convenience init() {
        self.init(frame: .zero, configuration: LampsWebView.makeConfiguration())
    }

    public override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        commonSetup()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        commonSetup()
    }

    deinit {
        bridge?.uninstall()
    }

    /// 加载活动页。`urlString` 必须包含 scheme 和 host，不合法时返回 `false` 且不发起请求。
    @discardableResult
    @objc(loadURLString:)
    public func load(urlString: String) -> Bool {
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
        allowsBackForwardNavigationGestures = true
        uiDelegate = self
        let bridge = LampsBridge(webView: self)
        self.bridge = bridge
        bridge.install()
        bridge.addHandler(LampsRewardBridgeHandler())
        bridge.addHandler(LampsRequestBridgeHandler())
        bridge.addHandler(LampsTrackBridgeHandler())
    }
}

extension LampsWebView: WKUIDelegate {
    public func webView(
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
