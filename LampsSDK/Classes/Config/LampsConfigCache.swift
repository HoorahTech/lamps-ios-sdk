import Foundation

/// `/v1/lamps/config` 的 `data` 磁盘缓存。按 appId + 环境隔离。
enum LampsConfigCache {
    private static let directoryName = "com.hupu.lamps.sdk.config"

    static func load(appId: String, environment: LampsSDKEnvironment) -> LampsRemoteConfig? {
        let trimmed = appId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let url = fileURL(appId: trimmed, environment: environment)
        guard let data = try? Data(contentsOf: url), !data.isEmpty else { return nil }
        guard let json = try? JSONSerialization.jsonObject(with: data),
              let dict = json as? [String: Any],
              let remote = LampsRemoteConfig.parse(from: dict) else {
            LampsSDKLog.debug("config cache parse failed path=\(url.lastPathComponent)")
            return nil
        }
        LampsSDKLog.debug(
            "config cache hit slots=\(remote.rewardAdSlots.count) tokenLen=\(remote.token.count)"
        )
        return remote
    }

    static func save(
        dataDictionary: [String: Any],
        appId: String,
        environment: LampsSDKEnvironment
    ) {
        let trimmed = appId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard JSONSerialization.isValidJSONObject(dataDictionary),
              let data = try? JSONSerialization.data(withJSONObject: dataDictionary, options: []) else {
            LampsSDKLog.debug("config cache save skipped: invalid json")
            return
        }
        let url = fileURL(appId: trimmed, environment: environment)
        do {
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try data.write(to: url, options: .atomic)
            LampsSDKLog.debug("config cache saved path=\(url.lastPathComponent) bytes=\(data.count)")
        } catch {
            LampsSDKLog.debug("config cache save failed: \(error.localizedDescription)")
        }
    }

    private static func fileURL(appId: String, environment: LampsSDKEnvironment) -> URL {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        let safeAppId = appId
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ":", with: "_")
        let envName = environment == .dev ? "dev" : "prd"
        return caches
            .appendingPathComponent(directoryName, isDirectory: true)
            .appendingPathComponent("config_\(safeAppId)_\(envName).json", isDirectory: false)
    }

    @discardableResult
    static func clear(appId: String, environment: LampsSDKEnvironment) -> Bool {
        let trimmed = appId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        let url = fileURL(appId: trimmed, environment: environment)
        guard FileManager.default.fileExists(atPath: url.path) else { return true }
        do {
            try FileManager.default.removeItem(at: url)
            LampsSDKLog.debug("config cache cleared path=\(url.lastPathComponent)")
            return true
        } catch {
            LampsSDKLog.debug("config cache clear failed: \(error.localizedDescription)")
            return false
        }
    }
}
