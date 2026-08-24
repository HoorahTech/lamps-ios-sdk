#if LampsADAPTER_SEPARATE_MODULE
@_spi(LampsAdapter) import LampsSDK
#endif

import Foundation
import NoahSDK

enum LampsNoahSDKInitializer: LampsSDKInitializing {
    static func initialize(config: LampsSDKConfig, channelAppId: String, completion: @escaping (Bool, Error?) -> Void) {
        let appKey = channelAppId.trimmingCharacters(in: .whitespacesAndNewlines)
        // channelList 未下发或 channelAppId 为空时跳过，避免二次 init。
        guard !appKey.isEmpty else {
            LampsSDKLog.debug("noah init skipped: empty appKey")
            completion(true, nil)
            return
        }
        let sdkConfig = NoahSdkConfig()
        sdkConfig.setAppKeyValue(appKey)
        sdkConfig.forbidHcGetLocationInfo = !config.allowLocation
        NoahSdk.initWith(sdkConfig, globalConfig: nil)
        completion(true, nil)
    }
}

@objc(LampsNoahSDKInitializerRegistrar)
public final class LampsNoahSDKInitializerRegistrar: NSObject {
    private static var didRegister = false

    @objc public static func registerIfNeeded() {
        guard !didRegister else { return }
        didRegister = true
        LampsSDKAdapterCenter.registerInitializer(channel: .noah, initializer: LampsNoahSDKInitializer.self)
    }
}
