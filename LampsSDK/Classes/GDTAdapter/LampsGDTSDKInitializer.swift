#if canImport(GDTMobSDK)
import Foundation
import GDTMobSDK

enum LampsGDTSDKInitializer: LampsSDKInitializing {
    static func initialize(config: LampsSDKConfig, completion: @escaping (Bool, Error?) -> Void) {
        let appId = config.gdtAppId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !appId.isEmpty else {
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

@objc(LampsGDTSDKInitializerLoader)
private final class LampsGDTSDKInitializerLoader: NSObject {
    @objc public override class func load() {
        LampsSDKAdapterCenter.registerInitializer(channel: .gdt, initializer: LampsGDTSDKInitializer.self)
    }
}
#endif
