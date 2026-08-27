import Foundation
import UIKit

/// 性能/事件上报：H5 `lamps.common.track`。
/// Native 请求当前环境 `baseURL` + `/api/v1/event/report`。
/// 外层为客户端参数 + `action`（access / click / exposure）+ `vt` / `lt`。
/// `vt` / `lt` 无论是 Native 补的还是 H5 传入的，都放在外层，不进 `pdata`。
/// H5 `data` 其余字段放在 `pdata`。
/// H5 `type` 表示行为类型；`type == page_load` 时对齐 `HCWebViewHermesBridgeHandler` 的 onload：
/// 先缓存，可见时段结束时上报并补 `vt` / `lt`（秒级时间戳）；缓存保留以便
/// 进后台/盖住后再回来重新计时。仅容器销毁时清空缓存。
/// 请求 body：JSON UTF-8 → GZIP → Base64（无换行）。
@objcMembers
final class LampsTrackBridgeHandler: NSObject, LampsBridgeHandler {
    weak var bridge: LampsBridge?

    private var pendingPageLoads: [PendingPageLoad] = []
    private var appObservers: [NSObjectProtocol] = []

    override init() {
        super.init()
        observeAppLifecycle()
    }

    deinit {
        appObservers.forEach { NotificationCenter.default.removeObserver($0) }
    }

    var supportedMethods: [String] {
        [Method.track]
    }

    func handle(
        method: String,
        data: [AnyHashable: Any],
        success: LampsBridgeToH5Callback?,
        error: LampsBridgeToH5Callback?
    ) {
        guard method == Method.track else {
            error?(["msg": "unsupported method: \(method)"])
            return
        }

        if stringValue(data["type"]) == TrackType.pageLoad {
            pendingPageLoads.append(
                PendingPageLoad(data: data, visitTime: Self.timestampSeconds())
            )
            LampsSDKLog.debug("bridge track page_load cached, wait for container disappear")
            success?(["msg": ""])
            return
        }

        sendTrack(from: data, extra: [:], success: success, error: error)
    }

    func containerWillAppear() {
        restartPendingVisitTime()
    }

    func containerWillDisappear() {
        reportPendingPageLoadsKeepingCache()
    }

    func containerDidDestroy() {
        pendingPageLoads.removeAll()
    }
}

private extension LampsTrackBridgeHandler {
    enum Method {
        static let track = "lamps.common.track"
    }

    enum TrackType {
        static let pageLoad = "page_load"
    }

    enum OuterField {
        static let action = "action"
        static let visitTime = "vt"
        static let leaveTime = "lt"
    }

    struct PendingPageLoad {
        let data: [AnyHashable: Any]
        var visitTime: Int64
    }

    static let path = "/api/v1/event/report"

    static func timestampSeconds() -> Int64 {
        Int64(Date().timeIntervalSince1970)
    }

    var isContainerVisible: Bool {
        bridge?.webView?.window != nil
    }

    func stringValue(_ value: Any?) -> String {
        if let text = value as? String {
            return text
        }
        if let number = value as? NSNumber {
            return number.stringValue
        }
        return ""
    }

    func observeAppLifecycle() {
        let center = NotificationCenter.default
        appObservers.append(center.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self, self.isContainerVisible else { return }
            self.reportPendingPageLoadsKeepingCache()
        })
        appObservers.append(center.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self, self.isContainerVisible else { return }
            self.restartPendingVisitTime()
        })
    }

    func restartPendingVisitTime() {
        guard !pendingPageLoads.isEmpty else { return }
        let now = Self.timestampSeconds()
        for index in pendingPageLoads.indices {
            pendingPageLoads[index].visitTime = now
        }
        LampsSDKLog.debug("bridge track page_load restart vt=\(now)")
    }

    func reportPendingPageLoadsKeepingCache() {
        guard !pendingPageLoads.isEmpty else { return }
        let leaveTime = Self.timestampSeconds()
        LampsSDKLog.debug("bridge track page_load flush count=\(pendingPageLoads.count) lt=\(leaveTime)")
        for item in pendingPageLoads {
            sendTrack(
                from: item.data,
                extra: [
                    OuterField.visitTime: "\(item.visitTime)",
                    OuterField.leaveTime: "\(leaveTime)"
                ],
                success: nil,
                error: nil
            )
        }
    }

    func makeReportURL() -> URL? {
        URL(string: LampsEnvironmentStore.current.baseURL + Self.path)
    }

    func makeReportBody(from data: [AnyHashable: Any], extra: [String: String]) -> [String: Any] {
        var body = LampsBridgeClientInfo.dictionary()
        body[OuterField.action] = stringValue(data[OuterField.action])
        var pdata: [String: Any] = [:]
        for (key, value) in data {
            let name = String(describing: key)
            if name == OuterField.action {
                continue
            }
            if name == OuterField.visitTime || name == OuterField.leaveTime {
                let text = stringValue(value)
                if !text.isEmpty {
                    body[name] = text
                }
                continue
            }
            pdata[name] = stringValue(value)
        }
        body["pdata"] = pdata
        extra.forEach { body[$0.key] = $0.value }
        return body
    }

    func sendTrack(
        from data: [AnyHashable: Any],
        extra: [String: String],
        success: LampsBridgeToH5Callback?,
        error: LampsBridgeToH5Callback?
    ) {
        guard let url = makeReportURL() else {
            error?(["msg": "上报地址无效"])
            return
        }

        let params = makeReportBody(from: data, extra: extra)
        guard JSONSerialization.isValidJSONObject(params),
              let jsonUTF8 = try? JSONSerialization.data(withJSONObject: params) else {
            error?(["msg": "data 无法序列化为 JSON"])
            return
        }
        guard let gzipData = LampsGzip.compress(jsonUTF8) else {
            error?(["msg": "gzip 压缩失败"])
            return
        }
        let body = gzipData.base64EncodedData(options: [])
        postTrack(url: url, body: body, success: success, error: error)
    }

    func postTrack(
        url: URL,
        body: Data,
        success: LampsBridgeToH5Callback?,
        error: LampsBridgeToH5Callback?
    ) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 15
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = body
        LampsSDKLog.debug("bridge track POST \(url.absoluteString)")
        URLSession.shared.dataTask(with: request) { _, response, requestError in
            DispatchQueue.main.async {
                if let requestError = requestError {
                    LampsSDKLog.debug("bridge track fail: \(requestError.localizedDescription)")
                    error?(["msg": requestError.localizedDescription])
                    return
                }
                let status = (response as? HTTPURLResponse)?.statusCode ?? 0
                LampsSDKLog.debug("bridge track done status=\(status)")
                if (200..<300).contains(status) {
                    success?(["msg": ""])
                } else {
                    error?(["msg": "http \(status)"])
                }
            }
        }.resume()
    }
}
