import Foundation

/// 打开或嵌入游戏中心时的展示配置。不传则用 `LampsSDKConfig` 中的对应字段。
@objcMembers
public final class LampsGameCenterConfig: NSObject {
    /// 日夜间，默认日间。创建内嵌游戏中心后若宿主日夜间变化，请调 `LampsGameCenterView.updateDayNightMode`。
    public var dayNightMode: LampsDayNightMode = .day
    /// 是否隐藏 H5 标题栏，默认不隐藏。`true` 时 `bridgeReady.hideTitle` 为 `1`。
    public var hideTitle: Bool = false
    /// 追加到游戏中心链接上的查询参数。键和值按原始字符串百分号编码后拼接。链接里已有的同名参数会跳过，保留原值。
    public var urlQuery: [String: String] = [:]
    /// 本次打开带上的埋点字段。`showGameCenter` / `presentGameCenter` 的打开成功、打开失败和退出会并进行为回传，不覆盖 SDK 字段。
    /// 从该游戏中心再打开的游戏也会带上这张表。`makeGameCenterView` 的内嵌视图本身不回传。
    public var trackParams: [String: String] = [:]

    public override init() {
        super.init()
    }

    public convenience init(dayNightMode: LampsDayNightMode) {
        self.init()
        self.dayNightMode = dayNightMode
    }
}
