import UIKit
import LampsSDK

@objc(LAMPSSDKViewController)
final class LAMPSSDKViewController: UIViewController {
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            makeButton(title: "打开 WebView（骨架）", action: #selector(openWebView)),
            makeButton(title: "激励视频（后续阶段）", action: #selector(showReward)),
            makeButton(title: "上报 CM/PM/XM（后续阶段）", action: #selector(reportStub))
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16
        stack.distribution = .fillEqually
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 120),
            stackView.widthAnchor.constraint(lessThanOrEqualToConstant: 320),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),
            stackView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }

    private func makeButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.96, alpha: 1)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    @objc private func openWebView() {
        let webVC = LampsWebViewController(urlString: "https://www.hupu.com")
        let nav = UINavigationController(rootViewController: webVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }

    @objc private func showReward() {
        LampsRewardAd.show(from: self) { [weak self] rewarded, error in
            let message = error?.localizedDescription ?? (rewarded ? "发奖成功" : "未发奖")
            self?.showAlert(title: "激励视频", message: message)
        }
    }

    @objc private func reportStub() {
        LampsReporter.reportCM(urls: ["https://example.com/cm"], extra: ["scene": "demo"])
        LampsReporter.reportPM(urls: ["https://example.com/pm"], extra: ["scene": "demo"])
        LampsReporter.reportXM(urls: ["https://example.com/xm"], extra: ["scene": "demo"])
        showAlert(title: "上报", message: "已调用 CM/PM/XM 占位方法，详见控制台日志。")
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "好", style: .default))
        present(alert, animated: true)
    }
}
