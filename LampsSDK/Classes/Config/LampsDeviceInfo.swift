import Foundation
import UIKit
import WebKit
import AdSupport
import Darwin
import SystemConfiguration
import CoreTelephony
#if canImport(AppTrackingTransparency)
import AppTrackingTransparency
#endif

enum LampsDeviceInfo {
    private static let userAgentCacheKey = "com.hupu.lamps.sdk.userAgent"
    private static let placeholderMacAddress = "02:00:00:00:00:00"
    private static var cachedUserAgent: String?
    private static var userAgentWebView: WKWebView?

    static var os: String {
        "iOS"
    }

    /// 当前网络环境：`wifi` / `2g` / `3g` / `4g` / `5g` / `unknown`。
    static var network: String {
        guard let flags = reachabilityFlags else { return "unknown" }
        guard flags.contains(.reachable) else { return "unknown" }
        if flags.contains(.isWWAN) {
            return cellularNetworkType
        }
        return "wifi"
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

    /// 读取系统 IDFV（`identifierForVendor`）；不可用时返回空字符串。
    static var idfv: String {
        UIDevice.current.identifierForVendor?.uuidString ?? ""
    }

    /// Wi‑Fi 接口（en0）MAC。
    /// 说明：iOS 7+ 系统对第三方 App 限制真实 MAC，多数机型会返回占位值 `02:00:00:00:00:00`。
    static var macAddress: String {
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr else {
            return placeholderMacAddress
        }
        defer { freeifaddrs(ifaddr) }

        var pointer: UnsafeMutablePointer<ifaddrs>? = firstAddr
        while let interface = pointer {
            defer { pointer = interface.pointee.ifa_next }

            let name = String(cString: interface.pointee.ifa_name)
            guard name == "en0" else { continue }
            guard let addr = interface.pointee.ifa_addr else { continue }
            guard addr.pointee.sa_family == UInt8(AF_LINK) else { continue }

            let mac = addr.withMemoryRebound(to: sockaddr_dl.self, capacity: 1) { sdl -> String? in
                let length = Int(sdl.pointee.sdl_alen)
                guard length == 6 else { return nil }
                let nameLen = Int(sdl.pointee.sdl_nlen)
                return withUnsafeBytes(of: sdl.pointee.sdl_data) { raw -> String? in
                    guard let base = raw.baseAddress, raw.count >= nameLen + length else { return nil }
                    let bytes = UnsafeBufferPointer(
                        start: base.assumingMemoryBound(to: UInt8.self).advanced(by: nameLen),
                        count: length
                    )
                    return bytes.map { String(format: "%02x", $0) }.joined(separator: ":")
                }
            }
            if let mac, !mac.isEmpty {
                return mac
            }
        }
        return placeholderMacAddress
    }

    /// WebKit UA（优先缓存 / 磁盘；未就绪时用本地降级串，避免宏替换阻塞）。
    static var userAgent: String {
        if let cachedUserAgent, !cachedUserAgent.isEmpty {
            return cachedUserAgent
        }
        if let stored = UserDefaults.standard.string(forKey: userAgentCacheKey)?
            .trimmingCharacters(in: .whitespacesAndNewlines),
           !stored.isEmpty {
            cachedUserAgent = stored
            return stored
        }
        return fallbackUserAgent
    }

    /// 在主线程预取真实 `navigator.userAgent`，供宏 `__UA__` 使用。启动时调用一次即可。
    static func prepareUserAgentIfNeeded() {
        let run: () -> Void = {
            if let cachedUserAgent, !cachedUserAgent.isEmpty {
                return
            }
            if let stored = UserDefaults.standard.string(forKey: userAgentCacheKey)?
                .trimmingCharacters(in: .whitespacesAndNewlines),
               !stored.isEmpty {
                cachedUserAgent = stored
                return
            }

            let webView = WKWebView(frame: .zero)
            userAgentWebView = webView
            webView.evaluateJavaScript("navigator.userAgent") { result, error in
                let ua: String
                if let text = result as? String,
                   !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    ua = text
                } else {
                    LampsSDKLog.debug(
                        "userAgent fetch failed: \(error?.localizedDescription ?? "empty")"
                    )
                    ua = fallbackUserAgent
                }
                cachedUserAgent = ua
                userAgentWebView = nil
                UserDefaults.standard.set(ua, forKey: userAgentCacheKey)
                LampsSDKLog.debug("userAgent ready len=\(ua.count)")
            }
        }

        if Thread.isMainThread {
            run()
        } else {
            DispatchQueue.main.async(execute: run)
        }
    }

    private static var fallbackUserAgent: String {
        let version = UIDevice.current.systemVersion.replacingOccurrences(of: ".", with: "_")
        if UIDevice.current.userInterfaceIdiom == .pad {
            return "Mozilla/5.0 (iPad; CPU OS \(version) like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148"
        }
        return "Mozilla/5.0 (iPhone; CPU iPhone OS \(version) like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148"
    }

    private static var reachabilityFlags: SCNetworkReachabilityFlags? {
        var address = sockaddr_in()
        address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        address.sin_family = sa_family_t(AF_INET)
        let reachability = withUnsafePointer(to: &address) { pointer in
            pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }
        guard let reachability else { return nil }
        var flags = SCNetworkReachabilityFlags()
        guard SCNetworkReachabilityGetFlags(reachability, &flags) else { return nil }
        return flags
    }

    private static var cellularNetworkType: String {
        let info = CTTelephonyNetworkInfo()
        let technologies: [String]
        if let values = info.serviceCurrentRadioAccessTechnology?.values {
            technologies = Array(values)
        } else if let legacy = info.currentRadioAccessTechnology {
            technologies = [legacy]
        } else {
            technologies = []
        }
        guard let tech = technologies.first else { return "unknown" }

        let dual2G: Set<String> = [
            CTRadioAccessTechnologyGPRS,
            CTRadioAccessTechnologyEdge,
            CTRadioAccessTechnologyCDMA1x
        ]
        let dual3G: Set<String> = [
            CTRadioAccessTechnologyWCDMA,
            CTRadioAccessTechnologyHSDPA,
            CTRadioAccessTechnologyHSUPA,
            CTRadioAccessTechnologyCDMAEVDORev0,
            CTRadioAccessTechnologyCDMAEVDORevA,
            CTRadioAccessTechnologyCDMAEVDORevB,
            CTRadioAccessTechnologyeHRPD
        ]
        if dual2G.contains(tech) { return "2g" }
        if dual3G.contains(tech) { return "3g" }
        if tech == CTRadioAccessTechnologyLTE { return "4g" }
        if #available(iOS 14.1, *) {
            if tech == CTRadioAccessTechnologyNRNSA || tech == CTRadioAccessTechnologyNR {
                return "5g"
            }
        }
        return "unknown"
    }
}
