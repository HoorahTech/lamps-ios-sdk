import Foundation

enum LampsConfigService {
    private static let path = "/v1/lamps/config"
    private static let successCode = 0

    static func fetch(
        config: LampsSDKConfig,
        completion: @escaping (Result<LampsRemoteConfig, Error>) -> Void
    ) {
        guard var components = URLComponents(string: LampsEnvironmentStore.current.baseURL + path) else {
            completion(.failure(LampsSDKError.invalidURL("配置接口地址无效").nsError))
            return
        }
        components.queryItems = [
            URLQueryItem(name: "appid", value: config.appId),
            URLQueryItem(name: "version", value: LampsDeviceInfo.appVersion),
            URLQueryItem(name: "idfa", value: LampsDeviceInfo.idfa),
            URLQueryItem(name: "os", value: LampsDeviceInfo.os)
        ]
        guard let url = components.url else {
            completion(.failure(LampsSDKError.invalidURL("配置接口 URL 组装失败").nsError))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 15

        LampsSDKLog.debug("config request: \(url.absoluteString)")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(LampsSDKError.network("配置请求失败: \(error.localizedDescription)").nsError))
                return
            }
            let status = (response as? HTTPURLResponse)?.statusCode ?? -1
            guard let data = data, !data.isEmpty else {
                completion(.failure(LampsSDKError.api("配置响应为空, http=\(status)").nsError))
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                guard let root = json as? [String: Any] else {
                    completion(.failure(LampsSDKError.api("配置响应格式错误").nsError))
                    return
                }
                let code = intValue(root["code"])
                let message = stringValue(root["message"]) ?? ""
                guard code == successCode else {
                    completion(.failure(LampsSDKError.api("配置失败 code=\(code) message=\(message)").nsError))
                    return
                }
                guard let dataObject = root["data"] as? [String: Any],
                      let remote = LampsRemoteConfig.parse(from: dataObject) else {
                    completion(.failure(LampsSDKError.api("配置 data 解析失败").nsError))
                    return
                }
                LampsConfigCache.save(
                    dataDictionary: dataObject,
                    appId: config.appId,
                    environment: LampsEnvironmentStore.current
                )
                LampsSDKLog.debug(
                    "config ok slots=\(remote.rewardAdSlots.count) tokenLen=\(remote.token.count) ip=\(remote.clientIp)"
                )
                completion(.success(remote))
            } catch {
                completion(.failure(LampsSDKError.api("配置 JSON 解析失败: \(error.localizedDescription)").nsError))
            }
        }.resume()
    }

    private static func intValue(_ value: Any?) -> Int {
        if let number = value as? NSNumber { return number.intValue }
        if let text = value as? String { return Int(text) ?? -1 }
        return -1
    }

    private static func stringValue(_ value: Any?) -> String? {
        if let text = value as? String { return text }
        if let number = value as? NSNumber { return number.stringValue }
        return nil
    }
}
