import Foundation

/// 支付宝支付结果。Adapter 回给 Core，由 Bridge 映射成 H5 回调。
@_spi(LampsAdapter)
public struct LampsAlipayPayOutcome {
    public var resultStatus: String
    public var result: String
    public var memo: String
    public var message: String

    public init(resultStatus: String, result: String, memo: String, message: String) {
        self.resultStatus = resultStatus
        self.result = result
        self.memo = memo
        self.message = message
    }
}

/// 支付宝支付实现。仅 `AlipayAdapter` 注册，Core 不链接 AlipaySDK。
@_spi(LampsAdapter)
public protocol LampsAlipayPaying: AnyObject {
    func pay(order: String, scheme: String, completion: @escaping (LampsAlipayPayOutcome) -> Void) -> Bool
    func handleOpenURL(_ url: URL) -> Bool
}

/// Core 侧支付入口。没有 Adapter 注册时，Bridge 直接失败。
@_spi(LampsAdapter)
public enum LampsAlipayPay {
    typealias Outcome = LampsAlipayPayOutcome

    private static let lock = NSLock()
    private static var payer: LampsAlipayPaying?

    public static func register(_ payer: LampsAlipayPaying) {
        lock.lock()
        self.payer = payer
        lock.unlock()
        LampsSDKLog.debug("alipay adapter registered")
    }

    static var isAvailable: Bool {
        lock.lock()
        defer { lock.unlock() }
        return payer != nil
    }

    @discardableResult
    static func pay(
        order: String,
        scheme: String,
        completion: @escaping (Outcome) -> Void
    ) -> Bool {
        guard let payer = current() else { return false }
        return payer.pay(order: order, scheme: scheme, completion: completion)
    }

    static func handleOpenURL(_ url: URL) -> Bool {
        current()?.handleOpenURL(url) ?? false
    }

    private static func current() -> LampsAlipayPaying? {
        lock.lock()
        defer { lock.unlock() }
        return payer
    }
}
