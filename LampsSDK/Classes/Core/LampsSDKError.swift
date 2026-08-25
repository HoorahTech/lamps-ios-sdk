import Foundation

/// `Lamps.start` 失败时 `NSError.domain`。
public let LampsSDKErrorDomain = "com.hupu.lamps.sdk"

/// `Lamps.start` 失败时 `NSError.code`。
@objc public enum LampsSDKErrorCode: Int {
    /// 能力尚未实现。
    case notImplemented = -1001
    /// 尚未调用 `Lamps.start`。
    case notStarted = -1002
    /// 初始化参数不合法，例如 `appId` 为空。
    case invalidConfig = -1003
    /// URL 无效。
    case invalidURL = -1004
    /// 网络失败。
    case network = -1005
    /// 接口或广告 SDK 返回失败。
    case api = -1006
}

/// SDK 内部错误构造。跨模块 Adapter 使用；宿主请识别 `NSError`。
@_spi(LampsAdapter)
public enum LampsSDKError {
    case notImplemented(String)
    case notStarted(String)
    case invalidConfig(String)
    case invalidURL(String)
    case network(String)
    case api(String)

    public var nsError: NSError {
        NSError(
            domain: LampsSDKErrorDomain,
            code: code.rawValue,
            userInfo: [NSLocalizedDescriptionKey: message]
        )
    }

    private var code: LampsSDKErrorCode {
        switch self {
        case .notImplemented: return .notImplemented
        case .notStarted: return .notStarted
        case .invalidConfig: return .invalidConfig
        case .invalidURL: return .invalidURL
        case .network: return .network
        case .api: return .api
        }
    }

    private var message: String {
        switch self {
        case .notImplemented(let message),
             .notStarted(let message),
             .invalidConfig(let message),
             .invalidURL(let message),
             .network(let message),
             .api(let message):
            return message
        }
    }
}
