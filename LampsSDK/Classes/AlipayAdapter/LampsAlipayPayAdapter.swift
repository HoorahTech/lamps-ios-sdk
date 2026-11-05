#if LampsADAPTER_SEPARATE_MODULE
@_spi(LampsAdapter) import LampsSDK
#endif

import Foundation
import AlipaySDK

/// 直接调用宿主已链接的支付宝 SDK。本文件只在 `AlipayAdapter` 中编译。
final class LampsAlipaySDKPay: LampsAlipayPaying {
    static let shared = LampsAlipaySDKPay()

    private var completion: ((LampsAlipayPayOutcome) -> Void)?

    func pay(
        order: String,
        scheme: String,
        completion: @escaping (LampsAlipayPayOutcome) -> Void
    ) -> Bool {
        guard let service = AlipaySDK.defaultService() else {
            LampsSDKLog.debug("alipay pay unavailable: defaultService nil")
            return false
        }
        self.completion = completion
        LampsSDKLog.debug("alipay pay scheme=\(scheme) orderLen=\(order.count)")
        service.payOrder(order, fromScheme: scheme) { [weak self] result in
            let outcome = LampsAlipaySDKPay.outcome(from: result)
            DispatchQueue.main.async {
                self?.finish(outcome)
            }
        }
        return true
    }

    func handleOpenURL(_ url: URL) -> Bool {
        guard isSafepay(url), completion != nil, let service = AlipaySDK.defaultService() else {
            return false
        }
        // standbyCallback 传空，支付宝才会回到 payOrder 的 callback。
        service.processOrder(withPaymentResult: url, standbyCallback: nil)
        LampsSDKLog.debug("alipay openURL safepay")
        return true
    }

    private func finish(_ outcome: LampsAlipayPayOutcome) {
        guard let current = completion else { return }
        completion = nil
        LampsSDKLog.debug(
            "alipay result status=\(outcome.resultStatus) memoLen=\(outcome.memo.count)"
        )
        current(outcome)
    }

    private func isSafepay(_ url: URL) -> Bool {
        url.host?.caseInsensitiveCompare("safepay") == .orderedSame
    }

    private static func outcome(from result: [AnyHashable: Any]?) -> LampsAlipayPayOutcome {
        LampsAlipayPayOutcome(
            resultStatus: text(result, key: "resultStatus"),
            result: text(result, key: "result"),
            memo: text(result, key: "memo"),
            message: ""
        )
    }

    private static func text(_ result: [AnyHashable: Any]?, key: String) -> String {
        guard let value = result?[key] else { return "" }
        if let text = value as? String {
            return text
        }
        if let number = value as? NSNumber {
            return number.stringValue
        }
        return ""
    }
}

@objc(LampsAlipayPayRegistrar)
final class LampsAlipayPayRegistrar: NSObject {
    private static var didRegister = false

    @objc static func registerIfNeeded() {
        guard !didRegister else { return }
        didRegister = true
        LampsAlipayPay.register(LampsAlipaySDKPay.shared)
    }
}
