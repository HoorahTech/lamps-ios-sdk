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
        config.environment = .dev
        config.rewardSignKey = "TESTKEY123"
        LampsSDK.start(config: config) { success, error in
            if !success {
                NSLog("[LampsSDK Demo] start failed: %@", error?.localizedDescription ?? "")
                return
            }
            if let remote = LampsSDK.remoteConfig {
                NSLog(
                    "[LampsSDK Demo] remote config slots=%lu tokenLen=%lu",
                    UInt(remote.rewardAdSlots.count),
                    UInt(remote.token.count)
                )
            } else {
                NSLog("[LampsSDK Demo] remote config unavailable")
            }
        }
        return true
    }
}
