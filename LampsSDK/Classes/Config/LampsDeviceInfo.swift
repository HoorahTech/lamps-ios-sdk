import Foundation
import AdSupport
#if canImport(AppTrackingTransparency)
import AppTrackingTransparency
#endif

enum LampsDeviceInfo {
    static var appVersion: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String
        let trimmed = version?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? "0" : trimmed
    }

    static var os: String {
        "ios"
    }

    /// 读取系统 IDFA；未授权或不可用时返回空字符串，不主动弹 ATT 授权框。
    static var idfa: String {
        #if canImport(AppTrackingTransparency)
        if #available(iOS 14, *) {
            if ATTrackingManager.trackingAuthorizationStatus != .authorized {
                return ""
            }
        } else if !ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
            return ""
        }
        #else
        if !ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
            return ""
        }
        #endif
        let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        if idfa == "00000000-0000-0000-0000-000000000000" {
            return ""
        }
        return idfa
    }
}
