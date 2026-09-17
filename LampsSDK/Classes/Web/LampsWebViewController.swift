import UIKit

/// 全屏活动容器：隐藏系统导航栏，整页交给 H5。
///
/// 请 `push` 或 `present` 本页。关闭由 H5 Bridge `close` 触发，也可调用 `closePage()`。
/// 游戏 H5 请使用 `LampsGameWebViewController`。
@objcMembers
public class LampsWebViewController: UIViewController {
    /// 当前活动 URL；本地 HTML 模式下为空字符串。
    public let urlString: String
    /// 本地 HTML；通过 URL 打开时为 `nil`。
    public let htmlString: String?
    /// 透传给 H5 的展示形态，见 `LampsBridgeClientInfo.DisplayMode`。未设置时为空。
    var displayMode: String = ""

    private var previousNavigationBarHidden: Bool?
    private var webViewTopConstraint: NSLayoutConstraint?
    /// 显示系统状态栏。默认 `true`。
    private var showsStatusBar = true
    /// 沉浸式：`true` WebView 从屏幕顶部布局；`false` 从状态栏下方开始。默认 `true`。
    private var statusBarImmersive = true
    /// `0` 浅色状态栏文字，`1` 深色。默认 `1`。
    private var statusBarFontStyle = 1
    private var statusBarBackgroundColor: UIColor = .white

    /// 页面内 WebView，仅 SDK 内部使用。
    private lazy var webView: LampsWebView = {
        let webView = LampsWebView()
        webView.displayMode = displayMode
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.closeHandler = { [weak self] in
            self?.closePage()
        }
        return webView
    }()

    /// 打开远端活动页。
    @objc(initWithURLString:)
    public convenience init(urlString: String) {
        self.init(urlString: urlString, htmlString: nil)
    }

    /// 加载本地 HTML，建议仅用于调试。
    @objc(initWithHTMLString:)
    public convenience init(htmlString: String) {
        self.init(urlString: "", htmlString: htmlString)
    }

    public init(urlString: String, htmlString: String?) {
        self.urlString = urlString
        self.htmlString = htmlString
        super.init(nibName: nil, bundle: nil)
        modalPresentationCapturesStatusBarAppearance = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override var prefersStatusBarHidden: Bool {
        !showsStatusBar
    }

    public override var preferredStatusBarStyle: UIStatusBarStyle {
        if statusBarFontStyle == 0 {
            return .lightContent
        }
        if #available(iOS 13.0, *) {
            return .darkContent
        }
        return .default
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = statusBarBackgroundColor
        view.addSubview(webView)
        let top = makeWebViewTopConstraint()
        webViewTopConstraint = top
        NSLayoutConstraint.activate([
            top,
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        if let htmlString = htmlString {
            webView.loadHTMLString(htmlString, baseURL: nil)
        } else {
            webView.load(urlString: urlString)
        }
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        webView.notifyContainerWillAppear()
        guard let navigationController else { return }
        if previousNavigationBarHidden == nil {
            previousNavigationBarHidden = navigationController.isNavigationBarHidden
        }
        navigationController.setNavigationBarHidden(true, animated: animated)
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView.notifyContainerWillDisappear()
        guard let navigationController,
              let previousNavigationBarHidden else { return }
        // 仅在自身被移出导航栈时恢复，避免 push 下级页时误恢复
        if isMovingFromParent || isBeingDismissed {
            navigationController.setNavigationBarHidden(previousNavigationBarHidden, animated: animated)
        }
    }

    /// 由 `lamps.common.statusBar` 调用。`backgroundColor` 为 `nil` 时不改容器背景。
    func applyStatusBar(
        showStatusBar: Bool,
        immersive: Bool,
        backgroundColor: UIColor?,
        fontStyle: Int
    ) {
        var statusBarNeedsUpdate = false
        if showsStatusBar != showStatusBar {
            showsStatusBar = showStatusBar
            statusBarNeedsUpdate = true
        }
        let style = fontStyle == 0 ? 0 : 1
        if statusBarFontStyle != style {
            statusBarFontStyle = style
            statusBarNeedsUpdate = true
        }
        if let backgroundColor {
            statusBarBackgroundColor = backgroundColor
            if isViewLoaded {
                view.backgroundColor = backgroundColor
            }
        }
        if statusBarImmersive != immersive {
            statusBarImmersive = immersive
            if isViewLoaded {
                updateWebViewTopInset()
            }
        }
        if statusBarNeedsUpdate {
            setNeedsStatusBarAppearanceUpdate()
        }
    }

    /// 关闭当前页：栈内有上级则 `pop`，自身或所在导航容器为模态根页时才 `dismiss`。
    @objc
    public func closePage() {
        if let navigationController, navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
            return
        }
        if let navigationController, navigationController.presentingViewController != nil {
            navigationController.dismiss(animated: true)
            return
        }
        if presentingViewController != nil {
            dismiss(animated: true)
            return
        }
        navigationController?.popViewController(animated: true)
    }

    /// 重新加载当前页：本地 HTML 再注入一次，否则按原 URL 重新请求。
    @objc
    public func reloadPage() {
        if let htmlString = htmlString {
            webView.loadHTMLString(htmlString, baseURL: nil)
            return
        }
        webView.load(urlString: urlString)
    }

    private func makeWebViewTopConstraint() -> NSLayoutConstraint {
        if statusBarImmersive {
            return webView.topAnchor.constraint(equalTo: view.topAnchor)
        }
        return webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
    }

    private func updateWebViewTopInset() {
        webViewTopConstraint?.isActive = false
        let top = makeWebViewTopConstraint()
        top.isActive = true
        webViewTopConstraint = top
        view.setNeedsLayout()
    }
}
