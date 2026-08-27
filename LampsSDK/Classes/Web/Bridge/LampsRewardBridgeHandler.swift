import Foundation
import UIKit

/// 激励视频：H5 一次调用，客户端完成 load → 竞价 → show。
/// 忙态由 `LampsRewardVideoManager` 处理；状态全部走 `hoorah.ad.rewardedVideoStatus`。
@objcMembers
final class LampsRewardBridgeHandler: NSObject, LampsBridgeHandler {
    weak var bridge: LampsBridge?

    var supportedMethods: [String] {
        [Method.showRewardedVideo]
    }

    func handle(
        method: String,
        data: [AnyHashable: Any],
        success: LampsBridgeToH5Callback?,
        error: LampsBridgeToH5Callback?
    ) {
        guard method == Method.showRewardedVideo else {
            error?(["success": false, "error": "unsupported method: \(method)"])
            return
        }

        success?(["success": true])

        guard let viewController = hostViewController() else {
            notifyStatus(makeCallback(
                name: .reqError,
                status: false,
                code: LampsSDKError.invalidConfig("无法找到展示激励视频的页面").nsError.code,
                message: "无法找到展示激励视频的页面"
            ))
            return
        }

        let forwardSource = LampsJSONValue.stringValue(data["forward_source"], trim: true)
        LampsSDKLog.debug("bridge reward start forward_source=\(forwardSource)")
        LampsRewardAd.show(
            from: viewController,
            forwardSource: forwardSource.isEmpty ? nil : forwardSource,
            handler: { [weak self] callback in
                self?.notifyStatus(callback)
            },
            completion: nil
        )
    }
}

private extension LampsRewardBridgeHandler {
    enum Method {
        static let showRewardedVideo = "lamps.ad.showRewardedVideo"
        static let rewardedVideoStatus = "lamps.ad.rewardedVideoStatus"
    }

    func notifyStatus(_ callback: LampsRewardCallback) {
        let payload = statusPayload(from: callback)
        LampsSDKLog.debug("bridge reward status=\(callback.name.h5CallbackName)")
        bridge?.send(method: Method.rewardedVideoStatus, data: payload)
    }

    func statusPayload(from callback: LampsRewardCallback) -> [AnyHashable: Any] {
        var payload: [AnyHashable: Any] = [
            "callbackName": callback.name.h5CallbackName
        ]
        let errMsg = callback.errMessage ?? ""
        if callback.errCode != 0 || !errMsg.isEmpty {
            payload["data"] = [
                "errCode": callback.errCode,
                "errMsg": errMsg
            ]
        }
        return payload
    }

    func makeCallback(
        name: LampsRewardCallbackName,
        status: Bool,
        code: Int = 0,
        message: String?
    ) -> LampsRewardCallback {
        let callback = LampsRewardCallback()
        callback.name = name
        callback.status = status
        callback.errCode = code
        callback.errMessage = message
        return callback
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
