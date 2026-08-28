import Foundation

/// SDK 失败时 `NSError.domain`。
public let LampsSDKErrorDomain = "com.hupu.lamps.sdk"

/// SDK 失败时 `NSError.code`。
@objc public enum LampsSDKErrorCode: Int {
    /// 尚未调用 `Lamps.start`。
    case notStarted = -1001
    /// 初始化参数不合法，例如 `appId` 为空。
    case invalidConfig = -1002
    /// 配置接口地址无效或 URL 组装失败。具体原因看 `localizedDescription`。
    case configURLError = -1003
    /// 配置请求失败，或响应为空 / 格式错误 / 解析失败。具体原因看 `localizedDescription`。
    case configFetchError = -1004
    /// 广告 SDK 初始化失败。具体原因看 `localizedDescription`。
    case adSDKInitializeError = -1005
    /// 激励视频进行中，无法开始新的一次。
    case rewardBusy = -1006
    /// 激励视频请求 / 加载失败（含超时、全部渠道失败）。具体原因看 `localizedDescription`。
    case rewardLoadError = -1007
    /// 激励视频展示失败。具体原因看 `localizedDescription`。
    case rewardShowError = -1008
    /// 游戏中心地址为空或 URL 不合法。
    case gameCenterUnavailable = -1009
    /// 找不到可用于展示的页面。
    case noHostViewController = -1010
}

/// SDK 内部错误构造。跨模块 Adapter 使用；宿主请识别 `NSError`。
@_spi(LampsAdapter)
public enum LampsSDKError {
    case notStarted(String)
    case invalidConfig(String)
    case configURLError(String)
    case configFetchError(String)
    case adSDKInitializeError(String)
    case rewardBusy(String)
    case rewardLoadError(String)
    case rewardShowError(String)
    case gameCenterUnavailable(String)
    case noHostViewController(String)

    public var nsError: NSError {
        NSError(
            domain: LampsSDKErrorDomain,
            code: code.rawValue,
            userInfo: [NSLocalizedDescriptionKey: message]
        )
    }

    private var code: LampsSDKErrorCode {
        switch self {
        case .notStarted: return .notStarted
        case .invalidConfig: return .invalidConfig
        case .configURLError: return .configURLError
        case .configFetchError: return .configFetchError
        case .adSDKInitializeError: return .adSDKInitializeError
        case .rewardBusy: return .rewardBusy
        case .rewardLoadError: return .rewardLoadError
        case .rewardShowError: return .rewardShowError
        case .gameCenterUnavailable: return .gameCenterUnavailable
        case .noHostViewController: return .noHostViewController
        }
    }

    private var message: String {
        switch self {
        case .notStarted(let message),
             .invalidConfig(let message),
             .configURLError(let message),
             .configFetchError(let message),
             .adSDKInitializeError(let message),
             .rewardBusy(let message),
             .rewardLoadError(let message),
             .rewardShowError(let message),
             .gameCenterUnavailable(let message),
             .noHostViewController(let message):
            return message
        }
    }
}
