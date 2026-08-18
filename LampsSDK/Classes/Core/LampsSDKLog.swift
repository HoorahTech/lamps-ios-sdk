import Foundation

enum LampsSDKLog {
    static func debug(_ message: String) {
        guard LampsSDK.config?.debugLogEnabled == true else { return }
        NSLog("[LampsSDK] %@", message)
    }
}
