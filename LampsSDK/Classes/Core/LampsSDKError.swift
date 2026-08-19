import Foundation

public let LampsSDKErrorDomain = "com.hupu.lamps.sdk"

@objc public enum LampsSDKErrorCode: Int {
    case notImplemented = -1001
    case notStarted = -1002
    case invalidConfig = -1003
    case invalidURL = -1004
    case network = -1005
    case api = -1006
}

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
