import Foundation

enum LampsJSONValue {
    /// String / NSNumber → 字符串；其它返回空串。
    static func stringValue(_ value: Any?, trim: Bool = false) -> String {
        if let text = value as? String {
            return trim ? text.trimmingCharacters(in: .whitespacesAndNewlines) : text
        }
        if let number = value as? NSNumber {
            return number.stringValue
        }
        return ""
    }

    /// String / NSNumber → Int；解析失败返回 `defaultValue`。
    static func intValue(_ value: Any?, default defaultValue: Int = 0) -> Int {
        if let number = value as? NSNumber {
            return number.intValue
        }
        if let text = value as? String {
            return Int(text) ?? defaultValue
        }
        return defaultValue
    }

    /// Bool / NSNumber / `"true"` `"false"` `"1"` `"0"` → Bool；缺失或无法解析返回 `defaultValue`。
    static func boolValue(_ value: Any?, default defaultValue: Bool = false) -> Bool {
        if value == nil || value is NSNull {
            return defaultValue
        }
        if let number = value as? NSNumber {
            return number.boolValue
        }
        if let text = value as? String {
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            if trimmed == "true" || trimmed == "1" || trimmed == "yes" {
                return true
            }
            if trimmed == "false" || trimmed == "0" || trimmed == "no" {
                return false
            }
        }
        return defaultValue
    }
}
