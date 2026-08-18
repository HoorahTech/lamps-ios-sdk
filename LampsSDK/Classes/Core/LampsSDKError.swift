import Foundation

public let LampsSDKErrorDomain = "com.hupu.lamps.sdk"

@objc public enum LampsSDKErrorCode: Int {
    case notImplemented = -1001
    case notStarted = -1002
    case invalidConfig = -1003
}

enum LampsSDKError {
    case notImplemented(String)
    case notStarted(String)
    case invalidConfig(String)

    var nsError: NSError {
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
        }
    }

    private var message: String {
        switch self {
        case .notImplemented(let message),
             .notStarted(let message),
             .invalidConfig(let message):
            return message
        }
    }
}
