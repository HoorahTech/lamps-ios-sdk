#if LampsADAPTER_SEPARATE_MODULE
import LampsSDK
#endif

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

        // 1 = 关闭个性化；其他 / 未设置 = 打开
        GDTSDKConfig.setPersonalizedState(config.personalizedRecommendEnabled ? 0 : 1)
        GDTSDKConfig.setExtraUserData([
            "shakable": config.shakeAdsEnabled ? "1" : "0"
        ])
        // iOS App Store 渠道；音频由宿主自行管理
        GDTSDKConfig.setChannel(14)
        GDTSDKConfig.enableDefaultAudioSessionSetting(false)

        GDTSDKConfig.start { success, error in
            DispatchQueue.main.async { completion(success, error) }
        }
    }
}

@objc(LampsGDTSDKInitializerRegistrar)
public final class LampsGDTSDKInitializerRegistrar: NSObject {
    private static var didRegister = false

    @objc public static func registerIfNeeded() {
        guard !didRegister else { return }
        didRegister = true
        LampsSDKAdapterCenter.registerInitializer(channel: .gdt, initializer: LampsGDTSDKInitializer.self)
    }
}
