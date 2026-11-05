import Foundation

/// 媒体侧当前用户。登录后调用 `Lamps.setUserInfo`，退出登录后调用 `Lamps.clearUserInfo`。
///
/// SDK 只保存在内存里，进程结束后失效。请在主线程设置。
@objcMembers
public final class LampsUserInfo: NSObject, NSCopying {
    /// 媒体用户 ID。`bridgeReady` 字段名为 `uid`。
    public var userId: String = ""
    /// 昵称。`bridgeReady` 字段名为 `nickname`。
    public var nickname: String = ""
    /// 头像地址。`bridgeReady` 字段名为 `avatar`。
    public var avatar: String = ""

    public override init() {
        super.init()
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        let info = LampsUserInfo()
        info.userId = userId
        info.nickname = nickname
        info.avatar = avatar
        return info
    }
}
