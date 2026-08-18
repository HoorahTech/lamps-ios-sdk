import UIKit

/// WebView 容器。第一阶段仅提供页面骨架，下一阶段再接入 WKWebView 与 Bridge。
@objcMembers
public final class LampsWebViewController: UIViewController {
    public let urlString: String

    private lazy var hintLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.text = "WebView 与 Bridge 将在下一阶段接入。\n当前只验证页面可以打开。"
        return label
    }()

    private lazy var urlLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 13)
        label.textColor = .gray
        label.text = urlString.isEmpty ? "(未传入 URL)" : urlString
        return label
    }()

    @objc(initWithURLString:)
    public init(urlString: String) {
        self.urlString = urlString
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
        view.addSubview(hintLabel)
        view.addSubview(urlLabel)
        NSLayoutConstraint.activate([
            hintLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            hintLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            hintLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            urlLabel.leadingAnchor.constraint(equalTo: hintLabel.leadingAnchor),
            urlLabel.trailingAnchor.constraint(equalTo: hintLabel.trailingAnchor),
            urlLabel.topAnchor.constraint(equalTo: hintLabel.bottomAnchor, constant: 16)
        ])
        LampsSDKLog.debug("open web placeholder, url=\(urlString)")
    }

    @objc private func closePage() {
        if presentingViewController != nil {
            dismiss(animated: true)
            return
        }
        navigationController?.popViewController(animated: true)
    }
}
