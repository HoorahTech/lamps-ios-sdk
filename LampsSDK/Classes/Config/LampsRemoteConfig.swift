import Foundation
import CoreGraphics

/// `/v1/lamps/config` 返回的 data。仅 SDK 内部使用。
@objcMembers
final class LampsRemoteConfig: NSObject {
    var rewardAdSlots: [LampsRewardAdSlot] = []
    var token: String = ""
    var clientIp: String = ""
    var monitorLinks: LampsMonitorLinks = LampsMonitorLinks()

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
final class LampsRewardAdSlot: NSObject {
    /// 代码位 ID
    var slotId: String = ""
    /// 类型：BD、PD
    var type: String = ""
    var channelName: String = ""
    var channelId: String = ""
    /// 接口下发价格；创建 model 时先写入，SDK 回传价 > 0 时覆盖。
    var price: CGFloat = 0

    /// 是否定价位。
    var isPD: Bool {
        type.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() == "PD"
    }

    static func parse(from dict: [String: Any]) -> LampsRewardAdSlot? {
        let slot = LampsRewardAdSlot()
        slot.slotId = stringValue(dict["slotId"]) ?? ""
        slot.type = stringValue(dict["type"]) ?? ""
        slot.channelName = stringValue(dict["channelName"]) ?? ""
        slot.channelId = stringValue(dict["channelId"]) ?? ""
        slot.price = cgFloatValue(dict["price"])
        guard !slot.slotId.isEmpty else { return nil }
        return slot
    }

    private static func stringValue(_ value: Any?) -> String? {
        if let text = value as? String { return text }
        if let number = value as? NSNumber { return number.stringValue }
        return nil
    }

    private static func cgFloatValue(_ value: Any?) -> CGFloat {
        if let number = value as? NSNumber { return CGFloat(truncating: number) }
        if let text = value as? String, let double = Double(text) { return CGFloat(double) }
        return 0
    }
}

@objcMembers
final class LampsMonitorLinks: NSObject {
    var rm: [String] = []
    var pm: [String] = []
    var cm: [String] = []
    var dm: [String] = []
    var wm: [String] = []

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
