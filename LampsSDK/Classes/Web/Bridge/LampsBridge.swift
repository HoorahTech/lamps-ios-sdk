import Foundation
import WebKit

/// 挂在 `LampsWebView` 上的 Bridge。
/// - H5 → Native：按 method 分发给 Handler
/// - Native → H5：`send(method:data:success:error:)` 主动调用
@objcMembers
public final class LampsBridge: NSObject, WKScriptMessageHandler {
    public static let messageName = "lamps"

    public weak var webView: LampsWebView?
    public private(set) var handlers: [LampsBridgeHandler] = []

    private var pendingSuccessCallbacks: [String: LampsBridgeToH5Callback] = [:]
    private var pendingErrorCallbacks: [String: LampsBridgeToH5Callback] = [:]
    private let lock = NSLock()

    private var installed = false
    private var scriptMessageHandler: LampsWeakScriptMessageHandler?

    public init(webView: LampsWebView) {
        self.webView = webView
        super.init()
    }

    func install() {
        guard !installed, let webView = webView else { return }
        installed = true
        let proxy = LampsWeakScriptMessageHandler(target: self)
        scriptMessageHandler = proxy
        webView.configuration.userContentController.add(proxy, name: Self.messageName)
    }

    func uninstall() {
        guard installed else { return }
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: Self.messageName)
        scriptMessageHandler = nil
        installed = false
        handlers.removeAll()
        lock.lock()
        pendingSuccessCallbacks.removeAll()
        pendingErrorCallbacks.removeAll()
        lock.unlock()
    }

    /// 添加一组业务 Handler。
    @objc(addHandler:)
    public func addHandler(_ handler: LampsBridgeHandler) {
        handler.bridge = self
        handlers.append(handler)
    }

    /// Native 主动调用 H5。H5 需实现 `_handle_(method, data, successcb, errorcb)`。
    @objc(sendMethod:data:success:error:)
    public func send(
        method: String,
        data: [AnyHashable: Any] = [:],
        success: LampsBridgeToH5Callback? = nil,
        error: LampsBridgeToH5Callback? = nil
    ) {
        let token = UUID().uuidString
        let successId = success == nil ? "" : "native_ok_\(token)"
        let errorId = error == nil ? "" : "native_err_\(token)"

        lock.lock()
        if let success = success, !successId.isEmpty {
            pendingSuccessCallbacks[successId] = success
        }
        if let error = error, !errorId.isEmpty {
            pendingErrorCallbacks[errorId] = error
        }
        lock.unlock()

        let methodJSON = LampsBridgeJSON.stringify(method)
        let dataJSON = LampsBridgeJSON.stringify(data) ?? "{}"
        let successJSON = LampsBridgeJSON.stringify(successId)
        let errorJSON = LampsBridgeJSON.stringify(errorId)
        LampsSDKLog.debug("bridge send method=\(method) successcb=\(successId) errorcb=\(errorId)")
        evaluate("window.LampsBridge && window.LampsBridge._handle_(\(methodJSON), \(dataJSON), \(successJSON), \(errorJSON));")
    }

    /// 解析 JSON 字符串并分发。
    @objc(flushMessageQueue:)
    public func flushMessageQueue(_ jsStr: String) {
        guard let data = jsStr.data(using: .utf8),
              let object = try? JSONSerialization.jsonObject(with: data, options: [.allowFragments]),
              let dictionary = object as? [String: Any] else {
            LampsSDKLog.debug("bridge ignore invalid json: \(jsStr)")
            return
        }
        dispatch(dictionary)
    }

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == Self.messageName else { return }
        if let text = message.body as? String {
            flushMessageQueue(text)
            return
        }
        if let dictionary = message.body as? [String: Any] {
            dispatch(dictionary)
            return
        }
        LampsSDKLog.debug("bridge ignore invalid message: \(message.body)")
    }
}

private extension LampsBridge {
    enum MessageKey {
        static let method = "method"
        static let data = "data"
        static let successCallback = "successcb"
        static let errorCallback = "errorcb"
        static let errorCallbackId = "errorcallbackId"
    }

    func dispatch(_ dictionary: [String: Any]) {
        let method = stringValue(dictionary[MessageKey.method])
        guard !method.isEmpty else {
            LampsSDKLog.debug("bridge ignore empty method")
            return
        }

        let payload = dictionary[MessageKey.data] as? [AnyHashable: Any] ?? [:]

        // Native → H5 之后，H5 用 callbackId 作为 method 回包
        if consumePendingCallback(method: method, data: payload) {
            return
        }

        var successId = stringValue(dictionary[MessageKey.successCallback])
        var errorId = stringValue(dictionary[MessageKey.errorCallbackId])
        if errorId.isEmpty {
            errorId = stringValue(dictionary[MessageKey.errorCallback])
        }

        let successCallback: LampsBridgeToH5Callback? = successId.isEmpty ? nil : { [weak self] data in
            self?.invokeH5Callback(callbackId: successId, data: data)
        }
        let errorCallback: LampsBridgeToH5Callback? = errorId.isEmpty ? nil : { [weak self] data in
            self?.invokeH5Callback(callbackId: errorId, data: data)
        }

        guard let handler = handlers.first(where: { $0.supportedMethods.contains(method) }) else {
            LampsSDKLog.debug("bridge unknown method=\(method)")
            errorCallback?(["success": false, "error": "unknown method: \(method)"])
            return
        }

        LampsSDKLog.debug("bridge recv method=\(method) handler=\(type(of: handler))")
        handler.handle(method: method, data: payload, success: successCallback, error: errorCallback)
    }

    @discardableResult
    func consumePendingCallback(method: String, data: [AnyHashable: Any]) -> Bool {
        lock.lock()
        let success = pendingSuccessCallbacks.removeValue(forKey: method)
        let error = pendingErrorCallbacks.removeValue(forKey: method)
        if success != nil || error != nil {
            // 成对清理另一侧，避免泄漏
            if method.hasPrefix("native_ok_") {
                let pair = "native_err_" + method.dropFirst("native_ok_".count)
                pendingErrorCallbacks.removeValue(forKey: pair)
            } else if method.hasPrefix("native_err_") {
                let pair = "native_ok_" + method.dropFirst("native_err_".count)
                pendingSuccessCallbacks.removeValue(forKey: pair)
            }
        }
        lock.unlock()

        if let success = success {
            LampsSDKLog.debug("bridge native-call successcb=\(method)")
            success(data)
            return true
        }
        if let error = error {
            LampsSDKLog.debug("bridge native-call errorcb=\(method)")
            error(data)
            return true
        }
        return false
    }

    func invokeH5Callback(callbackId: String, data: [AnyHashable: Any]) {
        let idJSON = LampsBridgeJSON.stringify(callbackId)
        let dataJSON = LampsBridgeJSON.stringify(data) ?? "{}"
        evaluate("window.LampsBridge && window.LampsBridge._handle_(\(idJSON), \(dataJSON));")
    }

    func evaluate(_ script: String) {
        DispatchQueue.main.async { [weak self] in
            self?.webView?.evaluateJavaScript(script, completionHandler: nil)
        }
    }

    func stringValue(_ value: Any?) -> String {
        if let text = value as? String {
            return text
        }
        if let number = value as? NSNumber {
            return number.stringValue
        }
        return ""
    }
}

enum LampsBridgeJSON {
    static func stringify(_ dictionary: [AnyHashable: Any]) -> String? {
        guard JSONSerialization.isValidJSONObject(dictionary),
              let data = try? JSONSerialization.data(withJSONObject: dictionary),
              let text = String(data: data, encoding: .utf8) else {
            return nil
        }
        return text
    }

    static func stringify(_ string: String) -> String {
        guard let data = try? JSONSerialization.data(withJSONObject: [string]),
              let wrapped = String(data: data, encoding: .utf8) else {
            return "\"\""
        }
        return String(wrapped.dropFirst().dropLast())
    }
}
