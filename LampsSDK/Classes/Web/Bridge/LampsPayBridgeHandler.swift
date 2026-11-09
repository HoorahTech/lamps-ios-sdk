import Foundation

/// 第三方支付。当前只支持支付宝，对齐虎扑 `hupu.thirdPartyPay.order` 的 `alipay` 渠道。
/// 真正调支付宝在 `AlipayAdapter`。Core 未注册该 Adapter 时直接失败。
@objcMembers
final class LampsPayBridgeHandler: NSObject, LampsBridgeHandler {
    weak var bridge: LampsBridge?

    /// H5 支付方法名。`bridgeReady.supportedBridges` 在支付宝可用时带回。
    static let orderMethod = "lamps.thirdPartyPay.order"

    var supportedMethods: [String] {
        [Self.orderMethod]
    }

    func handle(
        method: String,
        data: [AnyHashable: Any],
        success: LampsBridgeToH5Callback?,
        error: LampsBridgeToH5Callback?
    ) {
        guard method == Self.orderMethod else {
            error?(["msg": "unsupported method: \(method)"])
            return
        }

        let channel = LampsJSONValue.stringValue(data["channel"], trim: true)
        guard !channel.isEmpty else {
            fail(error, message: "缺少 channel")
            return
        }
        guard channel.lowercased() == "alipay" else {
            fail(error, message: "暂不支持该支付渠道: \(channel)")
            return
        }

        let order = LampsJSONValue.stringValue(data["orderInfo"], trim: true)
        guard !order.isEmpty else {
            fail(error, message: "orderInfo 为空")
            return
        }

        guard LampsAlipayPay.isAvailable else {
            fail(error, message: "宿主未集成支付宝 SDK")
            return
        }

        let started = LampsAlipayPay.pay(order: order, scheme: Lamps.alipayURLScheme) { [weak self] outcome in
            self?.complete(outcome, success: success, error: error)
        }
        if !started {
            fail(error, message: "宿主未集成支付宝 SDK")
        }
    }
}

private extension LampsPayBridgeHandler {
    func complete(
        _ outcome: LampsAlipayPay.Outcome,
        success: LampsBridgeToH5Callback?,
        error: LampsBridgeToH5Callback?
    ) {
        guard !outcome.resultStatus.isEmpty else {
            fail(error, message: outcome.message.isEmpty ? "fail" : outcome.message)
            return
        }
        let msg: String
        switch outcome.resultStatus {
        case "9000":
            msg = "success"
        case "6001":
            msg = "cancel"
        default:
            msg = "fail"
        }
        let body: [AnyHashable: Any] = [
            "msg": msg,
            "channel": "alipay",
            "resultStatus": outcome.resultStatus,
            "result": outcome.result,
            "memo": outcome.memo
        ]
        if outcome.resultStatus == "9000" {
            success?(body)
        } else {
            error?(body)
        }
    }

    func fail(_ error: LampsBridgeToH5Callback?, message: String) {
        LampsSDKLog.debug("bridge thirdPartyPay.order fail: \(message)")
        error?(["msg": message])
    }
}
