import UIKit

enum LampsNavigator {
    /// 有导航栈则 `push`，否则全屏 `present`。游戏中心与游戏页共用。
    static func pushOrPresent(_ page: UIViewController, from host: UIViewController) {
        if let nav = host as? UINavigationController {
            nav.pushViewController(page, animated: true)
        } else if let nav = host.navigationController {
            nav.pushViewController(page, animated: true)
        } else {
            page.modalPresentationStyle = .fullScreen
            host.present(page, animated: true)
        }
    }
}
