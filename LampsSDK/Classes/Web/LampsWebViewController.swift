import UIKit

/// 全屏 Web 页面容器。真正的加载与 Bridge 都在 `LampsWebView` 上。
@objcMembers
public final class LampsWebViewController: UIViewController {
    public let urlString: String
    public let htmlString: String?

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
        title = "Lamps WebView"
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "关闭",
            style: .plain,
            target: self,
            action: #selector(closePage)
        )
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
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

    @objc func closePage() {
        if presentingViewController != nil {
            dismiss(animated: true)
            return
        }
        navigationController?.popViewController(animated: true)
    }
}
