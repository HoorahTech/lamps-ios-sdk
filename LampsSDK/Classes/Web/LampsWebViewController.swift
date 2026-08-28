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

    private var previousNavigationBarHidden: Bool?

    /// 页面内 WebView，仅 SDK 内部使用。
    private lazy var webView: LampsWebView = {
        let webView = LampsWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
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
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
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

    /// 关闭当前页：模态容器则 `dismiss`，否则 `pop`。
    @objc
    public func closePage() {
        if let navigationController = navigationController,
           navigationController.presentingViewController != nil {
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
}
