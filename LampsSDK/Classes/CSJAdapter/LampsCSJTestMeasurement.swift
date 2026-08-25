import Foundation

/// 运行时打开穿山甲测试工具 debugMode。未链 BUAdTestMeasurement 时为空操作。
enum LampsCSJTestMeasurement {
    static var isAvailable: Bool {
        NSClassFromString("BUAdTestMeasurementConfiguration") != nil
    }

    static func enableDebugModeIfAvailable() {
        guard let cls = NSClassFromString("BUAdTestMeasurementConfiguration") else { return }
        let type = cls as AnyObject
        let configurationSel = NSSelectorFromString("configuration")
        var config: AnyObject?
        if type.responds(to: configurationSel) {
            config = type.perform(configurationSel)?.takeUnretainedValue()
        }
        if config == nil, let objectType = cls as? NSObject.Type {
            config = objectType.init()
        }
        let setDebugSel = NSSelectorFromString("setDebugMode:")
        guard let config, config.responds(to: setDebugSel) else { return }
        typealias Setter = @convention(c) (AnyObject, Selector, Bool) -> Void
        unsafeBitCast(config.method(for: setDebugSel), to: Setter.self)(config, setDebugSel, true)
    }
}
