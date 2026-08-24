import Foundation

@_spi(LampsAdapter)
public typealias LampsRewardAdapterMaker = (LampsRewardAdModel) -> LampsRewardAdapting

/// 广告 SDK Adapter / Initializer 注册中心（不放在 Reward 目录）。
/// 仅 Adapter 跨模块 SPI，宿主普通 import 不可见。
@_spi(LampsAdapter)
public enum LampsSDKAdapterCenter {
    private static var makers: [LampsRewardChannel: LampsRewardAdapterMaker] = [:]
    private static var initializers: [LampsRewardChannel: LampsSDKInitializing.Type] = [:]
    private static let lock = NSLock()

    public static func register(channel: LampsRewardChannel, maker: @escaping LampsRewardAdapterMaker) {
        lock.lock()
        makers[channel] = maker
        lock.unlock()
        LampsSDKLog.debug("adapter registered: \(channel.name)")
    }

    public static func registerInitializer(channel: LampsRewardChannel, initializer: LampsSDKInitializing.Type) {
        lock.lock()
        initializers[channel] = initializer
        lock.unlock()
        LampsSDKLog.debug("sdk initializer registered: \(channel.name)")
    }

    public static func isAvailable(_ channel: LampsRewardChannel) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return makers[channel] != nil
    }

    static func makeAdapter(model: LampsRewardAdModel) -> LampsRewardAdapting? {
        lock.lock()
        let maker = makers[model.channel]
        lock.unlock()
        return maker?(model)
    }

    static func initializeSDKs(config: LampsSDKConfig, completion: @escaping () -> Void) {
        lock.lock()
        let pairs = initializers.map { ($0.key, $0.value) }
        lock.unlock()
        guard !pairs.isEmpty else {
            completion()
            return
        }
        let group = DispatchGroup()
        for (channel, initializer) in pairs {
            group.enter()
            initializer.initialize(config: config) { success, error in
                if success {
                    LampsSDKLog.debug("sdk init ok: \(channel.name)")
                } else {
                    LampsSDKLog.debug(
                        "sdk init fail: \(channel.name) \(error?.localizedDescription ?? "")"
                    )
                }
                group.leave()
            }
        }
        group.notify(queue: .main, execute: completion)
    }
}
