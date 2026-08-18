import Foundation

/// 配置接口环境。
@objc public enum LampsSDKEnvironment: Int {
    case prd = 0
    case dev = 1

    public var baseURL: String {
        switch self {
        case .prd:
            return "https://api.hoorahgo.com"
        case .dev:
            return "https://api-dev.hoorahgo.com"
        }
    }
}
