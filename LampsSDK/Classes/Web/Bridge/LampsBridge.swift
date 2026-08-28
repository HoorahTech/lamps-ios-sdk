import Foundation
import WebKit

/// 挂在 `LampsWebView` 上的 Bridge（模块内部，不对外开放）。
/// - H5 → Native：按 method 分发给 Handler
/// - Native → H5：`send(method:data:success:error:)` 主动调用
@objcMembers
final class LampsBridge: NSObject, WKScriptMessageHandler {
    static let messageName = "chatMessage"

    weak var webView: LampsWebView?
    private(set) var handlers: [LampsBridgeHandler] = []

    private var pendingSuccessCallbacks: [String: LampsBridgeToH5Callback] = [:]
    private var pendingErrorCallbacks: [String: LampsBridgeToH5Callback] = [:]
    private let lock = NSLock()

    init(webView: LampsWebView) {
        self.webView = webView
        super.init()
    }

    func install() {
        guard let webView = webView else { return }
        webView.configuration.userContentController.add(self, name: Self.messageName)
    }

    func notifyContainerWillAppear() {
        for handler in handlers {
            handler.containerWillAppear?()
        }
    }

    func notifyContainerWillDisappear() {
        for handler in handlers {
            handler.containerWillDisappear?()
        }
    }

    func notifyContainerDidDestroy() {
        for handler in handlers {
            handler.containerDidDestroy?()
        }
    }

    func uninstall() {
        notifyContainerDidDestroy()
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: Self.messageName)
        handlers.removeAll()
        lock.lock()
        pendingSuccessCallbacks.removeAll()
        pendingErrorCallbacks.removeAll()
        lock.unlock()
    }

    /// 添加一组业务 Handler。
    @objc(addHandler:)
    func addHandler(_ handler: LampsBridgeHandler) {
        handler.bridge = self
        handlers.append(handler)
    }

    /// Native 主动调用 H5。H5 需实现 `_handle_(method, data, successcb, errorcb)`。
    @objc(sendMethod:data:success:error:)
    func send(
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
        evaluate("window.HoorahBridge && window.HoorahBridge._handle_(\(methodJSON), \(dataJSON), \(successJSON), \(errorJSON));")
    }

    /// 解析 JSON 字符串并分发。
    @objc(flushMessageQueue:)
    func flushMessageQueue(_ jsStr: String) {
        guard let data = jsStr.data(using: .utf8),
              let object = try? JSONSerialization.jsonObject(with: data, options: [.allowFragments]),
              let dictionary = object as? [String: Any] else {
            LampsSDKLog.debug("bridge ignore invalid json: \(jsStr)")
            return
        }
        dispatch(dictionary)
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
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
        static let callbackId = "id"
    }

    func dispatch(_ dictionary: [String: Any]) {
        let method = LampsJSONValue.stringValue(dictionary[MessageKey.method])
        guard !method.isEmpty else {
            LampsSDKLog.debug("bridge ignore empty method")
            return
        }

        let payload = dictionary[MessageKey.data] as? [AnyHashable: Any] ?? [:]

        // Native → H5 之后，H5 用 callbackId 作为 method 回包
        if consumePendingCallback(method: method, data: payload) {
            return
        }

        let callbackId = LampsJSONValue.stringValue(dictionary[MessageKey.callbackId])

        let successCallback: LampsBridgeToH5Callback? = callbackId.isEmpty ? nil : { [weak self] data in
            self?.invokeH5Callback(callbackId: callbackId, data: data)
        }
        let errorCallback: LampsBridgeToH5Callback? = callbackId.isEmpty ? nil : { [weak self] data in
            self?.invokeH5Callback(callbackId: callbackId, data: data)
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
        let finalParams: [AnyHashable: Any] = [
            "type": "response",
            "data": data,
            "id": callbackId,
        ]
        guard let data = try? JSONSerialization.data(withJSONObject: finalParams, options: []),
              let responseStr = String(data: data, encoding: .utf8) else {
            return
        }
        evaluate("window.receiveNativeMessage && window.receiveNativeMessage(\(responseStr))")
    }

    func evaluate(_ script: String) {
        DispatchQueue.main.async { [weak self] in
            self?.webView?.evaluateJavaScript(script, completionHandler: { result, error in
                if let error {
                    LampsSDKLog.debug("bridge evaluate failed: \(error.localizedDescription)")
                    return
                }
                LampsSDKLog.debug("bridge evaluate ok result=\(String(describing: result))")
            })
        }
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
