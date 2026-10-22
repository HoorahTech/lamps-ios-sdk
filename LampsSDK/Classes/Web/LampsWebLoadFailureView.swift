import UIKit

/// 主文档加载失败时盖在 WebView 上的失败页。成功提交文档后由加载守卫隐藏。
final class LampsWebLoadFailureView: UIView {
    var onRetry: (() -> Void)?
    var onClose: (() -> Void)?

    private let messageLabel = UILabel()
    private let retryButton = LampsWebFailureButton(type: .custom)
    private let closeButton = LampsWebFailureButton(type: .custom)
    private let buttonRow = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        isHidden = true

        messageLabel.text = "网络异常，请检查网络后重试"
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0

        configure(retryButton, title: "重试", action: #selector(retryTapped))
        configure(closeButton, title: "关闭", action: #selector(closeTapped))

        buttonRow.axis = .horizontal
        buttonRow.alignment = .center
        buttonRow.spacing = 12
        buttonRow.addArrangedSubview(retryButton)
        buttonRow.addArrangedSubview(closeButton)

        let stack = UIStackView(arrangedSubviews: [messageLabel, buttonRow])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -32),
            messageLabel.widthAnchor.constraint(equalTo: widthAnchor, constant: -64),
            retryButton.widthAnchor.constraint(equalToConstant: 120),
            retryButton.heightAnchor.constraint(equalToConstant: 40),
            closeButton.widthAnchor.constraint(equalTo: retryButton.widthAnchor),
            closeButton.heightAnchor.constraint(equalTo: retryButton.heightAnchor)
        ])

        apply(mode: .day, showsClose: false)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setMessage(_ message: String) {
        messageLabel.text = message
    }

    func apply(mode: LampsDayNightMode, showsClose: Bool) {
        let palette = Palette(mode)
        backgroundColor = palette.background
        messageLabel.textColor = palette.text
        stylePrimary(retryButton, palette: palette)
        styleSecondary(closeButton, palette: palette)
        closeButton.isHidden = !showsClose
    }

    private func configure(_ button: UIButton, title: String, action: Selector) {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.addTarget(self, action: action, for: .touchUpInside)
    }

    private func stylePrimary(_ button: UIButton, palette: Palette) {
        button.backgroundColor = palette.primaryBackground
        button.setTitleColor(palette.primaryTitle, for: .normal)
        button.layer.borderWidth = 0
    }

    private func styleSecondary(_ button: UIButton, palette: Palette) {
        button.backgroundColor = .clear
        button.setTitleColor(palette.text, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = palette.border.cgColor
    }

    @objc private func retryTapped() {
        onRetry?()
    }

    @objc private func closeTapped() {
        onClose?()
    }
}

private final class LampsWebFailureButton: UIButton {
    override var isHighlighted: Bool {
        didSet { alpha = isHighlighted ? 0.65 : 1 }
    }
}

private struct Palette {
    let background: UIColor
    let text: UIColor
    let primaryBackground: UIColor
    let primaryTitle: UIColor
    let border: UIColor

    init(_ mode: LampsDayNightMode) {
        switch mode {
        case .day:
            background = LampsColor.color(fromHex: "#FFFFFF") ?? .white
            text = LampsColor.color(fromHex: "#2F3033") ?? .black
            primaryBackground = LampsColor.color(fromHex: "#2F3033") ?? .black
            primaryTitle = .white
            border = LampsColor.color(fromHex: "#D8D8D8") ?? .lightGray
        case .night:
            background = LampsColor.color(fromHex: "#141218") ?? .black
            text = LampsColor.color(fromHex: "#F5F5F7") ?? .white
            primaryBackground = LampsColor.color(fromHex: "#F5F5F7") ?? .white
            primaryTitle = LampsColor.color(fromHex: "#141218") ?? .black
            border = LampsColor.color(fromHex: "#3D3A44") ?? .darkGray
        }
    }
}
