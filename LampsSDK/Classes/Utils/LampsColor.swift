import UIKit

enum LampsColor {
    /// 解析 `#RGB` / `#RRGGBB` / `#AARRGGBB`（可省略 `#`）。
    static func color(fromHex string: String) -> UIColor? {
        var hex = string.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hex.hasPrefix("#") {
            hex.removeFirst()
        }
        if hex.hasPrefix("0X") {
            hex = String(hex.dropFirst(2))
        }
        if hex.count == 3 {
            hex = hex.map { "\($0)\($0)" }.joined()
        }
        guard hex.count == 6 || hex.count == 8 else { return nil }
        var value: UInt64 = 0
        guard Scanner(string: hex).scanHexInt64(&value) else { return nil }

        let red, green, blue, alpha: CGFloat
        if hex.count == 8 {
            alpha = CGFloat((value & 0xFF000000) >> 24) / 255
            red = CGFloat((value & 0x00FF0000) >> 16) / 255
            green = CGFloat((value & 0x0000FF00) >> 8) / 255
            blue = CGFloat(value & 0x000000FF) / 255
        } else {
            red = CGFloat((value & 0xFF0000) >> 16) / 255
            green = CGFloat((value & 0x00FF00) >> 8) / 255
            blue = CGFloat(value & 0x0000FF) / 255
            alpha = 1
        }
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
