import UIKit
import LampsSDK

@objc(LAMPSSDKViewController)
final class LAMPSSDKViewController: UIViewController {
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            makeButton(title: "打开 WebView", action: #selector(openWebView)),
            makeButton(title: "打开 Bridge Demo", action: #selector(openBridgeDemo)),
            makeButton(title: "激励视频（并行竞价）", action: #selector(showReward)),
            makeButton(title: "上报 RM/WM/CM/PM/REM", action: #selector(reportStub)),
            makeButton(title: "调试工具", action: #selector(openDevTools))
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16
        stack.distribution = .fillEqually
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            stackView.widthAnchor.constraint(lessThanOrEqualToConstant: 320),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),
            stackView.heightAnchor.constraint(equalToConstant: 320)
        ])
    }

    private func makeButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.96, alpha: 1)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    @objc private func openWebView() {
        let webVC = LampsWebViewController(urlString: "https://www.hupu.com")
        presentWeb(webVC)
    }

    @objc private func openBridgeDemo() {
        let webVC = LampsWebViewController(htmlString: BridgeDemoHTML.content)
        webVC.webView.bridge.addHandler(BridgeDemoSendHandler())
        presentWeb(webVC)
    }

    @objc private func showReward() {
        LampsRewardAd.show(from: self) { [weak self] rewarded, error in
            let message = error?.localizedDescription ?? (rewarded ? "发奖成功" : "未发奖")
            self?.showAlert(title: "激励视频", message: message)
        }
    }

    @objc private func reportStub() {
        let adInfo: [AnyHashable: Any] = [
            "brand_name": "demo-brand",
            "title": "demo-title",
            "increasePrice": "10"
        ]
        LampsReporter.reportRM(
            urls: ["https://example.com/rm?ok=__IS_SUCCESS__&reason=__FILTER_REASON__&t=__EVENT_TIME_MS__"],
            adInfo: adInfo,
            extra: ["is_success": "1", "filter_reason": "1"]
        )
        LampsReporter.reportWM(
            urls: ["https://example.com/wm?brand=__BRAND_NAME__&title=__TITLE__&t=__EVENT_TIME_MS__"],
            adInfo: adInfo,
            extra: nil
        )
        LampsReporter.reportCM(
            urls: ["https://example.com/cm?x=__DOWN_X__&y=__DOWN_Y__&t=__EVENT_TIME_MS__"],
            adInfo: adInfo,
            extra: ["down_x": "100", "down_y": "200", "linkType": "lp"]
        )
        LampsReporter.reportPM(
            urls: ["https://example.com/pm?type=__EXPOSURE_TYPE__&t=__EVENT_TIME_MS__"],
            adInfo: adInfo,
            extra: ["exposure_type": "1"]
        )
        LampsReporter.reportREM(
            urls: ["https://example.com/rem?puid=1&cid=2&adpid=3&request_id=req&app_version=1.0&price=100&forward_source=demo&sign=__REM_SIGN__"],
            adInfo: adInfo,
            extra: nil
        )
        showAlert(title: "上报", message: "已触发 RM/WM/CM/PM/REM，详见控制台日志。")
    }

    @objc private func openDevTools() {
        LampsDevTools.present(from: self)
    }

    private func presentWeb(_ webVC: LampsWebViewController) {
        let nav = UINavigationController(rootViewController: webVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "好", style: .default))
        present(alert, animated: true)
    }
}

/// Demo：H5 调 askNativeSend 后，Native 再主动 send 到 H5。
private final class BridgeDemoSendHandler: NSObject, LampsBridgeHandler {
    weak var bridge: LampsBridge?

    var supportedMethods: [String] { ["askNativeSend"] }

    func handle(
        method: String,
        data: [AnyHashable: Any],
        success: LampsBridgeToH5Callback?,
        error: LampsBridgeToH5Callback?
    ) {
        bridge?.send(
            method: "onNativeEvent",
            data: ["from": "native", "message": "hello from native"],
            success: { result in
                success?(["sent": true, "h5Result": result])
            },
            error: { result in
                error?(["sent": false, "h5Result": result])
            }
        )
    }
}

private enum BridgeDemoHTML {
    static let content = """
    <!doctype html>
    <html>
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <title>Lamps Bridge Demo</title>
      <style>
        body { font-family: -apple-system, sans-serif; margin: 24px; color: #222; }
        button { display: block; width: 100%; margin: 12px 0; padding: 12px; font-size: 16px; }
        pre { background: #f5f5f5; padding: 12px; white-space: pre-wrap; word-break: break-all; }
      </style>
    </head>
    <body>
      <h3>Lamps Bridge Demo</h3>
      <button onclick="ping()">调用 Native ping</button>
      <button onclick="askNativeSend()">请求 Native 主动调 H5</button>
      <button onclick="closePage()">调用 Native close</button>
      <pre id="log">等待操作...</pre>
      <script>
        (function() {
          var callbacks = {};
          window.LampsBridge = {
            call: function(method, data, success, error) {
              var successcb = '';
              var errorcb = '';
              if (typeof success === 'function') {
                successcb = 'cb_ok_' + Date.now() + '_' + Math.random().toString(16).slice(2);
                callbacks[successcb] = success;
              }
              if (typeof error === 'function') {
                errorcb = 'cb_err_' + Date.now() + '_' + Math.random().toString(16).slice(2);
                callbacks[errorcb] = error;
              }
              window.webkit.messageHandlers.lamps.postMessage({
                method: String(method || ''),
                data: data || {},
                successcb: successcb,
                errorcb: errorcb
              });
            },
            _handle_: function(methodOrCb, data, successcb, errorcb) {
              if (typeof successcb === 'string' || typeof errorcb === 'string') {
                if (methodOrCb === 'onNativeEvent') {
                  log('收到 Native 主动调用: ' + JSON.stringify(data));
                  if (successcb) {
                    window.webkit.messageHandlers.lamps.postMessage({
                      method: successcb,
                      data: { ok: true, echo: data }
                    });
                  }
                }
                return;
              }
              var callback = callbacks[methodOrCb];
              if (callback) {
                callback(data);
                delete callbacks[methodOrCb];
              }
            }
          };
        })();
        function log(text) {
          document.getElementById('log').textContent = text;
        }
        function ping() {
          LampsBridge.call('ping', { from: 'h5', time: Date.now() }, function(result) {
            log('ping 成功: ' + JSON.stringify(result));
          }, function(error) {
            log('ping 失败: ' + JSON.stringify(error));
          });
        }
        function askNativeSend() {
          LampsBridge.call('askNativeSend', {}, function(result) {
            log('askNativeSend 完成: ' + JSON.stringify(result));
          }, function(error) {
            log('askNativeSend 失败: ' + JSON.stringify(error));
          });
        }
        function closePage() {
          LampsBridge.call('close', {}, function() {}, function() {});
        }
      </script>
    </body>
    </html>
    """
}
