import Foundation

/// 监测上报入口：宏替换后 GET。
/// 支持 RM / WM / CM / PM / REM，不区分 SDK 与 API。
@objcMembers
public final class LampsReporter: NSObject {
    /// 统一上报。
    @objc(reportWithType:urls:adInfo:extra:)
    public static func report(
        type: LampsReportType,
        urls: [String],
        adInfo: [AnyHashable: Any]? = nil,
        extra: [AnyHashable: Any]? = nil
    ) {
        guard Lamps.isStarted else {
            LampsSDKLog.debug("report \(type.name) skipped: SDK not started")
            return
        }
        let validURLs = urls
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard !validURLs.isEmpty else {
            LampsSDKLog.debug("report \(type.name) skipped: empty urls")
            return
        }

        let replaced = LampsMacroReplacer.replace(
            urls: validURLs,
            type: type,
            adInfo: adInfo,
            extra: filledExtra(extra)
        )
        LampsSDKLog.debug("report \(type.name) count=\(replaced.count)")
        LampsReportRequest.start(urls: replaced)
    }

    @objc(reportRMWithURLs:adInfo:extra:)
    public static func reportRM(urls: [String], adInfo: [AnyHashable: Any]? = nil, extra: [AnyHashable: Any]? = nil) {
        report(type: .rm, urls: urls, adInfo: adInfo, extra: extra)
    }

    @objc(reportWMWithURLs:adInfo:extra:)
    public static func reportWM(urls: [String], adInfo: [AnyHashable: Any]? = nil, extra: [AnyHashable: Any]? = nil) {
        report(type: .wm, urls: urls, adInfo: adInfo, extra: extra)
    }

    @objc(reportCMWithURLs:adInfo:extra:)
    public static func reportCM(urls: [String], adInfo: [AnyHashable: Any]? = nil, extra: [AnyHashable: Any]? = nil) {
        report(type: .cm, urls: urls, adInfo: adInfo, extra: extra)
    }

    @objc(reportPMWithURLs:adInfo:extra:)
    public static func reportPM(urls: [String], adInfo: [AnyHashable: Any]? = nil, extra: [AnyHashable: Any]? = nil) {
        report(type: .pm, urls: urls, adInfo: adInfo, extra: extra)
    }

    @objc(reportREMWithURLs:adInfo:extra:)
    public static func reportREM(urls: [String], adInfo: [AnyHashable: Any]? = nil, extra: [AnyHashable: Any]? = nil) {
        report(type: .rem, urls: urls, adInfo: adInfo, extra: extra)
    }

    private static func filledExtra(_ extra: [AnyHashable: Any]?) -> [AnyHashable: Any] {
        var result = extra ?? [:]
        let now = Date().timeIntervalSince1970
        if result["et"] == nil && result["__EVENT_TIME_S__"] == nil {
            result["et"] = "\(Int(now))"
        }
        if result["et_ms"] == nil && result["__EVENT_TIME_MS__"] == nil {
            result["et_ms"] = "\(Int(now * 1000))"
        }
        return result
    }
}
