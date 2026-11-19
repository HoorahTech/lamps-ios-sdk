import UIKit

/// 一次游戏中心或单个游戏访问。只在 SDK 内部使用。
/// 页面 `view` 加载时回传打开成功；只有报过成功才在真正关闭时回传退出。
final class LampsBehaviorVisit {
    enum Kind {
        case center
        case game

        var pageType: LampsBehaviorPageType {
            switch self {
            case .center: return .gameCenter
            case .game: return .game
            }
        }

        var typeName: String {
            pageType.name
        }
    }

    let kind: Kind
    let gameId: String?
    /// 宿主在打开时传入的埋点字段。打开成功、打开前失败和退出都并进去，不覆盖 SDK 字段。
    let trackParams: [String: String]
    /// 从游戏中心页 H5 打开的游戏才有。退出时把这一局累加进中心，中心自己的退出再带合并后的列表。
    private weak var parent: LampsBehaviorVisit?

    private(set) var hasExited = false
    /// 页面 `view` 是否已经加载并回传过「打开页面 / 成功」。
    /// 为 true 后不再重复报打开；加载成败不再改这次结果。只有这时关闭页面才回传退出并计时。
    private var reportedSuccess = false
    private var accumulated: TimeInterval = 0
    private var tickingSince: Date?
    private var ads = PlayStats()
    private var mergedOrder: [String] = []
    private var merged: [String: PlayStats] = [:]

    init(
        kind: Kind,
        gameId: String? = nil,
        parent: LampsBehaviorVisit? = nil,
        trackParams: [String: String] = [:]
    ) {
        self.kind = kind
        self.gameId = Self.normalizedGameId(gameId)
        self.parent = parent
        self.trackParams = trackParams
    }

    /// 页面 `view` 第一次加载。同一次访问只回传一次打开成功，与 H5 是否加载完成无关。
    func pageDidOpen() {
        guard !hasExited, !reportedSuccess else { return }
        reportedSuccess = true
        LampsBehaviorTracker.shared.emitOpen(
            kind: kind,
            gameId: gameId,
            success: true,
            code: nil,
            message: nil,
            trackParams: trackParams
        )
        refreshClock()
    }

    /// 页面真正离开。重复调用只回传一次。没报过成功则不回传退出。
    func close() {
        guard !hasExited else { return }
        hasExited = true
        refreshClock()
        guard reportedSuccess else { return }

        let seconds = foregroundSeconds
        if kind == .game {
            var snapshot = ads
            snapshot.gameId = gameId
            snapshot.duration = seconds
            LampsBehaviorTracker.shared.emitExit(
                kind: kind,
                duration: seconds,
                gameList: [snapshot.params],
                trackParams: trackParams
            )
            parent?.merge(snapshot)
            return
        }
        let gameList = mergedOrder.compactMap { merged[$0]?.params }
        LampsBehaviorTracker.shared.emitExit(
            kind: kind,
            duration: seconds,
            gameList: gameList,
            trackParams: trackParams
        )
    }

    func recordRequest() {
        performOnMain { [weak self] in
            guard let self, self.kind == .game, !self.hasExited else { return }
            self.ads.adReq += 1
        }
    }

    func recordShow(price raw: CGFloat) {
        performOnMain { [weak self] in
            guard let self, self.kind == .game, !self.hasExited else { return }
            self.ads.adShow += 1
            guard raw.isFinite else { return }
            let fen = Int(raw.rounded())
            if fen > 0 {
                self.ads.price += fen
            }
        }
    }

    func recordClick() {
        performOnMain { [weak self] in
            guard let self, self.kind == .game, !self.hasExited else { return }
            self.ads.adClk += 1
        }
    }

    func refreshClock() {
        let shouldTick = reportedSuccess
            && !hasExited
            && !LampsBehaviorTracker.shared.isInBackground
        if shouldTick {
            if tickingSince == nil {
                tickingSince = Date()
            }
            return
        }
        guard let start = tickingSince else { return }
        accumulated += Date().timeIntervalSince(start)
        tickingSince = nil
    }

    private var foregroundSeconds: Int {
        var total = accumulated
        if let tickingSince {
            total += Date().timeIntervalSince(tickingSince)
        }
        if total <= 0 { return 0 }
        return Int(total)
    }

    private func performOnMain(_ block: @escaping () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async(execute: block)
        }
    }

    private func merge(_ snapshot: PlayStats) {
        guard kind == .center, !hasExited else { return }
        let key = snapshot.gameId ?? ""
        var stats = merged[key] ?? PlayStats(gameId: snapshot.gameId)
        if merged[key] == nil {
            mergedOrder.append(key)
        }
        stats.duration += snapshot.duration
        stats.adReq += snapshot.adReq
        stats.adShow += snapshot.adShow
        stats.adClk += snapshot.adClk
        stats.price += snapshot.price
        merged[key] = stats
    }

    private static func normalizedGameId(_ gameId: String?) -> String? {
        let trimmed = gameId?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? nil : trimmed
    }
}

/// 从链接（含 `#/play?gameId=`）里取 `gameId`。
enum LampsGameLink {
    static func gameId(from urlString: String) -> String? {
        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        for part in trimmed.split(separator: "?").dropFirst() {
            let section = part.split(separator: "#", maxSplits: 1).first.map(String.init) ?? String(part)
            for pair in section.split(separator: "&") {
                let bits = pair.split(separator: "=", maxSplits: 1).map(String.init)
                guard bits.count == 2 else { continue }
                let key = (bits[0].removingPercentEncoding ?? bits[0])
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                guard key == "gameId" else { continue }
                let value = (bits[1].removingPercentEncoding ?? bits[1])
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                if !value.isEmpty {
                    return value
                }
            }
        }
        return nil
    }
}

/// 沿响应链找当前游戏中心访问，或发起广告的游戏页访问。
enum LampsBehaviorContext {
    /// 游戏中心这次打开带上的埋点字段。页面中心取访问记录，内嵌中心取 WebView 上保存的表。
    static func centerTrackParams(from responder: UIResponder?) -> [String: String] {
        if let visit = centerVisit(from: responder) {
            return visit.trackParams
        }
        var current = responder
        while let node = current {
            if let webView = node as? LampsWebView {
                return webView.behaviorTrackParams
            }
            current = node.next
        }
        return [:]
    }

    static func centerVisit(from responder: UIResponder?) -> LampsBehaviorVisit? {
        var current = responder
        while let node = current {
            if let page = node as? LampsWebViewController {
                if page is LampsGameWebViewController {
                    current = node.next
                    continue
                }
                guard let visit = page.behaviorVisit, !visit.hasExited else { return nil }
                return visit
            }
            current = node.next
        }
        return nil
    }

    static func gameVisit(from responder: UIResponder?) -> LampsBehaviorVisit? {
        var current = responder
        while let node = current {
            if let page = node as? LampsGameWebViewController {
                return page.behaviorVisit
            }
            current = node.next
        }
        return nil
    }
}

/// 前后台时暂停全部未结束的访问，并负责把 data 交给宿主。
final class LampsBehaviorTracker {
    static let shared = LampsBehaviorTracker()

    private(set) var isInBackground = UIApplication.shared.applicationState == .background
    private var boxes: [ObjectIdentifier: WeakVisit] = [:]
    private var observers: [NSObjectProtocol] = []

    private init() {}

    func track(_ visit: LampsBehaviorVisit) {
        observeAppIfNeeded()
        boxes[ObjectIdentifier(visit)] = WeakVisit(visit)
    }

    func reportOpenFailure(
        kind: LampsBehaviorVisit.Kind,
        gameId: String?,
        error: NSError,
        trackParams: [String: String] = [:]
    ) {
        emitOpen(
            kind: kind,
            gameId: normalized(gameId),
            success: false,
            code: error.code,
            message: error.localizedDescription,
            trackParams: trackParams
        )
    }

    func emitOpen(
        kind: LampsBehaviorVisit.Kind,
        gameId: String?,
        success: Bool,
        code: Int?,
        message: String?,
        trackParams: [String: String] = [:]
    ) {
        let id: Any = gameId.map { $0 as Any } ?? NSNull()
        let text = message?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        emit(
            event: .openPage,
            pageType: kind.pageType,
            data: merging(
                trackParams,
                into: [
                    "type": kind.typeName,
                    "status": success ? "成功" : "失败",
                    "id": id,
                    "code": code.map { $0 as Any } ?? NSNull(),
                    "message": text.isEmpty ? NSNull() : text
                ]
            ),
            trackParams: trackParams
        )
    }

    func emitExit(
        kind: LampsBehaviorVisit.Kind,
        duration: Int,
        gameList: [[String: Any]],
        trackParams: [String: String] = [:]
    ) {
        emit(
            event: .exitPage,
            pageType: kind.pageType,
            data: merging(
                trackParams,
                into: [
                    "type": kind.typeName,
                    "duration": duration,
                    "game_list": gameList
                ]
            ),
            trackParams: trackParams
        )
    }

    /// SDK 自己的字段优先。宿主同名键跳过。
    private func merging(_ trackParams: [String: String], into params: [String: Any]) -> [String: Any] {
        guard !trackParams.isEmpty else { return params }
        var merged = params
        for (key, value) in trackParams where merged[key] == nil {
            merged[key] = value
        }
        return merged
    }

    private func emit(
        event: LampsBehaviorEvent,
        pageType: LampsBehaviorPageType,
        data: [String: Any],
        trackParams: [String: String]
    ) {
        let bridged = Self.objcDictionary(data)
        let behavior = LampsBehavior(
            event: event,
            pageType: pageType,
            data: bridged as? [String: Any] ?? data,
            trackParams: trackParams
        )
        let send = {
            LampsSDKLog.debug("behavior event=\(event.name) pageType=\(pageType.name) data=\(bridged)")
            Lamps.behaviorHandler?(behavior)
        }
        if Thread.isMainThread {
            send()
        } else {
            DispatchQueue.main.async(execute: send)
        }
    }

    /// 嵌套的游戏列表也转成 `NSDictionary` / `NSNumber`，ObjC 拿到的就是字典和数字。
    private static func objcDictionary(_ params: [String: Any]) -> NSDictionary {
        let result = NSMutableDictionary()
        for (key, value) in params {
            result[key] = objcValue(value)
        }
        return result
    }

    private static func objcValue(_ value: Any) -> Any {
        switch value {
        case let text as String:
            return text
        case let number as Int:
            return NSNumber(value: number)
        case let number as NSNumber:
            return number
        case is NSNull:
            return NSNull()
        case let rows as [[String: Any]]:
            let list = NSMutableArray()
            for row in rows {
                list.add(objcDictionary(row))
            }
            return list
        default:
            return "\(value)"
        }
    }

    private func observeAppIfNeeded() {
        guard observers.isEmpty else { return }
        let center = NotificationCenter.default
        observers.append(center.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.isInBackground = true
            self?.refreshLiveVisits()
        })
        observers.append(center.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.isInBackground = false
            self?.refreshLiveVisits()
        })
    }

    private func refreshLiveVisits() {
        boxes = boxes.filter { $0.value.visit != nil }
        boxes.values.forEach { $0.visit?.refreshClock() }
    }

    private func normalized(_ gameId: String?) -> String? {
        let trimmed = gameId?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? nil : trimmed
    }
}

private final class WeakVisit {
    weak var visit: LampsBehaviorVisit?
    init(_ visit: LampsBehaviorVisit) { self.visit = visit }
}

private struct PlayStats {
    var gameId: String?
    var duration = 0
    var adReq = 0
    var adShow = 0
    var adClk = 0
    var price = 0

    var params: [String: Any] {
        [
            "id": gameId.map { $0 as Any } ?? NSNull(),
            "duration": duration,
            "ad_req": adReq,
            "ad_show": adShow,
            "ad_clk": adClk,
            "price": price
        ]
    }
}
