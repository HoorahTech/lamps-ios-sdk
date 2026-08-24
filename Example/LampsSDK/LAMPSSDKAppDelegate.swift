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
        return true
    }
}
