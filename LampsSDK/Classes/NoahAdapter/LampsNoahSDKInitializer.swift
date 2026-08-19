#if LampsADAPTER_SEPARATE_MODULE
import LampsSDK
#endif

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
        NoahSdk.initWith(sdkConfig, globalConfig: nil)
        completion(true, nil)
    }
}

#endif

@objc(LampsNoahSDKInitializerRegistrar)
public final class LampsNoahSDKInitializerRegistrar: NSObject {
    private static var didRegister = false

    @objc public static func registerIfNeeded() {
        guard !didRegister else { return }
        didRegister = true
        #if canImport(NoahSDK)
        LampsSDKAdapterCenter.registerInitializer(channel: .noah, initializer: LampsNoahSDKInitializer.self)
        #endif
    }
}
