import Foundation

public enum LampsRewardMonitorReporter {
    public static func reportRM(
        model: LampsRewardAdModel,
        isSuccess: Bool,
        filterReason: String? = nil,
        delayTimeMs: Int? = nil,
        error: Error? = nil
    ) {
        guard let urls = Lamps.remoteConfig?.monitorLinks.rm, !urls.isEmpty else { return }
        var extra: [AnyHashable: Any] = ["is_success": isSuccess ? "1" : "0"]
        if let filterReason { extra["filter_reason"] = filterReason }
        if let delayTimeMs { extra["delay_time"] = "\(delayTimeMs)" }
        if let error { extra["error_code"] = "\((error as NSError).code)" }
        LampsReporter.reportRM(urls: urls, adInfo: model.adInfo, extra: extra)
    }

    public static func reportPM(model: LampsRewardAdModel) {
        guard let urls = Lamps.remoteConfig?.monitorLinks.pm, !urls.isEmpty else { return }
        LampsReporter.reportPM(urls: urls, adInfo: model.adInfo, extra: ["exposure_type": "1"])
    }

    public static func reportCM(model: LampsRewardAdModel) {
        guard let urls = Lamps.remoteConfig?.monitorLinks.cm, !urls.isEmpty else { return }
        LampsReporter.reportCM(urls: urls, adInfo: model.adInfo, extra: nil)
    }

    public static func reportWM(model: LampsRewardAdModel) {
        guard let urls = Lamps.remoteConfig?.monitorLinks.wm, !urls.isEmpty else { return }
        LampsReporter.reportWM(urls: urls, adInfo: model.adInfo, extra: nil)
    }

    public static func reportREM(model: LampsRewardAdModel) {
        guard let urls = Lamps.remoteConfig?.monitorLinks.dm, !urls.isEmpty else { return }
        LampsReporter.reportREM(urls: urls, adInfo: model.adInfo, extra: nil)
    }
}