import Foundation

/// SDK 初始化配置。后续广告 AppId、超时等参数在对应阶段再扩展。
@objcMembers
public final class LampsSDKConfig: NSObject, NSCopying {
    /// 宿主分配的应用标识，初始化时必填。
    public var appId: String = ""
    /// 是否打印 SDK 调试日志，默认 false。
    public var debugLogEnabled: Bool = false

    public func copy(with zone: NSZone? = nil) -> Any {
        let config = LampsSDKConfig()
        config.appId = appId
        config.debugLogEnabled = debugLogEnabled
        return config
    }
}
