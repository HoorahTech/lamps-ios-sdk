import Foundation

/// 监测 URL GET 上报。
enum LampsReportRequest {
    static func start(urls: [String]) {
        for urlString in urls {
            start(urlString: urlString)
        }
    }

    private static func start(urlString: String) {
        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.lowercased().hasPrefix("http") else {
            LampsSDKLog.debug("report skip invalid url: \(trimmed)")
            return
        }
        guard let url = URL(string: trimmed) else {
            LampsSDKLog.debug("report skip unparsable url: \(trimmed)")
            return
        }
        LampsSDKLog.debug("report request: \(trimmed)")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 15
        let ua = LampsDeviceInfo.userAgent
        if !ua.isEmpty {
            request.setValue(ua, forHTTPHeaderField: "User-Agent")
        }
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                LampsSDKLog.debug("report fail: \(error.localizedDescription) url=\(trimmed)")
                return
            }
            let code = (response as? HTTPURLResponse)?.statusCode ?? -1
            LampsSDKLog.debug("report done status=\(code) url=\(trimmed)")
        }.resume()
    }
}
