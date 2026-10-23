import Foundation
import CoreGraphics

/// 穿山甲 BD 服务端竞价结果。仅 Adapter 跨模块 SPI。
@_spi(LampsAdapter)
public struct LampsRewardServerBidResult {
    public let adm: String
    public let price: CGFloat
}

/// POST `/api/v1/advertisement/bid`，用穿山甲 bidding token 换服务端胜出 adm。
/// 仅 Adapter 跨模块 SPI，宿主普通 import 不可见。
@_spi(LampsAdapter)
public enum LampsRewardServerBid {
    private static let path = "/api/v1/advertisement/bid"

    public static func fetch(
        ttToken: String,
        slotId: String,
        requestId: String,
        completion: @escaping (Result<LampsRewardServerBidResult, Error>) -> Void
    ) {
        let appId = Lamps.config?.appId.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !appId.isEmpty else {
            completion(.failure(LampsSDKError.rewardLoadError("穿山甲竞价 appId 为空").nsError))
            return
        }
        guard let url = URL(string: LampsEnvironmentStore.current.baseURL + path) else {
            completion(.failure(LampsSDKError.rewardLoadError("穿山甲竞价接口地址无效").nsError))
            return
        }

        let body: [String: String] = [
            "ttToken": ttToken,
            "slotId": slotId,
            "appid": appId,
            "version": Lamps.sdkVersion,
            "os": LampsDeviceInfo.os,
            "requestId": requestId
        ]
        guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else {
            completion(.failure(LampsSDKError.rewardLoadError("穿山甲竞价请求体组装失败").nsError))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 3
        request.httpBody = httpBody

        LampsSDKLog.debug("reward bid request slotId=\(slotId) tokenLen=\(ttToken.count)")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(LampsSDKError.rewardLoadError("穿山甲竞价请求失败: \(error.localizedDescription)").nsError))
                return
            }
            let status = (response as? HTTPURLResponse)?.statusCode ?? -1
            guard (200..<300).contains(status) else {
                completion(.failure(LampsSDKError.rewardLoadError("穿山甲竞价请求失败, http=\(status)").nsError))
                return
            }
            guard let data = data, !data.isEmpty else {
                completion(.failure(LampsSDKError.rewardLoadError("穿山甲竞价响应为空, http=\(status)").nsError))
                return
            }
            completion(parse(data: data, slotId: slotId))
        }.resume()
    }

    private static func parse(data: Data, slotId: String) -> Result<LampsRewardServerBidResult, Error> {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            guard let root = json as? [String: Any] else {
                return .failure(LampsSDKError.rewardLoadError("穿山甲竞价响应格式错误").nsError)
            }
            guard let dataObject = root["data"] as? [String: Any],
                  let ads = dataObject["ads"] as? [String: Any] else {
                return .failure(LampsSDKError.rewardLoadError("穿山甲竞价缺少 ads").nsError)
            }
            let adm = LampsJSONValue.stringValue(ads["adm"], trim: true)
            guard !adm.isEmpty else {
                return .failure(LampsSDKError.rewardLoadError("穿山甲竞价 adm 为空").nsError)
            }
            let price = cgFloatValue(ads["price"])
            LampsSDKLog.debug("reward bid ok slotId=\(slotId) price=\(price) admLen=\(adm.count)")
            return .success(LampsRewardServerBidResult(adm: adm, price: price))
        } catch {
            return .failure(LampsSDKError.rewardLoadError("穿山甲竞价 JSON 解析失败: \(error.localizedDescription)").nsError)
        }
    }

    private static func cgFloatValue(_ value: Any?) -> CGFloat {
        if let number = value as? NSNumber { return CGFloat(truncating: number) }
        if let text = value as? String, let double = Double(text) { return CGFloat(double) }
        return 0
    }
}
