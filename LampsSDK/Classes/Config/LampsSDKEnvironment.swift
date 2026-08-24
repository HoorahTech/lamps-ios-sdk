import Foundation

/// 配置接口环境。默认正式；仅调试工具可切换，宿主普通 import 不可见。
@_spi(LampsDevTools)
public enum LampsSDKEnvironment: Int {
    case prd = 0
    case dev = 1

    var baseURL: String {
        switch self {
        case .prd:
            return "https://api.hoorahgo.com"
        case .dev:
            return "https://api-dev.hoorahgo.com"
        }
    }

    var logName: String {
        switch self {
        case .prd: return "prd"
        case .dev: return "dev"
        }
    }
}

enum LampsEnvironmentStore {
    private static let defaultsKey = "com.hupu.lamps.sdk.environment"

    static var current: LampsSDKEnvironment {
        get {
            LampsSDKEnvironment(rawValue: UserDefaults.standard.integer(forKey: defaultsKey)) ?? .prd
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: defaultsKey)
        }
    }
}
