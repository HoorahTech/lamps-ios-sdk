#if LampsADAPTER_SEPARATE_MODULE
@_spi(LampsAdapter) import LampsSDK
#endif

import Foundation
import GDTMobSDK

enum LampsGDTSDKInitializer: LampsSDKInitializing {
    static func initialize(config: LampsSDKConfig, channelAppId: String, completion: @escaping (Bool, Error?) -> Void) {
        let appId = channelAppId.trimmingCharacters(in: .whitespacesAndNewlines)
        // channelList 未下发或 channelAppId 为空时跳过，避免二次 init。
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
final class LampsGDTSDKInitializerRegistrar: NSObject {
    private static var didRegister = false

    @objc static func registerIfNeeded() {
        guard !didRegister else { return }
        didRegister = true
        LampsSDKAdapterCenter.registerInitializer(channel: .gdt, initializer: LampsGDTSDKInitializer.self)
    }
}
