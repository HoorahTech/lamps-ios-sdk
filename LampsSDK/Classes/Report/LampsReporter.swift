import Foundation

/// 监测上报入口：宏替换后 GET。仅 SDK 内部使用，不向宿主开放。
@objcMembers
final class LampsReporter: NSObject {
    /// 统一上报。
    @objc(reportWithType:urls:adInfo:extra:)
    static func report(
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
            extra: extra
        )
        LampsSDKLog.debug("report \(type.name) count=\(replaced.count)")
        LampsReportRequest.start(urls: replaced)
    }

    @objc(reportRMWithURLs:adInfo:extra:)
    static func reportRM(urls: [String], adInfo: [AnyHashable: Any]? = nil, extra: [AnyHashable: Any]? = nil) {
        report(type: .rm, urls: urls, adInfo: adInfo, extra: extra)
    }

    @objc(reportWMWithURLs:adInfo:extra:)
    static func reportWM(urls: [String], adInfo: [AnyHashable: Any]? = nil, extra: [AnyHashable: Any]? = nil) {
        report(type: .wm, urls: urls, adInfo: adInfo, extra: extra)
    }

    @objc(reportCMWithURLs:adInfo:extra:)
    static func reportCM(urls: [String], adInfo: [AnyHashable: Any]? = nil, extra: [AnyHashable: Any]? = nil) {
        report(type: .cm, urls: urls, adInfo: adInfo, extra: extra)
    }

    @objc(reportPMWithURLs:adInfo:extra:)
    static func reportPM(urls: [String], adInfo: [AnyHashable: Any]? = nil, extra: [AnyHashable: Any]? = nil) {
        report(type: .pm, urls: urls, adInfo: adInfo, extra: extra)
    }

    @objc(reportREMWithURLs:adInfo:extra:)
    static func reportREM(urls: [String], adInfo: [AnyHashable: Any]? = nil, extra: [AnyHashable: Any]? = nil) {
        report(type: .rem, urls: urls, adInfo: adInfo, extra: extra)
    }
}
