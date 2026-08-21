#if LampsADAPTER_SEPARATE_MODULE
import LampsSDK
#endif

import Foundation
import BUAdSDK
#if canImport(BUAdTestMeasurement)
import BUAdTestMeasurement
#endif

enum LampsCSJSDKInitializer: LampsSDKInitializing {
    static func initialize(config: LampsSDKConfig, completion: @escaping (Bool, Error?) -> Void) {
        let appId = config.csjAppId.trimmingCharacters(in: .whitespacesAndNewlines)
        // 宿主（如 HCAD）已初始化时传空 AppId，跳过二次 init。
        guard !appId.isEmpty else {
            LampsSDKLog.debug("csj init skipped: empty appId")
            completion(true, nil)
            return
        }

        // 穿山甲测试工具要求：必须在 BUAdSDKManager.start 之前打开 debugMode，否则「基本信息」无数据。
        #if canImport(BUAdTestMeasurement)
        BUAdTestMeasurementConfiguration().debugMode = true
        #endif

        let shakeValue = config.shakeAdsEnabled ? 1 : 0
        let userExtData = "[{\"name\":\"is_shake_ads\", \"value\":\"\(shakeValue)\"}]"

        let configuration = BUAdSDKConfiguration.configuration()
        configuration.appID = appId
        configuration.userExtData = userExtData
        if config.debugLogEnabled {
            configuration.debugLog = NSNumber(value: 1)
        }
        #if canImport(BUAdTestMeasurement)
        // 与 HCAD 对齐：测试工具场景打开 SDKDEBUG
        configuration.sdkdebug = true
        #endif
        BUAdSDKManager.setUserExtData(userExtData)
        BUAdSDKManager.start(asyncCompletionHandler: { success, error in
            DispatchQueue.main.async { completion(success, error) }
        })
    }
}

@objc(LampsCSJSDKInitializerRegistrar)
public final class LampsCSJSDKInitializerRegistrar: NSObject {
    private static var didRegister = false

    @objc public static func registerIfNeeded() {
        guard !didRegister else { return }
        didRegister = true
        LampsSDKAdapterCenter.registerInitializer(channel: .csj, initializer: LampsCSJSDKInitializer.self)
    }
}
