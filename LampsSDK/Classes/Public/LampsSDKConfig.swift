import Foundation

/// SDK 初始化配置。
@objcMembers
public final class LampsSDKConfig: NSObject, NSCopying {
    /// 宿主分配的应用标识，初始化时必填。
    public var appId: String = ""
    /// 是否打印 SDK 调试日志，默认 false。
    public var debugLogEnabled: Bool = false

    /// 穿山甲 AppId；非空且集成 CSJ Subspec 时会在 start 中初始化。
    /// 宿主已自行初始化（如 HCAD）时请留空，避免二次 init。
    public var csjAppId: String = ""
    /// 优量汇 AppId；非空且集成 GDT Subspec 时会在 start 中初始化。
    /// 宿主已自行初始化时请留空。
    public var gdtAppId: String = ""
    /// 汇川 AppKey；非空且集成 Noah Subspec 时会在 start 中初始化。
    /// 宿主已自行初始化时请留空。
    public var noahAppKey: String = ""

    // MARK: - 三方 SDK 初始化通用开关（仅 Lamps 负责 init 时生效）

    /// 是否开启个性化推荐，默认 true。
    /// 优量汇：`setPersonalizedState`（false → 关闭个性化）。
    public var personalizedRecommendEnabled: Bool = true
    /// 是否开启摇一摇类互动广告，默认 true。
    /// 穿山甲：`userExtData.is_shake_ads`；优量汇：`shakable`。
    public var shakeAdsEnabled: Bool = true
    /// 是否允许广告 SDK 使用定位，默认 false（更稳妥的隐私默认）。
    /// 汇川：`forbidHcGetLocationInfo = !allowLocation`。
    public var allowLocation: Bool = false

    public func copy(with zone: NSZone? = nil) -> Any {
        let config = LampsSDKConfig()
        config.appId = appId
        config.debugLogEnabled = debugLogEnabled
        config.csjAppId = csjAppId
        config.gdtAppId = gdtAppId
        config.noahAppKey = noahAppKey
        config.personalizedRecommendEnabled = personalizedRecommendEnabled
        config.shakeAdsEnabled = shakeAdsEnabled
        config.allowLocation = allowLocation
        return config
    }
}
