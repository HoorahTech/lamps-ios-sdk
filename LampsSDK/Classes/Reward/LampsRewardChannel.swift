import Foundation
import CoreGraphics

/// 激励渠道。用 config `channelId` 判断（兼容 HCAD dsp：2/327=CSJ，348/349=GDT，417=Noah）。
@objc public enum LampsRewardChannel: Int {
    case csj = 1
    case gdt = 2
    case noah = 3

    public var name: String {
        switch self {
        case .csj: return "csj"
        case .gdt: return "gdt"
        case .noah: return "noah"
        }
    }

    public static func from(channelId: String?) -> LampsRewardChannel? {
        guard let raw = channelId?.trimmingCharacters(in: .whitespacesAndNewlines),
              !raw.isEmpty else {
            return nil
        }
        switch raw.lowercased() {
        case "2", "327", "csj", "bu", "pangle", "bytedance", "byte":
            return .csj
        case "348", "349", "gdt", "ylh", "tencent":
            return .gdt
        case "417", "noah", "hc", "huichuan":
            return .noah
        default:
            return nil
        }
    }
}

enum LampsRewardRequestState {
    case unknown
    case success
    case failure
}

/// 单次激励候选素材（由 rewardAdSlots 映射，无 getOther）。
public final class LampsRewardAdModel: NSObject {
    public let slot: LampsRewardAdSlot
    public let channel: LampsRewardChannel
    public var price: CGFloat = 0
    public var bidfloor: CGFloat = 0
    public var timeoutMs: Int
    public var userId: String
    var requestState: LampsRewardRequestState = .unknown

    public var slotId: String { slot.slotId }

    public init(slot: LampsRewardAdSlot, channel: LampsRewardChannel, timeoutMs: Int, userId: String) {
        self.slot = slot
        self.channel = channel
        self.timeoutMs = timeoutMs
        self.userId = userId
        super.init()
    }

    public var adInfo: [AnyHashable: Any] {
        [
            "slot_id": slotId,
            "channel": channel.name,
            "channel_id": slot.channelId,
            "channel_name": slot.channelName,
            "type": slot.type,
            "price": price,
            "increasePrice": price
        ]
    }
}
