import UIKit
import LampsSDK

/// `makeGameCenterView` 测试容器：顶部 Tab + 左右滑动切换列表 / 整页场景。
final class LAMPSSDKGameCenterEmbedViewController: UIViewController,
    UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    private let pages: [UIViewController] = [
        LAMPSSDKGameCenterListViewController(),
        LAMPSSDKGameCenterPageViewController()
    ]

    private lazy var segment: UISegmentedControl = {
        let control = UISegmentedControl(items: ["列表场景", "整页场景"])
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
        title = "makeGameCenterView"
        view.backgroundColor = .white
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

/// 列表使用场景：多行列表，仅其中一个 cell 内嵌 `makeGameCenterView()`。
final class LAMPSSDKGameCenterListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let rowCount = 8
    private let gameViewRow = 1
    private let gameViewRowHeight: CGFloat = 420
    private let plainRowHeight: CGFloat = 88
    private let gameView: UIView?

    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.dataSource = self
        table.delegate = self
        table.estimatedRowHeight = plainRowHeight
        table.backgroundColor = .white
        table.separatorColor = UIColor(white: 0.88, alpha: 1)
        table.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        table.tableFooterView = UIView()
        table.register(LAMPSSDKGameCenterListCell.self, forCellReuseIdentifier: LAMPSSDKGameCenterListCell.reuseId)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "plain")
        return table
    }()

    init() {
        gameView = Lamps.makeGameCenterView()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        gameView = Lamps.makeGameCenterView()
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rowCount
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        indexPath.row == gameViewRow ? gameViewRowHeight : plainRowHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == gameViewRow {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: LAMPSSDKGameCenterListCell.reuseId,
                for: indexPath
            ) as? LAMPSSDKGameCenterListCell ?? LAMPSSDKGameCenterListCell()
            cell.show(gameView)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "plain", for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.text = "普通列表项 \(indexPath.row + 1)"
        cell.textLabel?.font = .systemFont(ofSize: 16)
        cell.textLabel?.textColor = .black
        LAMPSSDKGameCenterEmbed.applyWhiteBackground(to: cell)
        return cell
    }
}

/// 整页使用场景：VC 只展示一个 `makeGameCenterView()`。
final class LAMPSSDKGameCenterPageViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        if let gameView = Lamps.makeGameCenterView() {
            LAMPSSDKGameCenterEmbed.pin(gameView, to: view)
        } else {
            LAMPSSDKGameCenterEmbed.showEmpty(in: view)
        }
    }
}

private enum LAMPSSDKGameCenterEmbed {
    static func pin(_ child: UIView, to parent: UIView) {
        child.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(child)
        NSLayoutConstraint.activate([
            child.topAnchor.constraint(equalTo: parent.topAnchor),
            child.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            child.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
            child.bottomAnchor.constraint(equalTo: parent.bottomAnchor)
        ])
    }

    static func applyWhiteBackground(to cell: UITableViewCell) {
        cell.backgroundColor = .white
        cell.contentView.backgroundColor = .white
        if #available(iOS 14.0, *) {
            var background = UIBackgroundConfiguration.listPlainCell()
            background.backgroundColor = .white
            cell.backgroundConfiguration = background
        }
    }

    static func showEmpty(in parent: UIView) {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "makeGameCenterView 返回 nil\n请先 start 且配置 gameCenterPage"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .gray
        label.font = .systemFont(ofSize: 14)
        parent.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: parent.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: parent.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: parent.leadingAnchor, constant: 24),
            label.trailingAnchor.constraint(lessThanOrEqualTo: parent.trailingAnchor, constant: -24)
        ])
    }
}

private final class LAMPSSDKGameCenterListCell: UITableViewCell {
    static let reuseId = "LAMPSSDKGameCenterListCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        clipsToBounds = true
        LAMPSSDKGameCenterEmbed.applyWhiteBackground(to: self)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        selectionStyle = .none
        clipsToBounds = true
        LAMPSSDKGameCenterEmbed.applyWhiteBackground(to: self)
    }

    func show(_ gameView: UIView?) {
        contentView.subviews.forEach { $0.removeFromSuperview() }

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "  内嵌 makeGameCenterView"
        titleLabel.font = .systemFont(ofSize: 13)
        titleLabel.textColor = .darkGray
        titleLabel.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.96, alpha: 1)
        contentView.addSubview(titleLabel)

        let holder = UIView()
        holder.translatesAutoresizingMaskIntoConstraints = false
        holder.clipsToBounds = true
        contentView.addSubview(holder)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 36),
            holder.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            holder.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            holder.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            holder.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        if let gameView {
            gameView.removeFromSuperview()
            LAMPSSDKGameCenterEmbed.pin(gameView, to: holder)
        } else {
            LAMPSSDKGameCenterEmbed.showEmpty(in: holder)
        }
    }
}
