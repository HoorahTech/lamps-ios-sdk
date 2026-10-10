import Foundation

/// 埋点回调，在主线程调用。
///
/// SDK 仍会自行上报。宿主用这份数据做自己的上报。未设置 `Lamps.trackHandler` 时不会调用。
/// - Parameter event: 本次事件。`action` 为 `access` / `click` / `exposure`。
public typealias LampsTrackHandler = (LampsTrackEvent) -> Void

/// 一次 `lamps.common.track` 上报。在客户端即将上报时回调，含访问、点击、曝光。
///
/// `type == onload` 的访问会在容器不可见或 App 进后台才回调，并带上这段可见时间的 `visitTime` / `leaveTime`。
/// 其它事件没有这两个时间时为 `0`。
@objcMembers
public final class LampsTrackEvent: NSObject {
    /// 外层行为。`access` / `click` / `exposure`。
    public let action: String
    /// H5 `type`。页面访问时长为 `onload`。
    public let type: String
    /// 进入时间，秒级时间戳。没有时为 `0`。
    public let visitTime: Int64
    /// 离开时间，秒级时间戳。没有时为 `0`。
    public let leaveTime: Int64
    /// H5 业务字段，以及客户端补上的 `vt` / `lt`。与上报 body 里的 `pdata` 同一份内容。
    public let pdata: [String: Any]

    init(
        action: String,
        type: String,
        visitTime: Int64,
        leaveTime: Int64,
        pdata: [String: Any]
    ) {
        self.action = action
        self.type = type
        self.visitTime = visitTime
        self.leaveTime = leaveTime
        self.pdata = pdata
        super.init()
    }
}
