import Foundation

/// SDK 自身 HTTP 请求的公共头。
enum LampsRequestHeader {
    static let cid = "L-CID"
    static let uid = "L-UID"

    /// 只有这些 host 才写入 `L-UID`。`L-CID` 不受此限制。比较时忽略大小写。
    private static let uidHosts: Set<String> = [
        "www.lampsgame.com",
        "lamps-api.hoorahgo.com"
    ]

    /// 所有 SDK 请求都写入 `L-CID`。已传入用户 ID 且 host 命中时再写入 `L-UID`。
    static func apply(_ request: inout URLRequest) {
        request.setValue(Lamps.clientId, forHTTPHeaderField: cid)
        guard let host = request.url?.host?.lowercased(), uidHosts.contains(host) else {
            return
        }
        let userId = Lamps.userId
        if userId.isEmpty {
            request.setValue(nil, forHTTPHeaderField: uid)
        } else {
            request.setValue(userId, forHTTPHeaderField: uid)
        }
    }
}
