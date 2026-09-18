import Foundation
import UIKit

/// Bridge 共用的客户端参数，供 `bridgeReady` 回给 H5、以及 `track` 上报。
enum LampsBridgeClientInfo {
    /// H5 展示形态。`embed`：`makeGameCenterView`；`page`：`showGameCenter` / `presentGameCenter`；其余为空。
    enum DisplayMode {
        static let embed = "embed"
        static let page = "page"
    }

    static func dictionary(displayMode: String = "", dayNightMode: LampsDayNightMode? = nil) -> [String: Any] {
        var info: [String: Any] = [:]
        info["ts"] = "\(Int(Date().timeIntervalSince1970))"
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
        info["packageName"] = Bundle.main.bundleIdentifier ?? ""
        info["appVer"] = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        info["osVer"] = UIDevice.current.systemVersion
        let screenPixels = UIScreen.main.nativeBounds.size
        info["clientWidth"] = "\(Int(screenPixels.width))"
        info["clientHeight"] = "\(Int(screenPixels.height))"
        info["statusBarHeight"] = "\(Int(LampsDeviceLayout.statusBarHeight.rounded()))"
        info["env"] = LampsEnvironmentStore.current.logName
        info["displayMode"] = displayMode
        info["night"] = Lamps.resolvedDayNightMode(dayNightMode).bridgeNightValue
        return info
    }
}
