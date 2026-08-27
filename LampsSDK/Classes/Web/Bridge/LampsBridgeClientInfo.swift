import Foundation
import UIKit

/// Bridge 共用的客户端参数，供 `bridgeReady` 回给 H5、以及 `track` 上报。
enum LampsBridgeClientInfo {
    static func dictionary() -> [String: Any] {
        var info: [String: Any] = [:]
        info["et"] = "\(Int(Date().timeIntervalSince1970))"
        info["ua"] = LampsDeviceInfo.userAgent
        info["ip"] = Lamps.remoteConfig?.clientIp ?? ""
        info["mac"] = LampsDeviceInfo.macAddress
        info["os"] = "iOS"
        info["appid"] = Lamps.config?.appId ?? ""
        info["sdkVersion"] = Lamps.sdkVersion
        info["phoneBrand"] = "APPLE"
        info["network"] = LampsDeviceInfo.network
        info["idfa"] = LampsDeviceInfo.idfa
        info["idfv"] = LampsDeviceInfo.idfv
        info["bundleName"] = Bundle.main.bundleIdentifier ?? ""
        info["appVer"] = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        info["platform"] = UIDevice.current.systemName
        info["osVer"] = UIDevice.current.systemVersion
        info["env"] = LampsEnvironmentStore.current.rawValue
        return info
    }
}
