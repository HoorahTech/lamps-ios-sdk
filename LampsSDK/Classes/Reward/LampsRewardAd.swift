import UIKit

public typealias LampsRewardCompletion = (Bool, Error?) -> Void

/// 激励视频入口。第一阶段仅保留 API，三方广告 SDK 在后续阶段按需接入。
@objcMembers
public final class LampsRewardAd: NSObject {
    @objc(showFromViewController:completion:)
    public static func show(from viewController: UIViewController, completion: LampsRewardCompletion?) {
        _ = viewController
        guard LampsSDK.isStarted else {
            LampsSDKLog.debug("reward skipped: SDK not started")
            completion?(false, LampsSDKError.notStarted("请先调用 LampsSDK.start(config:completion:)").nsError)
            return
        }
        LampsSDKLog.debug("reward placeholder called, will be implemented later")
        completion?(false, LampsSDKError.notImplemented("激励视频将在后续阶段接入").nsError)
    }
}
