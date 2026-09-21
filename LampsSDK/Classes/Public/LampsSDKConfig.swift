import Foundation

/// 日夜间。
@objc public enum LampsDayNightMode: Int {
    case day
    case night
}

/// 初始化参数。在调用 `Lamps.start` 之前设置。
@objcMembers
public final class LampsSDKConfig: NSObject, NSCopying {
    /// 分配给宿主 App 的应用 ID，必填。
    public var appId: String = ""
    /// 日夜间，默认日间。打开游戏中心时未传 `LampsGameCenterConfig` 则用该值。
    public var dayNightMode: LampsDayNightMode = .day
    /// 是否打印 `[LampsSDK]` 调试日志。正式包请保持关闭。
    public var debugLogEnabled: Bool = false

    // MARK: - 三方广告 SDK 初始化开关（由 Lamps 在 start 时写入各家 SDK）

    /// 是否开启个性化推荐广告，默认开启。
    public var personalizedRecommendEnabled: Bool = false
    /// 是否开启摇一摇类互动广告，默认开启。
    public var shakeAdsEnabled: Bool = false
    /// 是否允许广告 SDK 使用定位，默认关闭。
    public var allowLocation: Bool = false

    public func copy(with zone: NSZone? = nil) -> Any {
        let config = LampsSDKConfig()
        config.appId = appId
        config.dayNightMode = dayNightMode
        config.debugLogEnabled = debugLogEnabled
        config.personalizedRecommendEnabled = personalizedRecommendEnabled
        config.shakeAdsEnabled = shakeAdsEnabled
        config.allowLocation = allowLocation
        return config
    }
}

extension LampsDayNightMode {
    /// H5 `night` 字段：日间 `0`，夜间 `1`。
    var bridgeNightValue: Int {
        switch self {
        case .day:
            return 0
        case .night:
            return 1
        }
    }

    var logName: String {
        switch self {
        case .day:
            return "day"
        case .night:
            return "night"
        }
    }
}
