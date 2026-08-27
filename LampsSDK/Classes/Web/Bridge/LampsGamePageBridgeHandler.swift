import Foundation
import UIKit

/// 打开游戏页：H5 `lamps.game.open`，原生打开 `LampsGameWebViewController`。
@objcMembers
final class LampsGamePageBridgeHandler: NSObject, LampsBridgeHandler {
    weak var bridge: LampsBridge?

    var supportedMethods: [String] {
        [Method.open]
    }

    func handle(
        method: String,
        data: [AnyHashable: Any],
        success: LampsBridgeToH5Callback?,
        error: LampsBridgeToH5Callback?
    ) {
        guard method == Method.open else {
            error?(["msg": "unsupported method: \(method)"])
            return
        }

        let urlString = stringValue(data["url"])
        guard let url = LampsWebView.makeURL(from: urlString),
              let scheme = url.scheme?.lowercased(),
              scheme == "http" || scheme == "https" else {
            LampsSDKLog.debug("bridge game.open skip: invalid url=\(urlString)")
            error?(["msg": "url 无效，须为完整 http(s) URL"])
            return
        }

        guard let host = hostViewController() else {
            LampsSDKLog.debug("bridge game.open skip: no host vc")
            error?(["msg": "无法找到打开游戏页的容器"])
            return
        }

        LampsSDKLog.debug("bridge game.open url=\(urlString)")
        let page = LampsGameWebViewController(urlString: urlString)
        Lamps.pushOrPresent(page, from: host)
        success?(["msg": "success"])
    }
}

private extension LampsGamePageBridgeHandler {
    enum Method {
        static let open = "lamps.game.open"
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

    func stringValue(_ value: Any?) -> String {
        if let text = value as? String {
            return text.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if let number = value as? NSNumber {
            return number.stringValue
        }
        return ""
    }
}
