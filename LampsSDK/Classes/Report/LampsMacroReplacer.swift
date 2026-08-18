import Foundation
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
        if type == .rem {
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

        // 通用时间 / 位置
        let now = Date().timeIntervalSince1970
        put(&info, "__EVENT_TIME_S__", firstString(ex, keys: ["et", "__EVENT_TIME_S__"]) ?? "\(Int(now))")
        put(&info, "__EVENT_TIME_MS__", firstString(ex, keys: ["et_ms", "__EVENT_TIME_MS__"]) ?? "\(Int(now * 1000))")
        if let value = firstString(ex, keys: ["ts", "__DEVICE_ET__"]) {
            put(&info, "__DEVICE_ET__", value)
        }
        if let value = firstString(ex, keys: ["position", "__HPOS__"]) {
            put(&info, "__HPOS__", value)
        }

        // 点击坐标（CM 等）
        put(&info, "__DOWN_X__", firstString(ex, keys: ["down_x", "__DOWN_X__"]))
        put(&info, "__DOWN_Y__", firstString(ex, keys: ["down_y", "__DOWN_Y__"]))
        put(&info, "__UP_X__", firstString(ex, keys: ["up_x", "__UP_X__"]))
        put(&info, "__UP_Y__", firstString(ex, keys: ["up_y", "__UP_Y__"]))
        put(&info, "__WIDTH__", firstString(ex, keys: ["width", "__WIDTH__"]))
        put(&info, "__HEIGHT__", firstString(ex, keys: ["height", "__HEIGHT__"]))

        // 素材 / 落地
        put(&info, "__MATERIALURL__", firstString(ex, ad, keys: ["material_url", "img", "video_url", "__MATERIALURL__"]))
        put(&info, "__CLICKURL__", firstString(ex, ad, keys: ["click_url", "lp", "deep_link", "__CLICKURL__"]))

        switch type {
        case .rm:
            put(&info, "__IS_SUCCESS__", firstString(ex, keys: ["is_success", "__IS_SUCCESS__"]) ?? "1")
            put(&info, "__FILTER_REASON__", firstString(ex, keys: ["sdk_disable_type", "filter_reason", "__FILTER_REASON__"]) ?? "1")
            put(&info, "__DELAY_TIME__", firstString(ex, keys: ["delay_time", "__DELAY_TIME__"]))
            put(&info, "__CODE__", firstString(ex, keys: ["error_code", "code", "__CODE__"]))
        case .wm:
            put(&info, "__BRAND_NAME__", firstString(ex, ad, keys: ["brand_name", "__BRAND_NAME__"]))
            put(&info, "__TITLE__", firstString(ex, ad, keys: ["title", "__TITLE__"]))
            put(&info, "__SHOW_TYPE__", firstString(ex, ad, keys: ["show_type", "__SHOW_TYPE__"]))
            put(&info, "__ADDPROFIT__", firstString(ex, ad, keys: ["increasePrice", "add_profit", "__ADDPROFIT__"]))
            put(&info, "__STAGE_COST__", firstString(ex, ad, keys: ["wm_report_timestamp", "stage_cost", "__STAGE_COST__"]))
            if intValue(ad, key: "reachTimeLimit") != 0 {
                put(&info, "__AD_TIMEOUT__", "达到整体时限")
            }
        case .cm:
            put(&info, "__LINK_TYPE__", firstString(ex, keys: ["linkType", "link_type", "__LINK_TYPE__"]))
            put(&info, "__SCHEMA__", firstString(ex, keys: ["schema", "__SCHEMA__"]))
            put(&info, "__CLICK_TYPE__", firstString(ex, keys: ["click_type", "__CLICK_TYPE__"]))
            put(&info, "__INTERACTIVE_MODE__", firstString(ex, keys: ["interactive_mode", "__INTERACTIVE_MODE__"]) ?? "点击热区")
            put(&info, "__JUMP_LINK__", firstString(ex, keys: ["jump_link", "__JUMP_LINK__"]))
            put(&info, "__SLD__", firstString(ex, keys: ["sld_type", "sld", "__SLD__"]))
            put(&info, "__DELIVERY_TYPE__", firstString(ex, keys: ["delivery_type", "__DELIVERY_TYPE__"]))
            put(&info, "__PLAY_DURATION__", firstString(ex, keys: ["play_duration", "__PLAY_DURATION__"]))
            put(&info, "__ADDPROFIT__", firstString(ex, ad, keys: ["increasePrice", "add_profit", "__ADDPROFIT__"]))
            put(&info, "__MATERIAL_TYPE__", firstString(ex, ad, keys: ["materialType", "material_type", "__MATERIAL_TYPE__"]))
        case .pm:
            put(&info, "__EXPOSURE_TYPE__", firstString(ex, keys: ["exposure_type", "__EXPOSURE_TYPE__"]))
            put(&info, "__ADDPROFIT__", firstString(ex, ad, keys: ["increasePrice", "add_profit", "__ADDPROFIT__"]))
            put(&info, "__MATERIAL_TYPE__", firstString(ex, ad, keys: ["materialType", "material_type", "__MATERIAL_TYPE__"]))
            put(&info, "__WELFARETYPE__", firstString(ex, ad, keys: ["welfareType", "welfare_type", "__WELFARETYPE__"]))
            put(&info, "__EXPOSURE_LOAD__", firstString(ex, ad, keys: ["exposureLoad", "exposure_load", "__EXPOSURE_LOAD__"]))
            put(&info, "__BOOT_NOTIFICATION__", firstString(ex, keys: ["boot_notification", "__BOOT_NOTIFICATION__"]))
            if intValue(ad, key: "reachTimeLimit") != 0 {
                put(&info, "__AD_TIMEOUT__", "达到整体时限")
            }
        case .rem:
            break
        }

        // extra 里直接带 `__XXX__` 的键优先生效
        for (key, value) in ex {
            guard let key = key as? String, key.hasPrefix("__"), key.hasSuffix("__") else { continue }
            put(&info, key, stringValue(value))
        }
        return info
    }

    private static func replaceMacros(in url: String, with replaceInfo: [String: String]) -> String {
        var result = url
        for (macro, value) in replaceInfo {
            let encoded: String
            if macro == "__MATERIALURL__" {
                encoded = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value
            } else {
                encoded = value.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed.subtracting(CharacterSet(charactersIn: ":/?#[]@!$&'()*+,;="))) ?? value
            }
            result = result.replacingOccurrences(of: macro, with: encoded)
        }
        return result
    }

    /// REM：query 7 参字母升序拼接 + rewardSignKey，MD5 小写 hex 替换 `__REM_SIGN__`
    private static func replaceRemSignIfNeeded(in url: String) -> String {
        guard url.contains("__REM_SIGN__") else { return url }
        let key = LampsSDK.effectiveRewardSignKey
        guard !key.isEmpty else { return url }
        let sign = remSign(for: url, rewardSignKey: key) ?? ""
        return url.replacingOccurrences(of: "__REM_SIGN__", with: sign)
    }

    private static func remSign(for urlString: String, rewardSignKey: String) -> String? {
        let signKeys = ["adpid", "app_version", "cid", "forward_source", "price", "puid", "request_id"]
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

    private static func put(_ info: inout [String: String], _ key: String, _ value: String?) {
        guard let value = value, !value.isEmpty else { return }
        info[key] = value
    }

    private static func firstString(_ dicts: [AnyHashable: Any]..., keys: [String]) -> String? {
        for key in keys {
            for dict in dicts {
                if let value = stringValue(dict[key]), !value.isEmpty {
                    return value
                }
            }
        }
        return nil
    }

    private static func stringValue(_ value: Any?) -> String? {
        if let text = value as? String { return text }
        if let number = value as? NSNumber { return number.stringValue }
        return nil
    }

    private static func intValue(_ dict: [AnyHashable: Any], key: String) -> Int {
        if let number = dict[key] as? NSNumber { return number.intValue }
        if let text = dict[key] as? String { return Int(text) ?? 0 }
        return 0
    }
}
