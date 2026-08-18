import Foundation

/// 广告 SDK 初始化协议（与激励 Adapter 解耦）。
protocol LampsSDKInitializing: AnyObject {
    static func initialize(config: LampsSDKConfig, completion: @escaping (Bool, Error?) -> Void)
}
