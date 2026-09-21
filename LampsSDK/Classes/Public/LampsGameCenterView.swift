import UIKit

/// `makeGameCenterView` 返回的内嵌游戏中心容器。内部是 WebView，对外提供日夜间更新。
///
/// 接入方自有日夜间（不跟系统 Dark Mode）变化时调用 `updateDayNightMode`，无需重建本视图。
@objcMembers
public final class LampsGameCenterView: UIView {
    /// 当前日夜间。创建时取自本次 `LampsGameCenterConfig` 或 `Lamps.start` 配置。
    public private(set) var dayNightMode: LampsDayNightMode

    private let webView: LampsWebView

    init(webView: LampsWebView) {
        self.webView = webView
        self.dayNightMode = Lamps.resolvedDayNightMode(webView.dayNightMode)
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: topAnchor),
            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 更新日夜间，并 Native → H5 派发 `lamps.common.onnightmodechange`。
    /// 参数 `{ "night": 0|1 }`，取值与 `lamps.common.bridgeReady` 的 `night` 一致。
    /// 与当前值相同则不重复通知。H5 尚未 `bridgeReady` 时事件可能丢失，随后 `bridgeReady` 会带回最新值。
    @objc(updateDayNightMode:)
    public func updateDayNightMode(_ mode: LampsDayNightMode) {
        guard dayNightMode != mode else { return }
        dayNightMode = mode
        webView.applyDayNightMode(mode)
    }
}
