import UIKit
#if LampsADAPTER_SEPARATE_MODULE
@_spi(LampsDevTools) import LampsSDK
#endif
#if canImport(BUAdTestMeasurement)
import BUAdTestMeasurement
#endif

/// Lamps SDK 调试工具入口（需集成 `LampsDevTools`，或二进制下的 `LampsSDK/DevTools`）。
@objc(LampsDevTools)
@objcMembers
public final class LampsDevTools: NSObject {
    /// 弹出调试工具首页（导航栈）。
    @objc(presentFromViewController:)
    public static func present(from viewController: UIViewController) {
        enableThirdPartyDebugModesIfNeeded()
        let root = LampsDevToolsViewController()
        let nav = UINavigationController(rootViewController: root)
        nav.modalPresentationStyle = .fullScreen
        viewController.present(nav, animated: true)
    }

    private static func enableThirdPartyDebugModesIfNeeded() {
        #if canImport(BUAdTestMeasurement)
        BUAdTestMeasurementConfiguration().debugMode = true
        #endif
    }
}
