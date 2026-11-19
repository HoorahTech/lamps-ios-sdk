import UIKit
#if LampsADAPTER_SEPARATE_MODULE
@_spi(LampsDevTools) import LampsSDK
#endif

/// 按分类查看 SDK 内存日志：初始化、激励视频、Monitor、行为回调。
final class LampsDevToolsLogViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private struct Filter {
        let title: String
        let category: LampsSDKLogCategory?
    }

    private let filters: [Filter] = [Filter(title: "全部", category: nil)]
        + LampsSDKLogCategory.allCases.map { Filter(title: $0.title, category: $0) }

    private var selectedFilterIndex = 0
    private var entries: [LampsSDKLogEntry] = []
    private var observer: NSObjectProtocol?
    private var filterButtons: [UIButton] = []
    private var lastTableWidth: CGFloat = 0

    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()

    private let filterScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let filterStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var clearButton = LampsDevToolsUI.makeButton(
        title: "清空",
        target: self,
        action: #selector(clearLogs)
    )
    private lazy var copyButton = LampsDevToolsUI.makeButton(
        title: "复制",
        target: self,
        action: #selector(copyLogs)
    )

    private lazy var actionStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [clearButton, copyButton])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 72
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .white
        return tableView
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        label.text = "暂无日志"
        return label
    }()

    deinit {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupFilters()
        setupLayout()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(LampsDevToolsLogCell.self, forCellReuseIdentifier: LampsDevToolsLogCell.reuseID)
        observer = NotificationCenter.default.addObserver(
            forName: LampsSDKLog.didAppendNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.reloadEntries()
        }
        reloadEntries()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let width = tableView.bounds.width
        guard width > 0, abs(width - lastTableWidth) > 0.5 else { return }
        lastTableWidth = width
        tableView.beginUpdates()
        tableView.endUpdates()
    }

    private func setupFilters() {
        for (index, filter) in filters.enumerated() {
            let button = UIButton(type: .custom)
            button.setTitle(filter.title, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
            button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
            button.layer.cornerRadius = 14
            button.tag = index
            button.addTarget(self, action: #selector(filterTapped(_:)), for: .touchUpInside)
            filterButtons.append(button)
            filterStack.addArrangedSubview(button)
        }
        applyFilterStyles()
    }

    private func setupLayout() {
        view.addSubview(filterScrollView)
        filterScrollView.addSubview(filterStack)
        view.addSubview(actionStack)
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        NSLayoutConstraint.activate([
            filterScrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            filterScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filterScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            filterScrollView.heightAnchor.constraint(equalToConstant: 36),
            filterStack.topAnchor.constraint(equalTo: filterScrollView.contentLayoutGuide.topAnchor),
            filterStack.leadingAnchor.constraint(equalTo: filterScrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            filterStack.trailingAnchor.constraint(equalTo: filterScrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            filterStack.bottomAnchor.constraint(equalTo: filterScrollView.contentLayoutGuide.bottomAnchor),
            filterStack.heightAnchor.constraint(equalTo: filterScrollView.frameLayoutGuide.heightAnchor),
            actionStack.topAnchor.constraint(equalTo: filterScrollView.bottomAnchor, constant: 12),
            actionStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            actionStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: actionStack.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            emptyLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(greaterThanOrEqualTo: tableView.leadingAnchor, constant: 24),
            emptyLabel.trailingAnchor.constraint(lessThanOrEqualTo: tableView.trailingAnchor, constant: -24)
        ])
    }

    @objc private func filterTapped(_ sender: UIButton) {
        guard filters.indices.contains(sender.tag), sender.tag != selectedFilterIndex else { return }
        selectedFilterIndex = sender.tag
        applyFilterStyles()
        reloadEntries()
        if !entries.isEmpty {
            tableView.setContentOffset(.zero, animated: false)
        }
    }

    private func applyFilterStyles() {
        for (index, button) in filterButtons.enumerated() {
            let selected = index == selectedFilterIndex
            button.backgroundColor = selected
                ? LampsDevToolsUI.environmentSelectedColor
                : LampsDevToolsUI.environmentNormalColor
            button.setTitleColor(selected ? .white : .darkText, for: .normal)
        }
    }

    private func reloadEntries() {
        let snapshot = LampsSDKLog.snapshot()
        let category = filters[selectedFilterIndex].category
        let matched = category == nil ? snapshot : snapshot.filter { $0.category == category }
        entries = matched.reversed()
        emptyLabel.text = category == nil ? "暂无日志" : "当前分类暂无日志"
        tableView.reloadData()
        emptyLabel.isHidden = !entries.isEmpty
    }

    @objc private func clearLogs() {
        LampsSDKLog.clear()
    }

    @objc private func copyLogs() {
        guard !entries.isEmpty else {
            LampsDevToolsUI.showAlert("没有可复制的日志", from: self)
            return
        }
        let text = entries.reversed().map { entry in
            "\(timeFormatter.string(from: entry.date)) [\(entry.category.title)] \(entry.message)"
        }.joined(separator: "\n")
        UIPasteboard.general.string = text
        LampsDevToolsUI.showAlert("已复制 \(entries.count) 条", from: self)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        entries.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        64
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: LampsDevToolsLogCell.reuseID,
            for: indexPath
        ) as! LampsDevToolsLogCell
        let entry = entries[indexPath.row]
        cell.configure(
            time: timeFormatter.string(from: entry.date),
            category: entry.category.title,
            message: entry.message,
            color: Self.color(for: entry.category)
        )
        return cell
    }

    private static func color(for category: LampsSDKLogCategory) -> UIColor {
        switch category {
        case .startup:
            return UIColor(red: 0.10, green: 0.46, blue: 0.82, alpha: 1)
        case .reward:
            return UIColor(red: 0.85, green: 0.45, blue: 0.12, alpha: 1)
        case .monitor:
            return UIColor(red: 0.13, green: 0.55, blue: 0.32, alpha: 1)
        case .behavior:
            return UIColor(red: 0.45, green: 0.28, blue: 0.72, alpha: 1)
        case .other:
            return UIColor(white: 0.45, alpha: 1)
        }
    }
}

private final class LampsDevToolsLogCell: UITableViewCell {
    static let reuseID = "LampsDevToolsLogCell"

    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .white
        contentView.backgroundColor = .white
        contentView.addSubview(bodyLabel)
        NSLayoutConstraint.activate([
            bodyLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            bodyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bodyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            bodyLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(time: String, category: String, message: String, color: UIColor) {
        let text = NSMutableAttributedString(
            string: "\(time)  \(category)",
            attributes: [
                .font: UIFont.systemFont(ofSize: 12, weight: .semibold),
                .foregroundColor: color
            ]
        )
        let bodyFont: UIFont
        if #available(iOS 13.0, *) {
            bodyFont = .monospacedSystemFont(ofSize: 12, weight: .regular)
        } else {
            bodyFont = .systemFont(ofSize: 12)
        }
        let body = message.isEmpty ? "(空)" : message
        text.append(NSAttributedString(
            string: "\n\(body)",
            attributes: [
                .font: bodyFont,
                .foregroundColor: UIColor.darkText
            ]
        ))
        bodyLabel.attributedText = text
        applyPreferredWidth(contentView.bounds.width)
    }

    override func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        applyPreferredWidth(targetSize.width)
        return super.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: horizontalFittingPriority,
            verticalFittingPriority: verticalFittingPriority
        )
    }

    private func applyPreferredWidth(_ width: CGFloat) {
        let textWidth = max(0, width - 32)
        guard textWidth > 0, bodyLabel.preferredMaxLayoutWidth != textWidth else { return }
        bodyLabel.preferredMaxLayoutWidth = textWidth
    }
}
