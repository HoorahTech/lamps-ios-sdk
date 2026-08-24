import UIKit
#if LampsADAPTER_SEPARATE_MODULE
@_spi(LampsDevTools) import LampsSDK
#endif
#if canImport(BUAdTestMeasurement)
import BUAdTestMeasurement
#endif

/// 聚合 Lamps 自身调试信息与穿山甲 / 优量汇 / 汇川调试入口。
final class LampsDevToolsViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .fill
        return stack
    }()

    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        if #available(iOS 13.0, *) {
            label.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        } else {
            label.font = .systemFont(ofSize: 13)
        }
        label.textColor = .darkText
        return label
    }()

    private lazy var prdEnvironmentButton: UIButton = makeEnvironmentButton(
        title: "正式 prd",
        action: #selector(switchToPrd)
    )
    private lazy var devEnvironmentButton: UIButton = makeEnvironmentButton(
        title: "测试 dev",
        action: #selector(switchToDev)
    )
    private lazy var environmentButtonStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [prdEnvironmentButton, devEnvironmentButton])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        return stack
    }()

    private lazy var environmentHintLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray
        label.text = "默认正式环境。切换后重新拉取配置，并在本机记住（下次启动仍生效）。"
        return label
    }()

    private static let environmentSelectedColor = UIColor(red: 0.10, green: 0.46, blue: 0.82, alpha: 1)
    private static let environmentNormalColor = UIColor(red: 0.95, green: 0.95, blue: 0.96, alpha: 1)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Lamps 调试工具"
        view.backgroundColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "关闭",
            style: .plain,
            target: self,
            action: #selector(close)
        )
        setupLayout()
        reloadInfo()
    }

    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40)
        ])

        stackView.addArrangedSubview(sectionTitle("Lamps SDK"))
        stackView.addArrangedSubview(infoLabel)
        stackView.addArrangedSubview(sectionTitle("配置环境"))
        stackView.addArrangedSubview(environmentButtonStack)
        stackView.addArrangedSubview(environmentHintLabel)
        stackView.addArrangedSubview(makeButton(title: "刷新状态", action: #selector(reloadInfo)))
        stackView.addArrangedSubview(makeButton(title: "清除 Config 磁盘缓存", action: #selector(clearConfigCache)))

        stackView.addArrangedSubview(sectionTitle("三方广告调试"))
        stackView.addArrangedSubview(makeButton(title: "穿山甲测试工具", action: #selector(openCSJTool)))
        stackView.addArrangedSubview(makeButton(title: "优量汇测试工具", action: #selector(openGDTTool)))
        stackView.addArrangedSubview(makeButton(title: "汇川测试工具", action: #selector(openNoahTool)))
    }

    private func sectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .black
        return label
    }

    private func makeEnvironmentButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    private func applyEnvironmentButtonStyles() {
        let isDev = Lamps.debugEnvironment == .dev
        styleEnvironmentButton(prdEnvironmentButton, selected: !isDev)
        styleEnvironmentButton(devEnvironmentButton, selected: isDev)
    }

    private func styleEnvironmentButton(_ button: UIButton, selected: Bool) {
        button.backgroundColor = selected ? Self.environmentSelectedColor : Self.environmentNormalColor
        button.setTitleColor(selected ? .white : .darkText, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: selected ? .semibold : .regular)
    }

    private func makeButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.96, alpha: 1)
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    @objc private func close() {
        dismiss(animated: true)
    }

    @objc private func reloadInfo() {
        infoLabel.text = """
        \(Lamps.debugStatusText)
        csj: \(csjToolAvailable ? "可用" : "未集成")
        gdt: \(gdtToolAvailable ? "可用" : "未集成")
        noah: \(noahToolAvailable ? "可用" : "未集成")
        """
        applyEnvironmentButtonStyles()
    }

    @objc private func switchToPrd() {
        switchEnvironment(.prd)
    }

    @objc private func switchToDev() {
        switchEnvironment(.dev)
    }

    private func switchEnvironment(_ environment: LampsSDKEnvironment) {
        guard Lamps.debugEnvironment != environment else { return }
        setEnvironmentButtonsEnabled(false)
        Lamps.debugSwitchEnvironment(environment) { [weak self] success, error in
            guard let self = self else { return }
            self.setEnvironmentButtonsEnabled(true)
            self.reloadInfo()
            let name = environment == .dev ? "测试(dev)" : "正式(prd)"
            if success {
                self.showAlert("已切换到 \(name)")
            } else {
                let reason = error?.localizedDescription ?? "未知错误"
                self.showAlert("已切到 \(name)，配置拉取失败：\(reason)")
            }
        }
    }

    private func setEnvironmentButtonsEnabled(_ enabled: Bool) {
        prdEnvironmentButton.isEnabled = enabled
        devEnvironmentButton.isEnabled = enabled
        prdEnvironmentButton.alpha = enabled ? 1 : 0.6
        devEnvironmentButton.alpha = enabled ? 1 : 0.6
    }

    @objc private func clearConfigCache() {
        guard Lamps.isStarted else {
            showAlert("请先 Lamps.start")
            return
        }
        let ok = Lamps.debugClearConfigCache()
        showAlert(ok ? "已清除 Config 缓存" : "清除失败")
        reloadInfo()
    }

    @objc private func openCSJTool() {
        #if canImport(BUAdTestMeasurement)
        guard let nav = navigationController else { return }
        BUAdTestMeasurementManager.showTestMeasurement(with: nav)
        #else
        showAlert("未集成 Ads-CN/BUAdTestMeasurement（Debug）")
        #endif
    }

    @objc private func openGDTTool() {
        guard LampsGDTDevToolBridge.isAvailable() else {
            showAlert("未集成 GDTDevToolSDK")
            return
        }
        guard let toolVC = LampsGDTDevToolBridge.makeToolViewController() else {
            showAlert("优量汇调试页创建失败")
            return
        }
        navigationController?.pushViewController(toolVC, animated: true)
    }

    @objc private func openNoahTool() {
        guard LampsNoahDevToolBridge.isAvailable() else {
            showAlert("未集成 NoahSDK")
            return
        }
        guard let mockVC = LampsNoahDevToolBridge.makeToolViewController() else {
            showAlert("汇川调试页创建失败")
            return
        }
        mockVC.modalPresentationStyle = .fullScreen
        present(mockVC, animated: true)
    }

    private var csjToolAvailable: Bool {
        #if canImport(BUAdTestMeasurement)
        return true
        #else
        return false
        #endif
    }

    private var gdtToolAvailable: Bool {
        LampsGDTDevToolBridge.isAvailable()
    }

    private var noahToolAvailable: Bool {
        LampsNoahDevToolBridge.isAvailable()
    }

    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "好", style: .default))
        present(alert, animated: true)
    }
}
