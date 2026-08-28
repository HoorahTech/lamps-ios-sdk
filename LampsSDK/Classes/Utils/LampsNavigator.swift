import UIKit

enum LampsNavigator {
    /// 有导航栈则 `push`，否则全屏 `present`。游戏中心与游戏页共用。
    static func pushOrPresent(_ page: UIViewController, from host: UIViewController) {
        if let nav = host as? UINavigationController {
            preferHostNavigationBarHidden(on: page)
            nav.pushViewController(page, animated: true)
        } else if let nav = host.navigationController {
            preferHostNavigationBarHidden(on: page)
            nav.pushViewController(page, animated: true)
        } else {
            page.modalPresentationStyle = .fullScreen
            host.present(page, animated: true)
        }
    }

    /// 包一层普通 `UINavigationController` 后全屏 present，不进入宿主导航栈。
    static func presentInNavigationController(_ page: UIViewController, from host: UIViewController) {
        let navigationController = UINavigationController(rootViewController: page)
        navigationController.isNavigationBarHidden = true
        navigationController.modalPresentationStyle = .fullScreen
        host.present(navigationController, animated: true)
    }

    /// 当前最上层页面，供未传入 `viewController` 时兜底。
    static func currentHostViewController() -> UIViewController? {
        guard let root = rootViewController() else { return nil }
        return topViewController(from: root)
    }

    private static func rootViewController() -> UIViewController? {
        if let root = UIApplication.shared.delegate?.window??.rootViewController {
            return root
        }
        return keyWindow()?.rootViewController
    }

    private static func keyWindow() -> UIWindow? {
        if #available(iOS 13.0, *) {
            let windows = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
            return windows.first(where: { $0.isKeyWindow }) ?? windows.first
        }
        return UIApplication.shared.keyWindow
    }

    private static func topViewController(from root: UIViewController) -> UIViewController {
        if let presented = root.presentedViewController {
            return topViewController(from: presented)
        }
        if let tab = root as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(from: selected)
        }
        if let nav = root as? UINavigationController, let visible = nav.visibleViewController {
            return topViewController(from: visible)
        }
        return root
    }

    /// 虎扑 `HPNavigationController` + FD 会在 `viewWillAppear` 之后按该属性重设系统栏。
    /// 宿主没有 FD 时 `responds(to:)` 为 false，调用被跳过。
    private static func preferHostNavigationBarHidden(on page: UIViewController) {
        let selector = NSSelectorFromString("setFd_prefersNavigationBarHidden:")
        guard page.responds(to: selector) else { return }
        page.setValue(true, forKey: "fd_prefersNavigationBarHidden")
    }
}
