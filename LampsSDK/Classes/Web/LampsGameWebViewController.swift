import UIKit

/// 游戏 H5 容器：在 `LampsWebViewController` 之上增加右上角关闭按钮。
/// Bridge、加载、导航栏隐藏与 `closePage()` 行为与父类一致。
@objcMembers
public final class LampsGameWebViewController: LampsWebViewController {
    private lazy var closeButton: LampsGameCloseButton = {
        let button = LampsGameCloseButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(closePage), for: .touchUpInside)
        return button
    }()

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 12.5 + 18 + 12.5),
            closeButton.heightAnchor.constraint(equalToConstant: 32),
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 9),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -9)
        ])
    }
}

/// 对齐 `HoopGameWebViewController` 游戏菜单条上的关闭按钮：
/// 18×18 图标、四周 8pt 热区；条高 32、圆角 16、左右 12.5、距屏幕右侧 9。
private final class LampsGameCloseButton: UIButton {
    init() {
        super.init(frame: .zero)
        backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.10)
        layer.cornerRadius = 16
        clipsToBounds = true
        setImage(LampsGameCloseImage.load(), for: .normal)
        accessibilityLabel = "关闭"
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        bounds.insetBy(dx: -8, dy: -8).contains(point)
    }
}

private enum LampsGameCloseImage {
    static func load() -> UIImage {
        if let image = UIImage(named: "full_webview_close", in: resourceBundle, compatibleWith: nil) {
            return image
        }
        return fallbackXMark()
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
        let size = CGSize(width: 18, height: 18)
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
}
