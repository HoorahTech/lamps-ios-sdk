import Foundation

/// 基础能力：ping。
@objcMembers
final class LampsBaseBridgeHandler: NSObject, LampsBridgeHandler {
    weak var bridge: LampsBridge?

    var supportedMethods: [String] {
        ["ping"]
    }

    func handle(
        method: String,
        data: [AnyHashable: Any],
        success: LampsBridgeToH5Callback?,
        error: LampsBridgeToH5Callback?
    ) {
        guard method == "ping" else {
            error?(["success": false, "error": "unsupported method: \(method)"])
            return
        }
        var result: [AnyHashable: Any] = ["pong": true]
        result.merge(data) { _, new in new }
        success?(result)
    }
}
