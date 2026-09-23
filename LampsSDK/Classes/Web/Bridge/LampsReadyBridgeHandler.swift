import Foundation

/// H5 调用 `lamps.common.bridgeReady`（兼容 `bridgeReady`）获取客户端参数。
@objcMembers
final class LampsReadyBridgeHandler: NSObject, LampsBridgeHandler {
    weak var bridge: LampsBridge?

    var supportedMethods: [String] {
        [Method.bridgeReady]
    }

    func handle(
        method: String,
        data: [AnyHashable: Any],
        success: LampsBridgeToH5Callback?,
        error: LampsBridgeToH5Callback?
    ) {
        guard method == Method.bridgeReady else {
            error?(["msg": "unsupported method: \(method)"])
            return
        }
        let info = LampsBridgeClientInfo.dictionary(
            displayMode: bridge?.webView?.displayMode ?? "",
            dayNightMode: bridge?.webView?.dayNightMode
        )
        LampsSDKLog.debug(
            "bridgeReady os=\(info["os"] ?? "")/\(info["osVer"] ?? "") brand=\(info["phoneBrand"] ?? "") network=\(info["network"] ?? "") size=\(info["clientWidth"] ?? "")x\(info["clientHeight"] ?? "") density=\(info["density"] ?? "") statusBar=\(info["statusBarHeight"] ?? "") sdk=\(info["sdkVersion"] ?? "") appVer=\(info["appVer"] ?? "") displayMode=\(info["displayMode"] ?? "") night=\(info["night"] ?? "") env=\(info["env"] ?? "")"
        )
        guard JSONSerialization.isValidJSONObject(info) else {
            error?(["msg": "device info 序列化失败"])
            return
        }
        success?(info)
    }
}

private extension LampsReadyBridgeHandler {
    enum Method {
        static let bridgeReady = "lamps.common.bridgeReady"
    }
}
