#if LampsADAPTER_SEPARATE_MODULE
import LampsSDK
#endif

#if canImport(GDTMobSDK)
import Foundation
import GDTMobSDK

enum LampsGDTSDKInitializer: LampsSDKInitializing {
    static func initialize(config: LampsSDKConfig, completion: @escaping (Bool, Error?) -> Void) {
        let appId = config.gdtAppId.trimmingCharacters(in: .whitespacesAndNewlines)
        // 宿主（如 HCAD）已初始化时传空 AppId，跳过二次 init。
        guard !appId.isEmpty else {
            LampsSDKLog.debug("gdt init skipped: empty appId")
            completion(true, nil)
            return
        }
        let inited = GDTSDKConfig.initWithAppId(appId)
        guard inited else {
            completion(false, LampsSDKError.api("优量汇 initWithAppId 失败").nsError)
            return
        }
        GDTSDKConfig.enableDefaultAudioSessionSetting(false)
        GDTSDKConfig.start { success, error in
            DispatchQueue.main.async { completion(success, error) }
        }
    }
}

#endif

@objc(LampsGDTSDKInitializerRegistrar)
public final class LampsGDTSDKInitializerRegistrar: NSObject {
    private static var didRegister = false

    @objc public static func registerIfNeeded() {
        guard !didRegister else { return }
        didRegister = true
        #if canImport(GDTMobSDK)
        LampsSDKAdapterCenter.registerInitializer(channel: .gdt, initializer: LampsGDTSDKInitializer.self)
        #endif
    }
}
