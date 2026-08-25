import UIKit
import LampsSDK

@main
@objc(LAMPSSDKAppDelegate)
final class LAMPSSDKAppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        let config = LampsSDKConfig()
        config.appId = "10002"
        config.debugLogEnabled = true
        Lamps.start(config: config) { success, error in
            if !success {
                NSLog("[LampsSDK Demo] start failed: %@", error?.localizedDescription ?? "")
                return
            }
            NSLog("[LampsSDK Demo] start success")
        }

        let window = UIWindow(frame: UIScreen.main.bounds)
        let root = LAMPSSDKViewController()
        window.rootViewController = LAMPSSDKNavigationController(rootViewController: root)
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
}

/// Demo 导航容器：隐藏导航栏或自定义返回按钮时，仍启用系统侧滑返回。
private final class LAMPSSDKNavigationController: UINavigationController, UIGestureRecognizerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.isEnabled = true
        interactivePopGestureRecognizer?.delegate = self
    }

    override var childForStatusBarStyle: UIViewController? {
        topViewController
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        viewControllers.count > 1
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        gestureRecognizer == interactivePopGestureRecognizer
    }
}
