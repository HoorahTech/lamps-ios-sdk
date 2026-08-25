import UIKit
#if LampsADAPTER_SEPARATE_MODULE
@_spi(LampsDevTools) import LampsSDK
#endif
#if canImport(BUAdTestMeasurement)
import BUAdTestMeasurement
#endif

/// 聚合 Lamps 自身调试信息与穿山甲 / 优量汇 / 汇川调试入口。
final class LampsDevToolsViewController: UIViewController,
    UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    private let pages: [UIViewController] = [
        LampsDevToolsSDKViewController(),
        LampsDevToolsThirdPartyViewController()
    ]

    private lazy var segment: UISegmentedControl = {
        let control = UISegmentedControl(items: ["LampsSDK", "三方 SDK"])
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        control.translatesAutoresizingMaskIntoConstraints = false
        control.setTitleTextAttributes([
            .font: UIFont.systemFont(ofSize: 14, weight: .regular),
            .foregroundColor: UIColor.darkGray
        ], for: .normal)
        control.setTitleTextAttributes([
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
            .foregroundColor: UIColor.black
        ], for: .selected)
        if #available(iOS 13.0, *) {
            control.selectedSegmentTintColor = .white
            control.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.96, alpha: 1)
        }
        return control
    }()

    private lazy var headerView: UIView = {
        let header = UIView()
        header.translatesAutoresizingMaskIntoConstraints = false
        header.backgroundColor = .white
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = UIColor(white: 0.9, alpha: 1)
        header.addSubview(segment)
        header.addSubview(line)
        NSLayoutConstraint.activate([
            segment.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            segment.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 20),
            segment.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -20),
            segment.heightAnchor.constraint(equalToConstant: 32),
            line.heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale),
            line.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            line.trailingAnchor.constraint(equalTo: header.trailingAnchor),
            line.bottomAnchor.constraint(equalTo: header.bottomAnchor)
        ])
        return header
    }()

    private lazy var pageController: UIPageViewController = {
        let controller = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
        controller.dataSource = self
        controller.delegate = self
        return controller
    }()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        }
        return .default
    }

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
        view.addSubview(headerView)

        addChild(pageController)
        pageController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageController.view)
        pageController.didMove(toParent: self)
        pageController.setViewControllers([pages[0]], direction: .forward, animated: false)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 48),
            pageController.view.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            pageController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func close() {
        if presentingViewController != nil {
            dismiss(animated: true)
            return
        }
        navigationController?.popViewController(animated: true)
    }

    @objc private func segmentChanged() {
        showPage(at: segment.selectedSegmentIndex, animated: true)
    }

    private func showPage(at index: Int, animated: Bool) {
        guard pages.indices.contains(index) else { return }
        let currentIndex = pages.firstIndex(of: pageController.viewControllers?.first ?? pages[0]) ?? 0
        guard currentIndex != index else { return }
        let direction: UIPageViewController.NavigationDirection = index > currentIndex ? .forward : .reverse
        pageController.setViewControllers([pages[index]], direction: direction, animated: animated)
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index > 0 else { return nil }
        return pages[index - 1]
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index < pages.count - 1 else { return nil }
        return pages[index + 1]
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard completed,
              let current = pageViewController.viewControllers?.first,
              let index = pages.firstIndex(of: current) else { return }
        segment.selectedSegmentIndex = index
    }
}

/// LampsSDK：基本信息、全局配置、环境切换。
final class LampsDevToolsSDKViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .fill
        return stack
    }()

    private lazy var basicInfoLabel = LampsDevToolsUI.makeInfoLabel()
    private lazy var configInfoLabel = LampsDevToolsUI.makeInfoLabel()

    private lazy var prdEnvironmentButton: UIButton = LampsDevToolsUI.makeEnvironmentButton(
        title: "正式 prd",
        target: self,
        action: #selector(switchToPrd)
    )
    private lazy var devEnvironmentButton: UIButton = LampsDevToolsUI.makeEnvironmentButton(
        title: "测试 dev",
        target: self,
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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        reloadInfo()
    }

    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40)
        ])

        stackView.addArrangedSubview(LampsDevToolsUI.sectionTitle("基本信息"))
        stackView.addArrangedSubview(LampsDevToolsUI.makeCard(basicInfoLabel))
        stackView.addArrangedSubview(LampsDevToolsUI.sectionTitle("全局配置"))
        stackView.addArrangedSubview(LampsDevToolsUI.makeCard(configInfoLabel))
        stackView.addArrangedSubview(environmentButtonStack)
        stackView.addArrangedSubview(environmentHintLabel)
        stackView.addArrangedSubview(LampsDevToolsUI.makeButton(title: "刷新状态", target: self, action: #selector(reloadInfo)))
        stackView.addArrangedSubview(LampsDevToolsUI.makeButton(title: "清除 Config 磁盘缓存", target: self, action: #selector(clearConfigCache)))
    }

    @objc private func reloadInfo() {
        basicInfoLabel.text = Lamps.debugBasicStatusText
        configInfoLabel.text = Lamps.debugConfigStatusText
        applyEnvironmentButtonStyles()
    }

    private func applyEnvironmentButtonStyles() {
        let isDev = Lamps.debugEnvironment == .dev
        LampsDevToolsUI.styleEnvironmentButton(prdEnvironmentButton, selected: !isDev)
        LampsDevToolsUI.styleEnvironmentButton(devEnvironmentButton, selected: isDev)
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

    private func showAlert(_ message: String) {
        LampsDevToolsUI.showAlert(message, from: self)
    }
}

/// 三方广告 SDK：集成状态与调试入口。
final class LampsDevToolsThirdPartyViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .fill
        return stack
    }()

    private lazy var statusLabel = LampsDevToolsUI.makeInfoLabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        reloadStatus()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadStatus()
    }

    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40)
        ])

        stackView.addArrangedSubview(LampsDevToolsUI.sectionTitle("集成状态"))
        stackView.addArrangedSubview(LampsDevToolsUI.makeCard(statusLabel))
        stackView.addArrangedSubview(LampsDevToolsUI.sectionTitle("调试入口"))
        stackView.addArrangedSubview(LampsDevToolsUI.makeButton(title: "穿山甲测试工具", target: self, action: #selector(openCSJTool)))
        stackView.addArrangedSubview(LampsDevToolsUI.makeButton(title: "优量汇测试工具", target: self, action: #selector(openGDTTool)))
        stackView.addArrangedSubview(LampsDevToolsUI.makeButton(title: "汇川测试工具", target: self, action: #selector(openNoahTool)))
    }

    private func reloadStatus() {
        statusLabel.text = """
        csj: \(isClassLinked("BUAdSDKManager") ? "已集成" : "未集成")
        gdt: \(isClassLinked("GDTSDKConfig") ? "已集成" : "未集成")
        noah: \(isClassLinked("NASDKManager") ? "已集成" : "未集成")
        """
    }

    @objc private func openCSJTool() {
        guard isClassLinked("BUAdTestMeasurementManager") else {
            showAlert("未集成穿山甲测试工具（Ads-CN/BUAdTestMeasurement）")
            return
        }
        #if canImport(BUAdTestMeasurement)
        guard let nav = navigationController else { return }
        BUAdTestMeasurementManager.showTestMeasurement(with: nav)
        #else
        showAlert("未集成穿山甲测试工具（Ads-CN/BUAdTestMeasurement）")
        #endif
    }

    @objc private func openGDTTool() {
        guard LampsGDTDevTool.isAvailable else {
            showAlert("未集成优量汇测试工具（GDTDevToolSDK）")
            return
        }
        guard let toolVC = LampsGDTDevTool.makeToolViewController() else {
            showAlert("优量汇调试页创建失败")
            return
        }
        navigationController?.pushViewController(toolVC, animated: true)
    }

    @objc private func openNoahTool() {
        guard LampsNoahDevTool.isAvailable else {
            showAlert("未集成汇川调试页（NAAdExternalMockViewController）")
            return
        }
        guard let mockVC = LampsNoahDevTool.makeToolViewController() else {
            showAlert("汇川调试页创建失败")
            return
        }
        mockVC.modalPresentationStyle = .fullScreen
        present(mockVC, animated: true)
    }

    private func isClassLinked(_ className: String) -> Bool {
        NSClassFromString(className) != nil
    }

    private func showAlert(_ message: String) {
        LampsDevToolsUI.showAlert(message, from: self)
    }
}

private enum LampsDevToolsUI {
    static let environmentSelectedColor = UIColor(red: 0.10, green: 0.46, blue: 0.82, alpha: 1)
    static let environmentNormalColor = UIColor(red: 0.95, green: 0.95, blue: 0.96, alpha: 1)

    static func sectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .black
        return label
    }

    static func makeInfoLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        if #available(iOS 13.0, *) {
            label.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        } else {
            label.font = .systemFont(ofSize: 13)
        }
        label.textColor = .darkText
        return label
    }

    static func makeCard(_ content: UIView) -> UIView {
        let card = UIView()
        card.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.97, alpha: 1)
        card.layer.cornerRadius = 8
        content.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(content)
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            content.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            content.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            content.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12)
        ])
        return card
    }

    static func makeButton(title: String, target: Any, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.96, alpha: 1)
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        button.addTarget(target, action: action, for: .touchUpInside)
        return button
    }

    static func makeEnvironmentButton(title: String, target: Any, action: Selector) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        button.addTarget(target, action: action, for: .touchUpInside)
        return button
    }

    static func styleEnvironmentButton(_ button: UIButton, selected: Bool) {
        button.backgroundColor = selected ? environmentSelectedColor : environmentNormalColor
        button.setTitleColor(selected ? .white : .darkText, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: selected ? .semibold : .regular)
    }

    static func showAlert(_ message: String, from viewController: UIViewController) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "好", style: .default))
        viewController.present(alert, animated: true)
    }
}
