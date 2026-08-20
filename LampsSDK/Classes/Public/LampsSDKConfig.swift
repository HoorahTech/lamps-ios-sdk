import Foundation

/// SDK 初始化配置。
@objcMembers
public final class LampsSDKConfig: NSObject, NSCopying {
    /// 宿主分配的应用标识，初始化时必填。
    public var appId: String = ""
    /// 是否打印 SDK 调试日志，默认 false。
    public var debugLogEnabled: Bool = false
    /// 配置接口环境，默认正式环境。
    public var environment: LampsSDKEnvironment = .prd

    /// 穿山甲 AppId；非空且集成 CSJ Subspec 时会在 start 中初始化。
    /// 宿主已自行初始化（如 HCAD）时请留空，避免二次 init。
    public var csjAppId: String = ""
    /// 优量汇 AppId；非空且集成 GDT Subspec 时会在 start 中初始化。
    /// 宿主已自行初始化时请留空。
    public var gdtAppId: String = ""
    /// 汇川 AppKey；非空且集成 Noah Subspec 时会在 start 中初始化。
    /// 宿主已自行初始化时请留空。
    public var noahAppKey: String = ""

    public func copy(with zone: NSZone? = nil) -> Any {
        let config = LampsSDKConfig()
        config.appId = appId
        config.debugLogEnabled = debugLogEnabled
        config.environment = environment
        config.csjAppId = csjAppId
        config.gdtAppId = gdtAppId
        config.noahAppKey = noahAppKey
        return config
    }
}
