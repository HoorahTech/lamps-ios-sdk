import Foundation

/// 性能/事件上报：H5 `lamps.common.track`，Native 对入参 `url` 直接 GET。
/// `type` 为预留字段，暂不参与业务判断。
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

        let urlString = stringValue(data["url"])
        guard let url = makeHTTPURL(from: urlString) else {
            error?(["msg": "url 无效，须为完整 http(s) URL"])
            return
        }

        sendTrack(url: url, success: success, error: error)
    }
}

private extension LampsTrackBridgeHandler {
    enum Method {
        static let track = "lamps.common.track"
    }

    func makeHTTPURL(from string: String) -> URL? {
        guard let url = URL(string: string), let scheme = url.scheme?.lowercased() else {
            return nil
        }
        guard scheme == "http" || scheme == "https", url.host != nil else {
            return nil
        }
        return url
    }

    func sendTrack(
        url: URL,
        success: LampsBridgeToH5Callback?,
        error: LampsBridgeToH5Callback?
    ) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 15
        LampsSDKLog.debug("bridge track GET \(url.absoluteString)")
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

    func stringValue(_ value: Any?) -> String {
        if let text = value as? String {
            return text.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if let number = value as? NSNumber {
            return number.stringValue
        }
        return ""
    }
}
