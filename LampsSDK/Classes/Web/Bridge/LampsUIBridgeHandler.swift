import Foundation
import UIKit

/// UI 相关 Bridge：关闭 H5 页、状态栏等。
@objcMembers
final class LampsUIBridgeHandler: NSObject, LampsBridgeHandler {
    weak var bridge: LampsBridge?

    var supportedMethods: [String] {
        [Method.pageClose, Method.statusBar]
    }

    func handle(
        method: String,
        data: [AnyHashable: Any],
        success: LampsBridgeToH5Callback?,
        error: LampsBridgeToH5Callback?
    ) {
        switch method {
        case Method.pageClose:
            closePage(success: success, error: error)
        case Method.statusBar:
            applyStatusBar(data: data, success: success, error: error)
        default:
            error?(["msg": "unsupported method: \(method)"])
        }
    }
}

private extension LampsUIBridgeHandler {
    enum Method {
        static let pageClose = "lamps.ui.pageclose"
        static let statusBar = "lamps.common.statusBar"
    }

    enum StatusBarKey {
        static let showStatusBar = "showStatusBar"
        static let immersive = "statusBarImmersive"
        static let backgroundColor = "backgroundColor"
        static let fontStyle = "statusBarFontStyle"
    }

    func applyStatusBar(
        data: [AnyHashable: Any],
        success: LampsBridgeToH5Callback?,
        error: LampsBridgeToH5Callback?
    ) {
        guard let page = hostViewController() as? LampsWebViewController else {
            LampsSDKLog.debug("bridge common.statusBar skip: no LampsWebViewController")
            error?(["msg": "找不到 LampsWebViewController 容器"])
            return
        }

        let showStatusBar = LampsJSONValue.boolValue(data[StatusBarKey.showStatusBar], default: true)
        let immersive = LampsJSONValue.boolValue(data[StatusBarKey.immersive], default: true)
        let fontStyle = LampsJSONValue.intValue(data[StatusBarKey.fontStyle], default: 1)
        let colorText = LampsJSONValue.stringValue(data[StatusBarKey.backgroundColor], trim: true)
        let backgroundColor: UIColor?
        if colorText.isEmpty {
            backgroundColor = nil
        } else if let color = UIColor.lamps_color(fromHex: colorText) {
            backgroundColor = color
        } else {
            LampsSDKLog.debug("bridge common.statusBar ignore invalid backgroundColor=\(colorText)")
            backgroundColor = nil
        }

        LampsSDKLog.debug(
            "bridge common.statusBar show=\(showStatusBar) immersive=\(immersive) fontStyle=\(fontStyle) bg=\(colorText)"
        )
        page.applyStatusBar(
            showStatusBar: showStatusBar,
            immersive: immersive,
            backgroundColor: backgroundColor,
            fontStyle: fontStyle
        )
        success?(["msg": "success"])
    }

    func closePage(success: LampsBridgeToH5Callback?, error: LampsBridgeToH5Callback?) {
        if let closeHandler = bridge?.webView?.closeHandler {
            LampsSDKLog.debug("bridge ui.pageclose via closeHandler")
            success?(["msg": "success"])
            closeHandler()
            return
        }

        guard let host = hostViewController() else {
            LampsSDKLog.debug("bridge ui.pageclose skip: no host vc")
            error?(["msg": "无法关闭页面"])
            return
        }

        LampsSDKLog.debug("bridge ui.pageclose via host vc")
        success?(["msg": "success"])
        closeHost(host)
    }

    func closeHost(_ host: UIViewController) {
        if let page = host as? LampsWebViewController {
            page.closePage()
            return
        }
        if let navigationController = host.navigationController,
           navigationController.presentingViewController != nil {
            navigationController.dismiss(animated: true)
            return
        }
        if host.presentingViewController != nil {
            host.dismiss(animated: true)
            return
        }
        host.navigationController?.popViewController(animated: true)
    }

    func hostViewController() -> UIViewController? {
        var responder: UIResponder? = bridge?.webView
        while let current = responder {
            if let vc = current as? UIViewController {
                return vc
            }
            responder = current.next
        }
        return nil
    }
}

private extension UIColor {
    /// 解析 `#RGB` / `#RRGGBB` / `#AARRGGBB`（可省略 `#`）。
    static func lamps_color(fromHex string: String) -> UIColor? {
        var hex = string.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hex.hasPrefix("#") {
            hex.removeFirst()
        }
        if hex.hasPrefix("0X") {
            hex = String(hex.dropFirst(2))
        }
        if hex.count == 3 {
            hex = hex.map { "\($0)\($0)" }.joined()
        }
        guard hex.count == 6 || hex.count == 8 else { return nil }
        var value: UInt64 = 0
        guard Scanner(string: hex).scanHexInt64(&value) else { return nil }

        let red, green, blue, alpha: CGFloat
        if hex.count == 8 {
            alpha = CGFloat((value & 0xFF000000) >> 24) / 255
            red = CGFloat((value & 0x00FF0000) >> 16) / 255
            green = CGFloat((value & 0x0000FF00) >> 8) / 255
            blue = CGFloat(value & 0x000000FF) / 255
        } else {
            red = CGFloat((value & 0xFF0000) >> 16) / 255
            green = CGFloat((value & 0x00FF00) >> 8) / 255
            blue = CGFloat(value & 0x0000FF) / 255
            alpha = 1
        }
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
