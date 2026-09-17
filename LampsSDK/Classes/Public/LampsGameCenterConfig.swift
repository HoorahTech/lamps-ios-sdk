import Foundation

/// 打开或嵌入游戏中心时的展示配置。不传则用 `LampsSDKConfig` 中的对应字段。
@objcMembers
public final class LampsGameCenterConfig: NSObject {
    /// 日夜间，默认日间。
    public var dayNightMode: LampsDayNightMode = .day

    public override init() {
        super.init()
    }

    public convenience init(dayNightMode: LampsDayNightMode) {
        self.init()
        self.dayNightMode = dayNightMode
    }
}
