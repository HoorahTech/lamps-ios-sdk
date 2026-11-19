import Foundation

/// SDK 调试日志分类。调试页按这个筛选。
@_spi(LampsAdapter)
@_spi(LampsDevTools)
public enum LampsSDKLogCategory: CaseIterable {
    /// `start`、配置拉取、广告 SDK 初始化。
    case startup
    /// 激励视频请求、竞价、展示和关闭。
    case reward
    /// 监测链接上报（RM / PM / CM / WM / REM）。
    case monitor
    /// 游戏中心 / 游戏行为回传。
    case behavior
    /// 未归入以上分类的日志。
    case other

    public var title: String {
        switch self {
        case .startup: return "初始化"
        case .reward: return "激励视频"
        case .monitor: return "Monitor"
        case .behavior: return "行为回调"
        case .other: return "其他"
        }
    }
}

/// 一条内存日志。仅调试工具读取。
@_spi(LampsAdapter)
@_spi(LampsDevTools)
public struct LampsSDKLogEntry {
    public let id: UInt64
    public let date: Date
    public let category: LampsSDKLogCategory
    public let message: String
}

/// SDK 内部调试日志。仅 Adapter / 调试工具跨模块可见。
///
/// 始终写入内存环形缓冲，供调试页展示；`debugLogEnabled` 为真时同时 `NSLog`。
@_spi(LampsAdapter)
@_spi(LampsDevTools)
public enum LampsSDKLog {
    /// 有新日志写入。调试页在主线程监听后刷新。
    public static let didAppendNotification = Notification.Name("LampsSDKLogDidAppend")

    private static let lock = NSLock()
    private static var buffer: [LampsSDKLogEntry] = []
    private static var nextID: UInt64 = 1
    private static var notifyQueued = false
    private static let capacity = 400

    public static func debug(_ message: String, category: LampsSDKLogCategory = .other) {
        append(message, category: category)
        guard Lamps.config?.debugLogEnabled == true else { return }
        NSLog("[LampsSDK][%@] %@", category.title, message)
    }

    /// 当前缓冲，按写入顺序。调试页自行决定筛选和倒序。
    public static func snapshot() -> [LampsSDKLogEntry] {
        lock.lock()
        defer { lock.unlock() }
        return buffer
    }

    public static func clear() {
        lock.lock()
        buffer.removeAll()
        lock.unlock()
        scheduleNotify()
    }

    private static func append(_ message: String, category: LampsSDKLogCategory) {
        let date = Date()
        lock.lock()
        let entry = LampsSDKLogEntry(
            id: nextID,
            date: date,
            category: category,
            message: message
        )
        nextID += 1
        buffer.append(entry)
        if buffer.count > capacity {
            buffer.removeFirst(buffer.count - capacity)
        }
        lock.unlock()
        scheduleNotify()
    }

    /// 同一轮连续日志只通知一次，避免调试页连刷。
    private static func scheduleNotify() {
        lock.lock()
        let shouldSchedule = !notifyQueued
        notifyQueued = true
        lock.unlock()
        guard shouldSchedule else { return }
        DispatchQueue.main.async {
            lock.lock()
            notifyQueued = false
            lock.unlock()
            NotificationCenter.default.post(name: didAppendNotification, object: nil)
        }
    }
}
