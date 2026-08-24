import Foundation

/// 广告 SDK 初始化协议（与激励 Adapter 解耦）。
/// 仅 Adapter 跨模块 SPI，宿主普通 import 不可见。
@_spi(LampsAdapter)
public protocol LampsSDKInitializing {
    static func initialize(config: LampsSDKConfig, channelAppId: String, completion: @escaping (Bool, Error?) -> Void)
}
