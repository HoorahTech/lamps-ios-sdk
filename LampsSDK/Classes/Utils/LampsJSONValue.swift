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
}
