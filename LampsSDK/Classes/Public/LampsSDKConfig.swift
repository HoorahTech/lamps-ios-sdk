import Foundation

/// SDK 初始化配置。
@objcMembers
public final class LampsSDKConfig: NSObject, NSCopying {
    /// 宿主分配的应用标识，初始化时必填。
    public var appId: String = ""
    /// 是否打印 SDK 调试日志，默认 false。
    public var debugLogEnabled: Bool = false
    /// REM 签名密钥。为空时回退使用配置接口返回的 `token`。
    public var rewardSignKey: String = ""
    /// 配置接口环境，默认正式环境。
    public var environment: LampsSDKEnvironment = .prd

    /// 穿山甲 AppId；非空且集成 CSJ Subspec 时会在 start 中初始化。
    public var csjAppId: String = ""
    /// 优量汇 AppId；非空且集成 GDT Subspec 时会在 start 中初始化。
    public var gdtAppId: String = ""
    /// 汇川 AppKey；非空且集成 Noah Subspec 时会在 start 中初始化。
    public var noahAppKey: String = ""
    /// 激励默认超时（毫秒）。
    public var rewardTimeoutMs: Int = 5000
    /// 激励服务端校验 userId。
    public var rewardUserId: String = ""

    public func copy(with zone: NSZone? = nil) -> Any {
        let config = LampsSDKConfig()
        config.appId = appId
        config.debugLogEnabled = debugLogEnabled
        config.rewardSignKey = rewardSignKey
        config.environment = environment
        config.csjAppId = csjAppId
        config.gdtAppId = gdtAppId
        config.noahAppKey = noahAppKey
        config.rewardTimeoutMs = rewardTimeoutMs
        config.rewardUserId = rewardUserId
        return config
    }
}
