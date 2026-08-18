import Foundation

/// 导航相关：close。
@objcMembers
public final class LampsNavigationBridgeHandler: NSObject, LampsBridgeHandler {
    public weak var bridge: LampsBridge?
    public var closeHandler: (() -> Void)?

    public var supportedMethods: [String] {
        ["close"]
    }

    public func handle(
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
