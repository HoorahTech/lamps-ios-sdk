import Foundation

/// 直接打开具体游戏页时的配置。
@objcMembers
public final class LampsGameConfig: NSObject {
    /// 追加到游戏页链接上的查询参数。键和值按原始字符串百分号编码后拼接。链接里已有的同名参数会跳过，保留原值。
    public var urlQuery: [String: String] = [:]
    /// 本次打开带上的埋点字段。打开成功、打开失败和退出会并进行为回传，不覆盖 SDK 字段。
    public var trackParams: [String: String] = [:]

    public override init() {
        super.init()
    }
}
