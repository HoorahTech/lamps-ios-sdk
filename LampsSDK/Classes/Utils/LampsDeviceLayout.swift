import UIKit

/// 屏幕与安全区布局信息，取值对齐宿主 `HCDeviceInfo` / `UIDevice.checkIsiPhoneX()`。
enum LampsDeviceLayout {
    /// 状态栏高度，单位 pt。主线程优先读 keyWindow 顶部安全区，否则钳制 `statusBarFrame`。
    static var statusBarHeight: CGFloat {
        if Thread.isMainThread {
            if let window = keyWindow(), window.isKeyWindow {
                statusBarHeightCache = window.safeAreaInsets.top
                return statusBarHeightCache
            }
            var height = UIApplication.shared.statusBarFrame.height
            height = height < 20 ? 20 : height
            height = height < 44 ? (isNotchScreen ? 44 : height) : height
            height = min(height, 54)
            statusBarHeightCache = height
        }
        return statusBarHeightCache
    }

    /// 当前 keyWindow；没有时回落到第一个 window。
    static func keyWindow() -> UIWindow? {
        if #available(iOS 13.0, *) {
            let windows = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
            return windows.first(where: { $0.isKeyWindow }) ?? windows.first
        }
        return UIApplication.shared.keyWindow
    }

    /// 异形屏：底部安全区、状态栏高度或已知刘海屏尺寸。
    static var isNotchScreen: Bool {
        if #available(iOS 11.0, *) {
            if let window = UIApplication.shared.delegate?.window ?? nil, window.safeAreaInsets.bottom > 0 {
                return true
            }
            if UIApplication.shared.statusBarFrame.height >= 43 {
                return true
            }
            if UIDevice.current.userInterfaceIdiom == .phone {
                let maxSide = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
                return [812, 896, 926, 844, 780].contains(maxSide)
            }
        }
        return false
    }

    private static var statusBarHeightCache: CGFloat = 20
}
