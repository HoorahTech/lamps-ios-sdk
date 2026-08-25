import Foundation

/// 性能/事件上报：H5 `lamps.common.track`。
/// Native 请求当前环境 `baseURL` + `/api/v1/event/report`。
/// 外层为客户端参数 + `type`，H5 `data` 其余字段放在 `pdata`。
/// 请求 body：JSON UTF-8 → GZIP → Base64（无换行）。
@objcMembers
final class LampsTrackBridgeHandler: NSObject, LampsBridgeHandler {
    weak var bridge: LampsBridge?

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

        guard let url = makeReportURL() else {
            error?(["msg": "上报地址无效"])
            return
        }

        let params = makeReportBody(from: data)
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
        sendTrack(url: url, body: body, success: success, error: error)
    }
}

private extension LampsTrackBridgeHandler {
    enum Method {
        static let track = "lamps.common.track"
    }

    static let path = "/api/v1/event/report"

    func makeReportURL() -> URL? {
        URL(string: LampsEnvironmentStore.current.baseURL + Self.path)
    }

    func makeReportBody(from data: [AnyHashable: Any]) -> [String: Any] {
        var body = LampsBridgeClientInfo.dictionary()
        body["type"] = ""
        var pdata: [String: Any] = [:]
        for (key, value) in data {
            let name = String(describing: key)
            if name == "type" {
                body["type"] = value as? String ?? ""
            } else {
                pdata[name] = value as? String ?? ""
            }
        }
        body["pdata"] = pdata
        return body
    }

    func sendTrack(
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
