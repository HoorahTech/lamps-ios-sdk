import UIKit
import WebKit

/// 只处理主文档加载结果。由 `LampsWebView` 把导航回调转进来，自身不是 `WKNavigationDelegate`。
/// 主文档加载失败时盖上失败页。无网 `-1009` 用网络文案，其他错误用通用文案。
/// 子框架失败和被新加载取消的请求不盖页。有 `closeHandler` 才显示关闭。
final class LampsWebLoadGuard: NSObject {
    private weak var webView: LampsWebView?
    private let failureView = LampsWebLoadFailureView()
    private var pinConstraints: [NSLayoutConstraint] = []
    /// `decidePolicy` 与 `didStartProvisionalNavigation` 按调用顺序配对，用来识别主框架。
    private var pendingMainFrameFlags: [Bool] = []
    private var mainNavigationID: ObjectIdentifier?

    func attach(_ webView: LampsWebView) {
        self.webView = webView
        failureView.onRetry = { [weak webView] in
            webView?.reloadHandler?()
        }
        failureView.onClose = { [weak webView] in
            webView?.closeHandler?()
        }
    }

    func webViewDidMoveToSuperview() {
        guard webView?.superview != nil else {
            NSLayoutConstraint.deactivate(pinConstraints)
            pinConstraints = []
            failureView.removeFromSuperview()
            return
        }
        placeFailureView()
    }

    func applyDayNightMode() {
        refreshFailureAppearance()
    }

    func willNavigate(_ navigationAction: WKNavigationAction) {
        let isMainFrame = navigationAction.targetFrame?.isMainFrame ?? true
        pendingMainFrameFlags.append(isMainFrame)
    }

    func didStartNavigation(_ navigation: WKNavigation?) {
        // 没有配对到 decidePolicy 的迟到回调不再当作主框架，避免盖住下一次加载。
        guard !pendingMainFrameFlags.isEmpty else { return }
        let isMainFrame = pendingMainFrameFlags.removeFirst()
        guard isMainFrame, let navigation else { return }
        mainNavigationID = ObjectIdentifier(navigation)
    }

    func didCommitNavigation(_ navigation: WKNavigation?) {
        guard isCurrentMainNavigation(navigation) else { return }
        dismissFailure()
    }

    func didFinishNavigation(_ navigation: WKNavigation?) {
        guard isCurrentMainNavigation(navigation) else { return }
        dismissFailure()
    }

    func didFailNavigation(_ navigation: WKNavigation?, error: Error) {
        if Self.shouldIgnore(error) { return }
        // 只处理当前这一次主框架。子框架、以及已被新加载替换的旧请求都不盖页。
        guard let navigation, ObjectIdentifier(navigation) == mainNavigationID else { return }
        let nsError = error as NSError
        let message = Self.isNotConnected(error) ? "网络异常，请检查网络后重试" : "页面加载失败，请稍后重试"
        presentFailure(reason: "\(nsError.domain) \(nsError.code)", message: message)
    }

    private func isCurrentMainNavigation(_ navigation: WKNavigation?) -> Bool {
        guard let navigation else { return mainNavigationID == nil }
        guard let mainNavigationID else { return true }
        return ObjectIdentifier(navigation) == mainNavigationID
    }

    private func presentFailure(reason: String, message: String) {
        if failureView.isHidden {
            LampsSDKLog.debug("show load failure: \(reason)")
        }
        failureView.setMessage(message)
        failureView.isHidden = false
        refreshFailureAppearance()
        placeFailureView()
    }

    private func dismissFailure() {
        failureView.isHidden = true
    }

    private func refreshFailureAppearance() {
        let mode = Lamps.resolvedDayNightMode(webView?.dayNightMode)
        failureView.apply(mode: mode, showsClose: webView?.closeHandler != nil)
    }

    private func placeFailureView() {
        guard let webView, let superview = webView.superview else { return }
        if failureView.superview !== superview {
            NSLayoutConstraint.deactivate(pinConstraints)
            superview.insertSubview(failureView, aboveSubview: webView)
            pinConstraints = [
                failureView.topAnchor.constraint(equalTo: webView.topAnchor),
                failureView.leadingAnchor.constraint(equalTo: webView.leadingAnchor),
                failureView.trailingAnchor.constraint(equalTo: webView.trailingAnchor),
                failureView.bottomAnchor.constraint(equalTo: webView.bottomAnchor)
            ]
            NSLayoutConstraint.activate(pinConstraints)
        } else {
            superview.insertSubview(failureView, aboveSubview: webView)
        }
    }

    static func isNotConnected(_ error: Error) -> Bool {
        let nsError = error as NSError
        return nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorNotConnectedToInternet
    }

    /// 取消（`-999`）和策略中断不是页面打不开。
    static func shouldIgnore(_ error: Error) -> Bool {
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled {
            return true
        }
        // WebKitErrorFrameLoadInterruptedByPolicyChange：导航策略打断了这次加载，不是页面打不开。
        if nsError.domain == WKError.errorDomain && nsError.code == 102 {
            return true
        }
        return false
    }
}
