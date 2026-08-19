import UIKit

/// 全屏 Web 页面容器。真正的加载与 Bridge 都在 `LampsWebView` 上。
/// 隐藏系统导航栏，整页交给 webView 渲染；关闭走 Bridge `close` 或 `closePage`。
@objcMembers
public final class LampsWebViewController: UIViewController {
    public let urlString: String
    public let htmlString: String?

    private var previousNavigationBarHidden: Bool?

    public private(set) lazy var webView: LampsWebView = {
        let webView = LampsWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.closeHandler = { [weak self] in
            self?.closePage()
        }
        return webView
    }()

    @objc(initWithURLString:)
    public convenience init(urlString: String) {
        self.init(urlString: urlString, htmlString: nil)
    }

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
        guard let navigationController else { return }
        if previousNavigationBarHidden == nil {
            previousNavigationBarHidden = navigationController.isNavigationBarHidden
        }
        navigationController.setNavigationBarHidden(true, animated: animated)
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let navigationController,
              let previousNavigationBarHidden else { return }
        // 仅在自身被移出导航栈时恢复，避免 push 下级页时误恢复
        if isMovingFromParent || isBeingDismissed {
            navigationController.setNavigationBarHidden(previousNavigationBarHidden, animated: animated)
        }
    }

    @objc func closePage() {
        if presentingViewController != nil {
            dismiss(animated: true)
            return
        }
        navigationController?.popViewController(animated: true)
    }
}
