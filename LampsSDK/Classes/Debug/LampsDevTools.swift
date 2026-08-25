import UIKit
#if LampsADAPTER_SEPARATE_MODULE
@_spi(LampsDevTools) import LampsSDK
#endif
#if canImport(BUAdTestMeasurement)
import BUAdTestMeasurement
#endif

/// Lamps 调试面板。仅调试包接入 `LampsDevTools` 后使用，不要打进正式包。
@objc(LampsDevTools)
@objcMembers
public final class LampsDevTools: NSObject {
    /// 以全屏模态弹出调试页。
    @objc(presentFromViewController:)
    public static func present(from viewController: UIViewController) {
        enableThirdPartyDebugModesIfNeeded()
        let root = LampsDevToolsViewController()
        let nav = UINavigationController(rootViewController: root)
        nav.modalPresentationStyle = .fullScreen
        viewController.present(nav, animated: true)
    }

    /// 在当前导航栈压入调试页。调用方需已处于 `UINavigationController` 中。
    @objc(pushFromViewController:)
    public static func push(from viewController: UIViewController) {
        enableThirdPartyDebugModesIfNeeded()
        viewController.navigationController?.pushViewController(
            LampsDevToolsViewController(),
            animated: true
        )
    }

    private static func enableThirdPartyDebugModesIfNeeded() {
        #if canImport(BUAdTestMeasurement)
        BUAdTestMeasurementConfiguration().debugMode = true
        #endif
    }
}
