import Foundation

enum LampsRewardMonitorReporter {
    static func reportRM(
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

    static func reportPM(model: LampsRewardAdModel) {
        guard let urls = Lamps.remoteConfig?.monitorLinks.pm, !urls.isEmpty else { return }
        LampsReporter.reportPM(urls: urls, adInfo: model.adInfo, extra: ["exposure_type": "1"])
    }

    static func reportCM(model: LampsRewardAdModel) {
        guard let urls = Lamps.remoteConfig?.monitorLinks.cm, !urls.isEmpty else { return }
        LampsReporter.reportCM(urls: urls, adInfo: model.adInfo, extra: nil)
    }

    static func reportWM(model: LampsRewardAdModel) {
        guard let urls = Lamps.remoteConfig?.monitorLinks.wm, !urls.isEmpty else { return }
        LampsReporter.reportWM(urls: urls, adInfo: model.adInfo, extra: nil)
    }

    static func reportREM(model: LampsRewardAdModel) {
        // REM 复用 wm 位或单独宏链接：若业务另有 rem 列表可再扩展；当前用 reward 场景 WM 之外走 REM 签名能力时由调用方传 URL。
        // 无专用 rem 列表时跳过。
        _ = model
    }
}
