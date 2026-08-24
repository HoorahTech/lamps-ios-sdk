import Foundation

/// 导航相关：close。
@objcMembers
final class LampsNavigationBridgeHandler: NSObject, LampsBridgeHandler {
    weak var bridge: LampsBridge?
    var closeHandler: (() -> Void)?

    var supportedMethods: [String] {
        ["close"]
    }

    func handle(
        method: String,
        data: [AnyHashable: Any],
        success: LampsBridgeToH5Callback?,
        error: LampsBridgeToH5Callback?
    ) {
        guard method == "close" else {
            error?(["success": false, "error": "unsupported method: \(method)"])
            return
        }
        success?(["success": true])
        DispatchQueue.main.async { [weak self] in
            self?.closeHandler?()
        }
    }
}
