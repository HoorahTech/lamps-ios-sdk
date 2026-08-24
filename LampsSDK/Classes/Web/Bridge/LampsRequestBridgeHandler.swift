import Foundation

/// 通用 HTTP：H5 `lamps.common.request`，走客户端 URLSession，不经过 WebView JS 网络。
@objcMembers
final class LampsRequestBridgeHandler: NSObject, LampsBridgeHandler {
    weak var bridge: LampsBridge?

    var supportedMethods: [String] {
        [Method.request]
    }

    func handle(
        method: String,
        data: [AnyHashable: Any],
        success: LampsBridgeToH5Callback?,
        error: LampsBridgeToH5Callback?
    ) {
        guard method == Method.request else {
            fail(error, message: "unsupported method: \(method)")
            return
        }

        let urlString = stringValue(data["url"])
        guard let url = makeHTTPURL(from: urlString) else {
            fail(error, message: "url 无效，须为完整 http(s) URL")
            return
        }

        let methodName = stringValue(data["method"]).lowercased()
        guard methodName == "get" || methodName == "post" else {
            fail(error, message: "method 仅支持 get 或 post")
            return
        }

        let params = dictionaryValue(data["data"])
        let headers = dictionaryValue(data["header"])
        guard let request = makeRequest(
            url: url,
            method: methodName,
            params: params,
            headers: headers
        ) else {
            fail(error, message: "请求组装失败")
            return
        }

        LampsSDKLog.debug("bridge http \(methodName.uppercased()) \(request.url?.absoluteString ?? "")")
        URLSession.shared.dataTask(with: request) { data, response, requestError in
            DispatchQueue.main.async {
                if let requestError = requestError {
                    self.fail(error, message: requestError.localizedDescription)
                    return
                }
                let http = response as? HTTPURLResponse
                let status = http?.statusCode ?? 0
                let statusText = HTTPURLResponse.localizedString(forStatusCode: status)
                let body = self.encodeURIComponent(self.bodyString(from: data))
                success?([
                    "msg": "",
                    "data": [
                        "status": status,
                        "statusText": statusText,
                        "data": body
                    ]
                ])
            }
        }.resume()
    }
}

private extension LampsRequestBridgeHandler {
    enum Method {
        static let request = "lamps.common.request"
    }

    func fail(_ error: LampsBridgeToH5Callback?, message: String) {
        LampsSDKLog.debug("bridge http fail: \(message)")
        error?([
            "msg": message,
            "data": [:]
        ])
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

    func makeRequest(
        url: URL,
        method: String,
        params: [String: Any],
        headers: [String: Any]
    ) -> URLRequest? {
        var requestURL = url
        if method == "get", !params.isEmpty {
            guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                return nil
            }
            var items = components.queryItems ?? []
            for (key, value) in params {
                items.append(URLQueryItem(name: key, value: queryValue(value)))
            }
            components.queryItems = items
            guard let built = components.url else { return nil }
            requestURL = built
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = method.uppercased()
        request.timeoutInterval = 15
        applyHeaders(&request, headers)

        if method == "post", !params.isEmpty {
            let contentType = headerValue(headers, name: "Content-Type") ?? ""
            if isJSONContentType(contentType) {
                guard JSONSerialization.isValidJSONObject(params),
                      let body = try? JSONSerialization.data(withJSONObject: params) else {
                    return nil
                }
                request.httpBody = body
                if contentType.isEmpty {
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                }
            } else {
                request.httpBody = formBody(params)
                if contentType.isEmpty {
                    request.setValue(
                        "application/x-www-form-urlencoded; charset=utf-8",
                        forHTTPHeaderField: "Content-Type"
                    )
                }
            }
        }
        return request
    }

    func applyHeaders(_ request: inout URLRequest, _ headers: [String: Any]) {
        for (key, value) in headers {
            if key.caseInsensitiveCompare("Referer") == .orderedSame {
                continue
            }
            request.setValue(queryValue(value), forHTTPHeaderField: key)
        }
    }

    func headerValue(_ headers: [String: Any], name: String) -> String? {
        for (key, value) in headers {
            if key.caseInsensitiveCompare(name) == .orderedSame {
                let text = queryValue(value).trimmingCharacters(in: .whitespacesAndNewlines)
                return text.isEmpty ? nil : text
            }
        }
        return nil
    }

    func isJSONContentType(_ value: String) -> Bool {
        value.lowercased().contains("application/json")
    }

    func formBody(_ params: [String: Any]) -> Data {
        var components = URLComponents()
        components.queryItems = params.map { URLQueryItem(name: $0.key, value: queryValue($0.value)) }
        return Data((components.percentEncodedQuery ?? "").utf8)
    }

    func bodyString(from data: Data?) -> String {
        guard let data = data, !data.isEmpty else { return "" }
        if let text = String(data: data, encoding: .utf8) {
            return text
        }
        return String(data: data, encoding: .isoLatin1) ?? ""
    }

    /// 与 JS `encodeURIComponent` 对齐，供 H5 `decodeURIComponent`。
    func encodeURIComponent(_ string: String) -> String {
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-_.!~*'()")
        return string.addingPercentEncoding(withAllowedCharacters: allowed) ?? string
    }

    func dictionaryValue(_ value: Any?) -> [String: Any] {
        guard let dict = value as? [AnyHashable: Any] else { return [:] }
        var result: [String: Any] = [:]
        for (key, item) in dict {
            result[String(describing: key)] = item
        }
        return result
    }

    func queryValue(_ value: Any) -> String {
        if value is NSNull {
            return ""
        }
        if let text = value as? String {
            return text
        }
        if let number = value as? NSNumber {
            if CFBooleanGetTypeID() == CFGetTypeID(number) {
                return number.boolValue ? "true" : "false"
            }
            return number.stringValue
        }
        if JSONSerialization.isValidJSONObject(value),
           let data = try? JSONSerialization.data(withJSONObject: value, options: []),
           let text = String(data: data, encoding: .utf8) {
            return text
        }
        return String(describing: value)
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
