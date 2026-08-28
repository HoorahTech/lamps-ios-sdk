import UIKit

/// 游戏菜单条：更多 + 分割线 + 关闭。
/// 悬浮跟手拖拽，松手按左右距离吸边；静止 3s 收成贴边半圆弧，点击再展开。
final class LampsGameMenuBar: UIView {
    var onClose: (() -> Void)?
    var onRestart: (() -> Void)?

    private let expandedContent = UIView()
    private let moreButton = LampsGameBarButton()
    private let closeButton = LampsGameBarButton()
    private let divider = UIView()
    private let handleView = UIImageView()
    private weak var overlayView: UIView?
    private weak var dropdownView: UIView?

    private var dockEdge: DockEdge = .right
    private var isCollapsed = false
    private var isDragging = false
    private var needsInitialPlacement = true
    private var lastSuperviewSize: CGSize = .zero
    private var panStartCenter: CGPoint = .zero
    private var collapseTimer: Timer?
    private let expandButton = UIButton(type: .custom)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        stopCollapseTimer()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window == nil {
            dismissDropdown(animated: false)
            stopCollapseTimer()
        } else {
            scheduleCollapse()
        }
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        bounds.insetBy(dx: -Metrics.hitSlop, dy: -Metrics.hitSlop).contains(point)
    }

    /// 宿主 `viewDidLayoutSubviews` 时调用：首次落到右上角，旋转后保持吸边。
    func relayoutForSuperviewBoundsChange() {
        guard !isDragging, let superview, superview.bounds.width > 0, superview.bounds.height > 0 else { return }
        if needsInitialPlacement {
            needsInitialPlacement = false
            lastSuperviewSize = superview.bounds.size
            dockEdge = .right
            isCollapsed = false
            frame = CGRect(
                x: 0,
                y: superview.safeAreaInsets.top + Metrics.edgeMargin,
                width: Metrics.expandedSize.width,
                height: Metrics.expandedSize.height
            )
            frame = dockedFrame(tucked: false, in: superview)
            isHidden = false
            scheduleCollapse()
            return
        }
        guard superview.bounds.size != lastSuperviewSize else { return }
        lastSuperviewSize = superview.bounds.size
        frame = dockedFrame(tucked: isCollapsed, in: superview)
    }

    private func setup() {
        isHidden = true
        bounds.size = Metrics.expandedSize
        backgroundColor = Metrics.barBackground
        layer.cornerRadius = Metrics.barHeight / 2
        clipsToBounds = true

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        addGestureRecognizer(pan)

        expandedContent.translatesAutoresizingMaskIntoConstraints = false
        addSubview(expandedContent)

        moreButton.setImage(LampsGameMenuImage.load("full_webview_more", fallback: .more), for: .normal)
        moreButton.accessibilityLabel = "更多"
        moreButton.addTarget(self, action: #selector(moreTapped), for: .touchUpInside)

        closeButton.setImage(LampsGameMenuImage.load("full_webview_close", fallback: .close), for: .normal)
        closeButton.accessibilityLabel = "关闭"
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)

        divider.backgroundColor = UIColor(red: 227 / 255, green: 227 / 255, blue: 227 / 255, alpha: 0.10)

        handleView.translatesAutoresizingMaskIntoConstraints = false
        handleView.contentMode = .center
        handleView.alpha = 0
        handleView.isUserInteractionEnabled = false
        addSubview(handleView)
        updateHandleImage()

        expandButton.translatesAutoresizingMaskIntoConstraints = false
        expandButton.accessibilityLabel = "展开菜单"
        expandButton.addTarget(self, action: #selector(expand), for: .touchUpInside)
        expandButton.isUserInteractionEnabled = false
        addSubview(expandButton)

        [moreButton, divider, closeButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            expandedContent.addSubview($0)
        }

        NSLayoutConstraint.activate([
            expandedContent.leadingAnchor.constraint(equalTo: leadingAnchor),
            expandedContent.centerYAnchor.constraint(equalTo: centerYAnchor),
            expandedContent.widthAnchor.constraint(equalToConstant: Metrics.expandedWidth),
            expandedContent.heightAnchor.constraint(equalToConstant: Metrics.barHeight),

            moreButton.widthAnchor.constraint(equalToConstant: Metrics.iconSize),
            moreButton.heightAnchor.constraint(equalToConstant: Metrics.iconSize),
            moreButton.leadingAnchor.constraint(equalTo: expandedContent.leadingAnchor, constant: Metrics.horizontalPadding),
            moreButton.centerYAnchor.constraint(equalTo: expandedContent.centerYAnchor),

            divider.widthAnchor.constraint(equalToConstant: Metrics.dividerWidth),
            divider.heightAnchor.constraint(equalToConstant: Metrics.dividerHeight),
            divider.leadingAnchor.constraint(equalTo: moreButton.trailingAnchor, constant: Metrics.iconGap),
            divider.centerYAnchor.constraint(equalTo: expandedContent.centerYAnchor),

            closeButton.widthAnchor.constraint(equalToConstant: Metrics.iconSize),
            closeButton.heightAnchor.constraint(equalToConstant: Metrics.iconSize),
            closeButton.leadingAnchor.constraint(equalTo: divider.trailingAnchor, constant: Metrics.iconGap),
            closeButton.trailingAnchor.constraint(equalTo: expandedContent.trailingAnchor, constant: -Metrics.horizontalPadding),
            closeButton.centerYAnchor.constraint(equalTo: expandedContent.centerYAnchor),

            handleView.centerXAnchor.constraint(equalTo: centerXAnchor),
            handleView.centerYAnchor.constraint(equalTo: centerYAnchor),
            handleView.widthAnchor.constraint(equalToConstant: Metrics.handleSize.width),
            handleView.heightAnchor.constraint(equalToConstant: Metrics.handleSize.height),

            expandButton.topAnchor.constraint(equalTo: topAnchor),
            expandButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            expandButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            expandButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let superview else { return }
        switch gesture.state {
        case .began:
            isDragging = true
            panStartCenter = center
            stopCollapseTimer()
            dismissDropdown(animated: true)
            layer.removeAllAnimations()
        case .changed:
            let translation = gesture.translation(in: superview)
            var next = frame
            next.origin.x = panStartCenter.x + translation.x - next.width / 2
            next.origin.y = panStartCenter.y + translation.y - next.height / 2
            frame = clampToSuperview(next, in: superview)
            updateDockEdge(in: superview)
        case .ended, .cancelled, .failed:
            isDragging = false
            updateDockEdge(in: superview)
            snapToDock()
            if !isCollapsed {
                scheduleCollapse()
            }
        default:
            break
        }
    }

    @objc private func closeTapped() {
        stopCollapseTimer()
        dismissDropdown(animated: true)
        onClose?()
    }

    @objc private func moreTapped() {
        if overlayView != nil {
            dismissDropdown(animated: true)
            scheduleCollapse()
            return
        }
        stopCollapseTimer()
        presentDropdown()
    }

    private func presentDropdown() {
        guard let host = superview else { return }
        let overlay = UIControl()
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.addTarget(self, action: #selector(overlayTapped), for: .touchUpInside)

        let dropdown = LampsGameMenuDropdownView()
        dropdown.translatesAutoresizingMaskIntoConstraints = false
        dropdown.onExit = { [weak self] in
            self?.dismissDropdown(animated: true)
            self?.onClose?()
        }
        dropdown.onRestart = { [weak self] in
            self?.dismissDropdown(animated: true)
            self?.onRestart?()
        }

        host.insertSubview(overlay, belowSubview: self)
        host.addSubview(dropdown)
        overlayView = overlay
        dropdownView = dropdown

        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: host.topAnchor),
            overlay.leadingAnchor.constraint(equalTo: host.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: host.trailingAnchor),
            overlay.bottomAnchor.constraint(equalTo: host.bottomAnchor),

            dropdown.topAnchor.constraint(equalTo: host.topAnchor, constant: frame.maxY + Metrics.dropdownGap),
            dropdown.leadingAnchor.constraint(equalTo: host.leadingAnchor, constant: frame.minX),
            dropdown.widthAnchor.constraint(equalToConstant: frame.width)
        ])

        dropdown.alpha = 0
        dropdown.transform = CGAffineTransform(translationX: 0, y: -4)
        UIView.animate(withDuration: 0.15) {
            dropdown.alpha = 1
            dropdown.transform = .identity
        }
    }

    @objc private func overlayTapped() {
        dismissDropdown(animated: true)
        scheduleCollapse()
    }

    private func dismissDropdown(animated: Bool) {
        let overlay = overlayView
        let dropdown = dropdownView
        overlayView = nil
        dropdownView = nil
        let remove = {
            overlay?.removeFromSuperview()
            dropdown?.removeFromSuperview()
        }
        guard animated, dropdown != nil else {
            remove()
            return
        }
        UIView.animate(withDuration: 0.12, animations: {
            dropdown?.alpha = 0
        }, completion: { _ in
            remove()
        })
    }

    private func stopCollapseTimer() {
        collapseTimer?.invalidate()
        collapseTimer = nil
    }

    private func scheduleCollapse() {
        stopCollapseTimer()
        guard canCollapse else { return }
        let timer = Timer(timeInterval: Metrics.collapseDelay, repeats: false) { [weak self] _ in
            self?.collapseIfNeeded()
        }
        RunLoop.main.add(timer, forMode: .common)
        collapseTimer = timer
    }

    private var canCollapse: Bool {
        !isCollapsed && !isDragging && overlayView == nil && window != nil && !needsInitialPlacement
    }

    private func collapseIfNeeded() {
        guard canCollapse, let superview else { return }
        let target = dockedFrame(tucked: true, in: superview)
        isCollapsed = true
        moreButton.isUserInteractionEnabled = false
        closeButton.isUserInteractionEnabled = false
        expandButton.isUserInteractionEnabled = true
        updateCollapsedAppearance()
        UIView.animate(
            withDuration: 0.28,
            delay: 0,
            options: [.curveEaseInOut, .beginFromCurrentState, .allowUserInteraction]
        ) {
            self.frame = target
            self.expandedContent.alpha = 0
            self.handleView.alpha = 1
            self.layoutIfNeeded()
        }
    }

    @objc private func expand() {
        guard isCollapsed, let superview else { return }
        let target = dockedFrame(tucked: false, in: superview)
        isCollapsed = false
        moreButton.isUserInteractionEnabled = true
        closeButton.isUserInteractionEnabled = true
        expandButton.isUserInteractionEnabled = false
        updateCollapsedAppearance()
        UIView.animate(
            withDuration: 0.28,
            delay: 0,
            options: [.curveEaseInOut, .beginFromCurrentState, .allowUserInteraction]
        ) {
            self.frame = target
            self.expandedContent.alpha = 1
            self.handleView.alpha = 0
            self.layoutIfNeeded()
        } completion: { finished in
            guard finished else { return }
            self.scheduleCollapse()
        }
    }

    private func snapToDock() {
        guard let superview else { return }
        let target = dockedFrame(tucked: isCollapsed, in: superview)
        UIView.animate(
            withDuration: 0.28,
            delay: 0,
            usingSpringWithDamping: 0.86,
            initialSpringVelocity: 0.4,
            options: [.allowUserInteraction, .beginFromCurrentState]
        ) {
            self.frame = target
        }
    }

    private func updateDockEdge(in superview: UIView) {
        dockEdge = center.x < superview.bounds.midX ? .left : .right
        updateHandleImage()
        updateCollapsedAppearance()
    }

    private func updateHandleImage() {
        handleView.image = LampsGameMenuImage.chevron(pointing: dockEdge == .right ? .left : .right)
    }

    private func updateCollapsedAppearance() {
        if isCollapsed {
            layer.maskedCorners = dockEdge == .left
                ? [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
                : [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        } else {
            layer.maskedCorners = [
                .layerMinXMinYCorner, .layerMinXMaxYCorner,
                .layerMaxXMinYCorner, .layerMaxXMaxYCorner
            ]
        }
    }

    private func dockedFrame(tucked: Bool, in superview: UIView) -> CGRect {
        let size = tucked ? Metrics.collapsedSize : Metrics.expandedSize
        let margin: CGFloat = tucked ? 0 : Metrics.edgeMargin
        var next = CGRect(origin: .zero, size: size)
        next.origin.y = frame.midY - size.height / 2
        next.origin.x = dockEdge == .left
            ? margin
            : superview.bounds.width - size.width - margin
        return clampVertical(next, in: superview)
    }

    private func clampToSuperview(_ proposed: CGRect, in superview: UIView) -> CGRect {
        var next = clampVertical(proposed, in: superview)
        let margin: CGFloat = isCollapsed ? 0 : Metrics.edgeMargin
        let minX = margin
        let maxX = superview.bounds.width - next.width - margin
        next.origin.x = minX <= maxX ? min(max(next.origin.x, minX), maxX) : minX
        return next
    }

    private func clampVertical(_ proposed: CGRect, in superview: UIView) -> CGRect {
        var next = proposed
        let minY = superview.safeAreaInsets.top + Metrics.edgeMargin
        let maxY = superview.bounds.height - superview.safeAreaInsets.bottom - next.height - Metrics.edgeMargin
        next.origin.y = minY <= maxY ? min(max(next.origin.y, minY), maxY) : minY
        return next
    }
}

private enum DockEdge {
    case left
    case right
}

private enum Metrics {
    static let barHeight: CGFloat = 32
    static let iconSize: CGFloat = 18
    static let horizontalPadding: CGFloat = 12.5
    static let iconGap: CGFloat = 8
    static let dividerWidth: CGFloat = 0.5
    static let dividerHeight: CGFloat = 19
    static let dropdownGap: CGFloat = 8
    static let dropdownItemHeight: CGFloat = 40
    static let hitSlop: CGFloat = 8
    static let edgeMargin: CGFloat = 9
    static let collapseDelay: TimeInterval = 3
    static let collapsedStem: CGFloat = 20
    static let collapsedWidth: CGFloat = barHeight / 2 + collapsedStem
    static let collapsedSize = CGSize(width: collapsedWidth, height: barHeight)
    static let handleSize = CGSize(width: 12, height: 14)
    static let expandedWidth: CGFloat = horizontalPadding * 2 + iconSize * 2 + iconGap * 2 + dividerWidth
    static let expandedSize = CGSize(width: expandedWidth, height: barHeight)
    static let barBackground = UIColor(red: 0, green: 0, blue: 0, alpha: 0.10)
}

/// 18×18 图标，四周各扩 8pt 热区，对齐 `setEnlargeEdgeWithTop:8`。
private final class LampsGameBarButton: UIButton {
    init() {
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        bounds.insetBy(dx: -Metrics.hitSlop, dy: -Metrics.hitSlop).contains(point)
    }
}

private final class LampsGameMenuDropdownView: UIView {
    var onExit: (() -> Void)?
    var onRestart: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.65)
        layer.cornerRadius = 10
        clipsToBounds = true

        let exitItem = makeItem(title: "退出", action: #selector(exitTapped))
        let restartItem = makeItem(title: "重启", action: #selector(restartTapped))
        let line = UIView()
        line.backgroundColor = UIColor(white: 1, alpha: 0.10)
        line.translatesAutoresizingMaskIntoConstraints = false

        addSubview(exitItem)
        addSubview(line)
        addSubview(restartItem)

        NSLayoutConstraint.activate([
            exitItem.topAnchor.constraint(equalTo: topAnchor),
            exitItem.leadingAnchor.constraint(equalTo: leadingAnchor),
            exitItem.trailingAnchor.constraint(equalTo: trailingAnchor),
            exitItem.heightAnchor.constraint(equalToConstant: Metrics.dropdownItemHeight),

            line.topAnchor.constraint(equalTo: exitItem.bottomAnchor),
            line.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            line.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            line.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale),

            restartItem.topAnchor.constraint(equalTo: line.bottomAnchor),
            restartItem.leadingAnchor.constraint(equalTo: leadingAnchor),
            restartItem.trailingAnchor.constraint(equalTo: trailingAnchor),
            restartItem.bottomAnchor.constraint(equalTo: bottomAnchor),
            restartItem.heightAnchor.constraint(equalToConstant: Metrics.dropdownItemHeight)
        ])
    }

    private func makeItem(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    @objc private func exitTapped() {
        onExit?()
    }

    @objc private func restartTapped() {
        onRestart?()
    }
}

private enum LampsGameMenuImage {
    enum Fallback {
        case close
        case more
    }

    enum ChevronDirection {
        case left
        case right
    }

    static func load(_ name: String, fallback: Fallback) -> UIImage {
        if let image = UIImage(named: name, in: resourceBundle, compatibleWith: nil) {
            return image
        }
        switch fallback {
        case .close:
            return fallbackXMark()
        case .more:
            return fallbackEllipsis()
        }
    }

    static func chevron(pointing direction: ChevronDirection) -> UIImage {
        let size = Metrics.handleSize
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            let path = UIBezierPath()
            let insetX: CGFloat = 3
            let insetY: CGFloat = 2.5
            switch direction {
            case .left:
                path.move(to: CGPoint(x: size.width - insetX, y: insetY))
                path.addLine(to: CGPoint(x: insetX + 0.5, y: size.height / 2))
                path.addLine(to: CGPoint(x: size.width - insetX, y: size.height - insetY))
            case .right:
                path.move(to: CGPoint(x: insetX, y: insetY))
                path.addLine(to: CGPoint(x: size.width - insetX - 0.5, y: size.height / 2))
                path.addLine(to: CGPoint(x: insetX, y: size.height - insetY))
            }
            path.lineWidth = 1.6
            path.lineCapStyle = .round
            path.lineJoinStyle = .round
            UIColor.white.setStroke()
            path.stroke()
        }.withRenderingMode(.alwaysOriginal)
    }

    private static var resourceBundle: Bundle {
        let parents = [Bundle(for: Lamps.self), Bundle.main]
        for parent in parents {
            if let url = parent.url(forResource: "LampsSDKResources", withExtension: "bundle"),
               let bundle = Bundle(url: url) {
                return bundle
            }
        }
        return Bundle(for: Lamps.self)
    }

    private static func fallbackXMark() -> UIImage {
        let size = CGSize(width: Metrics.iconSize, height: Metrics.iconSize)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            let inset: CGFloat = 3.5
            let path = UIBezierPath()
            path.move(to: CGPoint(x: inset, y: inset))
            path.addLine(to: CGPoint(x: size.width - inset, y: size.height - inset))
            path.move(to: CGPoint(x: size.width - inset, y: inset))
            path.addLine(to: CGPoint(x: inset, y: size.height - inset))
            path.lineWidth = 1.6
            path.lineCapStyle = .round
            UIColor.white.setStroke()
            path.stroke()
        }
    }

    private static func fallbackEllipsis() -> UIImage {
        let size = CGSize(width: Metrics.iconSize, height: Metrics.iconSize)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            UIColor.white.setFill()
            let diameter: CGFloat = 2.5
            let spacing: CGFloat = 3.5
            let total = diameter * 3 + spacing * 2
            var x = (size.width - total) / 2
            let y = (size.height - diameter) / 2
            for _ in 0..<3 {
                UIBezierPath(ovalIn: CGRect(x: x, y: y, width: diameter, height: diameter)).fill()
                x += diameter + spacing
            }
        }
    }
}
