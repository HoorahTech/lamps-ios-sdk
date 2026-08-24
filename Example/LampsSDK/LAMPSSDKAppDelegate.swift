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
        config.appId = "lamps-sdk-demo"
        config.debugLogEnabled = true
        config.csjAppId = "5015515"
        config.gdtAppId = "1206233429"
        config.noahAppKey = "11780"
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
