import Foundation

/// 基础能力：ping。
@objcMembers
public final class LampsBaseBridgeHandler: NSObject, LampsBridgeHandler {
    public weak var bridge: LampsBridge?

    public var supportedMethods: [String] {
        ["ping"]
    }

    public func handle(
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
