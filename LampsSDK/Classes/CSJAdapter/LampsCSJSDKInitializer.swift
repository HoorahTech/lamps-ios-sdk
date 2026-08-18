#if canImport(BUAdSDK)
import Foundation
import BUAdSDK

enum LampsCSJSDKInitializer: LampsSDKInitializing {
    static func initialize(config: LampsSDKConfig, completion: @escaping (Bool, Error?) -> Void) {
        let appId = config.csjAppId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !appId.isEmpty else {
            completion(true, nil)
            return
        }
        let configuration = BUAdSDKConfiguration.configuration()
        configuration.appID = appId
        if config.debugLogEnabled {
            configuration.sdkDEBUG = true
        }
        BUAdSDKManager.start(asyncCompletionHandler: { success, error in
            DispatchQueue.main.async { completion(success, error) }
        })
    }
}

@objc(LampsCSJSDKInitializerLoader)
private final class LampsCSJSDKInitializerLoader: NSObject {
    @objc public override class func load() {
        LampsSDKAdapterCenter.registerInitializer(channel: .csj, initializer: LampsCSJSDKInitializer.self)
    }
}
#endif
