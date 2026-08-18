import Foundation

/// `/v1/lamps/config` 返回的 data。
@objcMembers
public final class LampsRemoteConfig: NSObject {
    public var rewardAdSlots: [LampsRewardAdSlot] = []
    public var token: String = ""
    public var clientIp: String = ""
    public var monitorLinks: LampsMonitorLinks = LampsMonitorLinks()

    static func parse(from data: [String: Any]?) -> LampsRemoteConfig? {
        guard let data = data else { return nil }
        let config = LampsRemoteConfig()
        if let slots = data["rewardAdSlots"] as? [[String: Any]] {
            config.rewardAdSlots = slots.compactMap { LampsRewardAdSlot.parse(from: $0) }
        }
        config.token = stringValue(data["token"]) ?? ""
        config.clientIp = stringValue(data["clientIp"]) ?? ""
        if let links = data["monitorLinks"] as? [String: Any] {
            config.monitorLinks = LampsMonitorLinks.parse(from: links)
        }
        return config
    }

    private static func stringValue(_ value: Any?) -> String? {
        if let text = value as? String { return text }
        if let number = value as? NSNumber { return number.stringValue }
        return nil
    }
}

@objcMembers
public final class LampsRewardAdSlot: NSObject {
    /// 代码位 ID
    public var slotId: String = ""
    /// 类型：BD、PD
    public var type: String = ""
    public var channelName: String = ""
    public var channelId: String = ""

    static func parse(from dict: [String: Any]) -> LampsRewardAdSlot? {
        let slot = LampsRewardAdSlot()
        slot.slotId = stringValue(dict["slotId"]) ?? ""
        slot.type = stringValue(dict["type"]) ?? ""
        slot.channelName = stringValue(dict["channelName"]) ?? ""
        slot.channelId = stringValue(dict["channelId"]) ?? ""
        guard !slot.slotId.isEmpty else { return nil }
        return slot
    }

    private static func stringValue(_ value: Any?) -> String? {
        if let text = value as? String { return text }
        if let number = value as? NSNumber { return number.stringValue }
        return nil
    }
}

@objcMembers
public final class LampsMonitorLinks: NSObject {
    public var rm: [String] = []
    public var pm: [String] = []
    public var cm: [String] = []
    public var dm: [String] = []
    public var wm: [String] = []

    static func parse(from dict: [String: Any]) -> LampsMonitorLinks {
        let links = LampsMonitorLinks()
        links.rm = stringArray(dict["rm"])
        links.pm = stringArray(dict["pm"])
        links.cm = stringArray(dict["cm"])
        links.dm = stringArray(dict["dm"])
        links.wm = stringArray(dict["wm"])
        return links
    }

    private static func stringArray(_ value: Any?) -> [String] {
        guard let list = value as? [Any] else { return [] }
        return list.compactMap { item -> String? in
            if let text = item as? String {
                let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                return trimmed.isEmpty ? nil : trimmed
            }
            if let number = item as? NSNumber {
                return number.stringValue
            }
            return nil
        }
    }
}
