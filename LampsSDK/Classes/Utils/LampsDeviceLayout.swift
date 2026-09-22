import UIKit

/// 屏幕与安全区布局信息。
enum LampsDeviceLayout {
    /// 状态栏高度，单位 pt。主线程优先读前台 keyWindow 的顶部安全区。
    static var statusBarHeight: CGFloat {
        if Thread.isMainThread, let height = currentStatusBarHeight() {
            statusBarHeightCache = height
            return height
        }
        return statusBarHeightCache
    }

    /// 有 keyWindow 用它的顶部安全区。没有时用前台 Scene 里已经布局出安全区的窗口，再退到状态栏高度。都读不到则保留缓存。
    private static func currentStatusBarHeight() -> CGFloat? {
        if #available(iOS 13.0, *) {
            let scenes = foregroundScenes()
            let windows = scenes.flatMap { $0.windows }
            if let window = windows.first(where: { $0.isKeyWindow }), let height = topInset(of: window) {
                return height
            }
            if let window = windows.first(where: { $0.safeAreaInsets.top > 0 }) {
                return window.safeAreaInsets.top
            }
            for scene in scenes {
                let height = scene.statusBarManager?.statusBarFrame.height ?? 0
                if height > 0 {
                    return height
                }
            }
            return nil
        }
        let height = UIApplication.shared.statusBarFrame.height
        return height > 0 ? height : nil
    }

    /// 横屏顶部安全区为 0 是有效值。竖屏仍为 0 说明窗口还没布局完。
    private static func topInset(of window: UIWindow) -> CGFloat? {
        let top = window.safeAreaInsets.top
        if top > 0 || window.bounds.width > window.bounds.height {
            return top
        }
        return nil
    }

    @available(iOS 13.0, *)
    private static func foregroundScenes() -> [UIWindowScene] {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let active = scenes.filter { $0.activationState == .foregroundActive }
        if !active.isEmpty {
            return active
        }
        return scenes.filter { $0.activationState == .foregroundInactive }
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

    /// 窗口还没布局出来时的竖屏顶部安全区。按屏幕物理像素区分机型，读到真实值后会被覆盖。
    private static let statusBarHeightCacheDefault: CGFloat = {
        let pixels = max(UIScreen.main.nativeBounds.width, UIScreen.main.nativeBounds.height)
        switch Int(pixels) {
        case 2868, 2622: // 16 Pro / 16 Pro Max、17 / 17 Pro / 17 Pro Max
            return 62
        case 2736: // iPhone Air
            return 68
        case 2796, 2556: // 14 Pro、15 / 15 Pro、15 Plus / 15 Pro Max、16 / 16 Plus
            return 59
        case 2340: // 12 mini、13 mini
            return 50
        case 1792: // XR、11
            return 48
        case 2778, 2532: // 12 / 12 Pro、13 / 13 Pro、14、16e、12 Pro Max、13 Pro Max、14 Plus
            return 47
        case 2688, 2436: // X / XS / 11 Pro、XS Max / 11 Pro Max
            return 44
        default: // 带 Home 键的 iPhone、iPad
            return 20
        }
    }()

    private static var statusBarHeightCache: CGFloat = statusBarHeightCacheDefault
}
