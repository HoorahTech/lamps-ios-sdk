import Foundation
import UIKit
import CommonCrypto

/// 监测 URL 宏替换。不区分 SDK / API，按上报类型组装替换字典后做字符串替换。
enum LampsMacroReplacer {
    static func replace(
        urls: [String],
        type: LampsReportType,
        adInfo: [AnyHashable: Any]?,
        extra: [AnyHashable: Any]?
    ) -> [String] {
        let replaceInfo = buildReplaceInfo(type: type, adInfo: adInfo, extra: extra)
        var result = urls.map { replaceMacros(in: $0, with: replaceInfo) }
        if type == .rem || type == .pm {
            result = result.map { replaceRemSignIfNeeded(in: $0) }
        }
        return result
    }

    private static func buildReplaceInfo(
        type: LampsReportType,
        adInfo: [AnyHashable: Any]?,
        extra: [AnyHashable: Any]?
    ) -> [String: String] {
        var info: [String: String] = [:]
        let ad = adInfo ?? [:]
        let ex = extra ?? [:]

        // 通用时间、OS
        let now = Date().timeIntervalSince1970
        put(&info, "__TS__", "\(Int(now))")
        put(&info, "__OS__", "iOS")

        // 屏幕物理像素
        let screenPixels = UIScreen.main.nativeBounds.size
        put(&info, "__SW__", "\(Int(screenPixels.width))")
        put(&info, "__SH__", "\(Int(screenPixels.height))")

        // User-Agent（start 时预取；未就绪用降级串）
        put(&info, "__UA__", LampsDeviceInfo.userAgent)

        // MAC（iOS 上多为占位 02:00:00:00:00:00）
        put(&info, "__MAC__", LampsDeviceInfo.macAddress)

        // IDFA（未授权或不可用时为空；不主动弹 ATT）
        put(&info, "__IDFA__", LampsDeviceInfo.idfa)

        // IDFV（identifierForVendor；不可用时为空）
        put(&info, "__IDFV__", LampsDeviceInfo.idfv)

        // SDK 分配的 appId / SDK 版本 / 宿主 App 包名
        put(&info, "__APPID__", Lamps.config?.appId ?? "")
        put(&info, "__SDK_VERSION__", Lamps.sdkVersion)
        put(&info, "__PACKAGE_NAME__", Bundle.main.bundleIdentifier ?? "")

        // 网络环境：wifi / 2g / 3g / 4g / 5g / unknown
        put(&info, "__NETWORK__", LampsDeviceInfo.network)

        // 客户端 IP（配置接口返回的 clientIp）
        put(&info, "__IP__", Lamps.remoteConfig?.clientIp ?? "")

        // 价格
        if let price = firstString(ex, ad, key: "price") {
            put(&info, "__PRICE__", price)
        }

        // requestId
        if let requestId = firstString(ex, ad, key: "request_id") {
            put(&info, "__REQUEST_ID__", requestId)
        }

        // 联盟名按渠道和代码位 type（BD / PD）拼接，不直接用配置里的 channelName。
        if let unionName = unionName(ad: ad, extra: ex) {
            put(&info, "__UNION_NAME__", unionName)
        }

        // slot_id
        if let slotId = firstString(ex, ad, key: "slot_id") {
            put(&info, "__SLOTID__", slotId)
        }

        // forward_source
        if let forward_source = firstString(ex, ad, key: "forward_source") {
            put(&info, "__FORWARD_SOURCE__", forward_source)
        }

        // phone_brand
        put(&info, "__PHONE_BRAND__", "APPLE")
        
        switch type {
        case .rm:
            put(&info, "__IS_SUCCESS__", firstString(ex, key: "is_success"))
            put(&info, "__CODE__", firstString(ex, key: "error_code"))
        case .wm:
            break
        case .cm:
            break
        case .pm:
            break
        case .rem:
            put(&info, "__ACTION__", "30")
            break
        }

        // extra 里直接带 `__XXX__` 的键优先生效
        for (key, value) in ex {
            guard let key = key as? String, key.hasPrefix("__"), key.hasSuffix("__") else { continue }
            put(&info, key, LampsJSONValue.stringValue(value))
        }
        return info
    }

    private static func replaceMacros(in url: String, with replaceInfo: [String: String]) -> String {
        var result = url
        for (macro, value) in replaceInfo {
            let encoded = value.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed.subtracting(CharacterSet(charactersIn: ":/?#[]@!$&'()*+,;="))) ?? value
            result = result.replacingOccurrences(of: macro, with: encoded)
        }
        return result
    }

    /// REM：query 6 参字母升序拼接 + 远端 token，MD5 小写 hex 替换 `__REM_SIGN__`
    private static func replaceRemSignIfNeeded(in url: String) -> String {
        guard url.contains("__REM_SIGN__") else { return url }
        let key = Lamps.effectiveRewardSignKey
        guard !key.isEmpty else { return url }
        let sign = remSign(for: url, rewardSignKey: key) ?? ""
        return url.replacingOccurrences(of: "__REM_SIGN__", with: sign)
    }

    private static func remSign(for urlString: String, rewardSignKey: String) -> String? {
        let signKeys = ["appid", "forwardSource", "price", "requestId", "sdkVersion", "slotId"]
        let query = queryParameters(from: urlString)
        var parts: [String] = []
        for key in signKeys {
            guard let value = query[key], !value.isEmpty else { continue }
            parts.append("\(key)=\(value)")
        }
        let raw = parts.joined(separator: "&") + rewardSignKey
        return md5Hex(raw)
    }

    private static func queryParameters(from urlString: String) -> [String: String] {
        guard let components = URLComponents(string: urlString) else { return [:] }
        var params: [String: String] = [:]
        for item in components.queryItems ?? [] {
            guard let value = item.value, !value.isEmpty else { continue }
            params[item.name] = value
        }
        return params
    }

    private static func md5Hex(_ string: String) -> String {
        let data = Data(string.utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        data.withUnsafeBytes { buffer in
            _ = CC_MD5(buffer.baseAddress, CC_LONG(data.count), &digest)
        }
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    /// `__UNION_NAME__`：穿山甲 / 优量汇按代码位 `type` 拼成「穿山甲BD」或「穿山甲PD」；汇川固定为汇川 SDK。
    private static func unionName(ad: [AnyHashable: Any], extra: [AnyHashable: Any]) -> String? {
        let raw = firstString(extra, ad, key: "channel_id")
            ?? firstString(extra, ad, key: "channel_name")
        guard let raw else { return nil }
        let key = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        let bidType = (firstString(extra, ad, key: "type") ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()
        let suffix = (bidType == "BD" || bidType == "PD") ? bidType : ""
        switch key.uppercased() {
        case "CSJ", "穿山甲":
            return "穿山甲" + suffix
        case "GDT", "优量汇":
            return "优量汇" + suffix
        case "NOAH", "汇川":
            return "汇川SDK"
        default:
            return firstString(extra, ad, key: "channel_name") ?? key
        }
    }

    private static func put(_ info: inout [String: String], _ key: String, _ value: String?) {
        guard let value = value, !value.isEmpty else { return }
        info[key] = value
    }

    private static func firstString(_ dicts: [AnyHashable: Any]..., key: String) -> String? {
        for dict in dicts {
            let value = LampsJSONValue.stringValue(dict[key])
            if !value.isEmpty {
                return value
            }
        }
        return nil
    }
}
