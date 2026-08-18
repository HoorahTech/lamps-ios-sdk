import Foundation

/// 监测上报入口，对齐 HCADManager 的 CM / PM / XM。
/// 第一阶段只保留方法签名，真正的宏替换与请求在后续阶段实现。
@objcMembers
public final class LampsReporter: NSObject {
    /// 点击监测。
    @objc(reportCMWithURLs:extra:)
    public static func reportCM(urls: [String], extra: [AnyHashable: Any]?) {
        report(type: "CM", urls: urls, extra: extra)
    }

    /// 曝光监测。
    @objc(reportPMWithURLs:extra:)
    public static func reportPM(urls: [String], extra: [AnyHashable: Any]?) {
        report(type: "PM", urls: urls, extra: extra)
    }

    /// 关闭监测。
    @objc(reportXMWithURLs:extra:)
    public static func reportXM(urls: [String], extra: [AnyHashable: Any]?) {
        report(type: "XM", urls: urls, extra: extra)
    }

    private static func report(type: String, urls: [String], extra: [AnyHashable: Any]?) {
        guard LampsSDK.isStarted else {
            LampsSDKLog.debug("report \(type) skipped: SDK not started")
            return
        }
        LampsSDKLog.debug("report \(type) placeholder, count=\(urls.count) extra=\(String(describing: extra))")
    }
}
