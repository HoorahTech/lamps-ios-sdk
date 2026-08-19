import Foundation

enum LampsSDKLog {
    static func debug(_ message: String) {
        guard Lamps.config?.debugLogEnabled == true else { return }
        NSLog("[LampsSDK] %@", message)
    }
}
