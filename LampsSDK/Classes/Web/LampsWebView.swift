import UIKit
import WebKit

/// 可独立使用的 WKWebView 子类。页面加载与 Bridge 都挂在这个 View 上。
@objcMembers
public class LampsWebView: WKWebView {
    public private(set) var bridge: LampsBridge!

    private let navigationHandler = LampsNavigationBridgeHandler()

    /// H5 调用 `close` 时触发。
    public var closeHandler: (() -> Void)? {
        didSet { navigationHandler.closeHandler = closeHandler }
    }

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

    /// 按字符串加载页面。URL 不合法时返回 false。
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

    public static func makeURL(from string: String) -> URL? {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let url = URL(string: trimmed), url.scheme != nil, url.host != nil else {
            return nil
        }
        return url
    }

    public static func makeConfiguration() -> WKWebViewConfiguration {
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
        bridge.addHandler(LampsBaseBridgeHandler())
        navigationHandler.closeHandler = closeHandler
        bridge.addHandler(navigationHandler)
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
