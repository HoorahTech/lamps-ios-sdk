import UIKit
import LampsSDK

@objc(LAMPSSDKViewController)
final class LAMPSSDKViewController: UIViewController {
    private static let demoGameId = "10001"

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            makeButton(title: "打开游戏中心", action: #selector(openGameCenter)),
            makeButton(title: "打开单个游戏", action: #selector(openGame)),
            makeButton(title: "makeGameCenterView 测试", action: #selector(openGameCenterEmbed)),
            makeButton(title: "调试工具", action: #selector(openDevTools))
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16
        stack.distribution = .fillEqually
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Lamps Demo"
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
            navigationItem.standardAppearance = appearance
            navigationItem.scrollEdgeAppearance = appearance
            navigationItem.compactAppearance = appearance
        } else {
            navigationController?.navigationBar.isTranslucent = false
            navigationController?.navigationBar.barTintColor = .white
            navigationController?.navigationBar.titleTextAttributes = [
                .foregroundColor: UIColor.black
            ]
        }
        view.backgroundColor = .white
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            stackView.widthAnchor.constraint(equalToConstant: 320),
            stackView.heightAnchor.constraint(equalToConstant: 400)
        ])
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        }
        return .default
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

    @objc private func openGameCenter() {
        Lamps.showGameCenter(from: self) { success, error in
            if !success {
                NSLog("[LampsSDK Demo] %@", error?.localizedDescription ?? "gameCenter unavailable")
            }
        }
    }

    @objc private func openGame() {
        Lamps.showGame(gameId: "2", from: self) { success, error in
            if !success {
                NSLog("[LampsSDK Demo] %@", error?.localizedDescription ?? "game unavailable")
            }
        }
    }

    @objc private func openGameCenterEmbed() {
        navigationController?.pushViewController(LAMPSSDKGameCenterEmbedViewController(), animated: true)
    }

    @objc private func openDevTools() {
        LampsDevTools.push(from: self)
    }
}
