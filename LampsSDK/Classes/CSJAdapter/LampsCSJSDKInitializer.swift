#if LampsADAPTER_SEPARATE_MODULE
@_spi(LampsAdapter) import LampsSDK
#endif

import Foundation
import BUAdSDK

enum LampsCSJSDKInitializer: LampsSDKInitializing {
    static func initialize(config: LampsSDKConfig, channelAppId: String, completion: @escaping (Bool, Error?) -> Void) {
        let appId = channelAppId.trimmingCharacters(in: .whitespacesAndNewlines)
        // channelList 未下发或 channelAppId 为空时跳过，避免二次 init。
        guard !appId.isEmpty else {
            LampsSDKLog.debug("csj init skipped: empty appId")
            completion(true, nil)
            return
        }

        // 穿山甲测试工具要求：必须在 BUAdSDKManager.start 之前打开 debugMode。
        // 用运行时检测，避免正式包未链 BUAdTestMeasurement 时链接失败。
        LampsCSJTestMeasurement.enableDebugModeIfAvailable()

        let shakeValue = config.shakeAdsEnabled ? 1 : 0
        let userExtData = "[{\"name\":\"is_shake_ads\", \"value\":\"\(shakeValue)\"}]"

        let configuration = BUAdSDKConfiguration.configuration()
        configuration.appID = appId
        configuration.userExtData = userExtData
        if config.debugLogEnabled {
            configuration.debugLog = NSNumber(value: 1)
        }
        if LampsCSJTestMeasurement.isAvailable {
            // 与 HCAD 对齐：测试工具场景打开 SDKDEBUG
            configuration.sdkdebug = true
        }
        BUAdSDKManager.setUserExtData(userExtData)
        BUAdSDKManager.start(asyncCompletionHandler: { success, error in
            DispatchQueue.main.async { completion(success, error) }
        })
    }
}

@objc(LampsCSJSDKInitializerRegistrar)
final class LampsCSJSDKInitializerRegistrar: NSObject {
    private static var didRegister = false

    @objc static func registerIfNeeded() {
        guard !didRegister else { return }
        didRegister = true
        LampsSDKAdapterCenter.registerInitializer(channel: .csj, initializer: LampsCSJSDKInitializer.self)
    }
}
