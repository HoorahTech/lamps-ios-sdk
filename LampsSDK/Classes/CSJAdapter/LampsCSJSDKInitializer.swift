#if LampsADAPTER_SEPARATE_MODULE
import LampsSDK
#endif

#if canImport(BUAdSDK)
import Foundation
import BUAdSDK
#if canImport(BUAdTestMeasurement)
import BUAdTestMeasurement
#endif

enum LampsCSJSDKInitializer: LampsSDKInitializing {
    static func initialize(config: LampsSDKConfig, completion: @escaping (Bool, Error?) -> Void) {
        let appId = config.csjAppId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !appId.isEmpty else {
            completion(true, nil)
            return
        }

        // 穿山甲测试工具要求：必须在 BUAdSDKManager.start 之前打开 debugMode，否则「基本信息」无数据。
        #if canImport(BUAdTestMeasurement)
        BUAdTestMeasurementConfiguration().debugMode = true
        #endif

        let configuration = BUAdSDKConfiguration.configuration()
        configuration.appID = appId
        if config.debugLogEnabled {
            configuration.debugLog = NSNumber(value: 1)
        }
        #if canImport(BUAdTestMeasurement)
        // 与 HCAD 对齐：测试工具场景打开 SDKDEBUG
        configuration.sdkdebug = true
        #endif
        BUAdSDKManager.start(asyncCompletionHandler: { success, error in
            DispatchQueue.main.async { completion(success, error) }
        })
    }
}

#endif

@objc(LampsCSJSDKInitializerRegistrar)
public final class LampsCSJSDKInitializerRegistrar: NSObject {
    private static var didRegister = false

    @objc public static func registerIfNeeded() {
        guard !didRegister else { return }
        didRegister = true
        #if canImport(BUAdSDK)
        LampsSDKAdapterCenter.registerInitializer(channel: .csj, initializer: LampsCSJSDKInitializer.self)
        #endif
    }
}
