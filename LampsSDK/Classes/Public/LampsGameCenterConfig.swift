import Foundation

/// 打开或嵌入游戏中心时的展示配置。不传则用 `LampsSDKConfig` 中的对应字段。
@objcMembers
public final class LampsGameCenterConfig: NSObject {
    /// 日夜间，默认日间。创建内嵌游戏中心后若宿主日夜间变化，请调 `LampsGameCenterView.updateDayNightMode`。
    public var dayNightMode: LampsDayNightMode = .day

    public override init() {
        super.init()
    }

    public convenience init(dayNightMode: LampsDayNightMode) {
        self.init()
        self.dayNightMode = dayNightMode
    }
}
