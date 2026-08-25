import Foundation

/// SDK 内部调试日志。仅 Adapter 跨模块可见。
@_spi(LampsAdapter)
public enum LampsSDKLog {
    public static func debug(_ message: String) {
        guard Lamps.config?.debugLogEnabled == true else { return }
        NSLog("[LampsSDK] %@", message)
    }
}
