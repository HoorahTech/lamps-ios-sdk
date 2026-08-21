import Foundation

/// SDK 内部调试日志。独立 Adapter 模块出包时需 `public`，否则跨模块不可见。
public enum LampsSDKLog {
    public static func debug(_ message: String) {
        guard Lamps.config?.debugLogEnabled == true else { return }
        NSLog("[LampsSDK] %@", message)
    }
}
