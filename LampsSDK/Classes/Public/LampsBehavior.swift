import Foundation

/// 游戏中心 / 游戏行为回传的事件。
///
/// 打开页面对应埋点外层 `type = action`，退出页面对应 `type = view`。
/// 埋点事件名用 `name`。ObjC 用 `LampsBehaviorEventOpenPage` / `LampsBehaviorEventExitPage`。
@objc public enum LampsBehaviorEvent: Int {
    /// 打开页面。
    case openPage
    /// 退出页面。
    case exitPage

    /// 埋点事件名：`打开页面` / `退出页面`。
    public var name: String {
        switch self {
        case .openPage: return "打开页面"
        case .exitPage: return "退出页面"
        }
    }
}

/// 行为回传的页面类型。
///
/// 埋点文案用 `name`：`游戏中心` / `游戏`。与 `data` 里的 `type` 相同。
/// ObjC 用 `LampsBehaviorPageTypeGameCenter` / `LampsBehaviorPageTypeGame`，文案用 `[Lamps behaviorPageTypeNameForPageType:]`。
@objc public enum LampsBehaviorPageType: Int {
    /// 游戏中心。
    case gameCenter
    /// 单个游戏。
    case game

    /// 埋点页面类型：`游戏中心` / `游戏`。
    public var name: String {
        switch self {
        case .gameCenter: return "游戏中心"
        case .game: return "游戏"
        }
    }
}

/// 一次游戏中心 / 游戏行为回传。
///
/// `data` 仍是原来的业务字段，里面平铺了 `trackParams`。`trackParams` 同时单独给出本次打开时传入的原表。
/// 宿主自行补 `model`、外层 `event` / `type`、用户或游客标识、事件时间和客户端版本。
@objcMembers
public final class LampsBehavior: NSObject {
    /// 打开页面或退出页面。埋点事件名用 `event.name`。
    public let event: LampsBehaviorEvent
    /// 页面类型。埋点文案用 `pageType.name`。
    public let pageType: LampsBehaviorPageType
    /// 本次行为字段。打开、退出的内容和原先回调里的 `data` 相同。
    public let data: [String: Any]
    /// 打开时通过配置传入的埋点字段。没有传入时为空。
    public let trackParams: [String: String]

    init(
        event: LampsBehaviorEvent,
        pageType: LampsBehaviorPageType,
        data: [String: Any],
        trackParams: [String: String]
    ) {
        self.event = event
        self.pageType = pageType
        self.data = data
        self.trackParams = trackParams
        super.init()
    }
}

/// 游戏中心 / 游戏行为回传，在主线程调用。
///
/// 未设置 `Lamps.behaviorHandler` 时不会调用。回调里不要做耗时操作。
public typealias LampsBehaviorHandler = (LampsBehavior) -> Void
