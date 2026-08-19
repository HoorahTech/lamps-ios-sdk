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
            configuration.debugLog = NSNumber(value: 1)
        }
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
