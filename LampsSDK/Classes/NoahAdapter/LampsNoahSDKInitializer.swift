#if canImport(NoahSDK)
import Foundation
import NoahSDK

enum LampsNoahSDKInitializer: LampsSDKInitializing {
    static func initialize(config: LampsSDKConfig, completion: @escaping (Bool, Error?) -> Void) {
        let appKey = config.noahAppKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !appKey.isEmpty else {
            completion(true, nil)
            return
        }
        let sdkConfig = NoahSdkConfig()
        sdkConfig.setAppKeyValue(appKey)
        sdkConfig.forbidHcGetLocationInfo = true
        NoahSdk.initWithConfig(sdkConfig, globalConfig: nil)
        completion(true, nil)
    }
}

@objc(LampsNoahSDKInitializerLoader)
private final class LampsNoahSDKInitializerLoader: NSObject {
    @objc public override class func load() {
        LampsSDKAdapterCenter.registerInitializer(channel: .noah, initializer: LampsNoahSDKInitializer.self)
    }
}
#endif
