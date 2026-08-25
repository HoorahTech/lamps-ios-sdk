import UIKit
import LampsSDK
import LampsDevTools

@objc(LAMPSSDKViewController)
final class LAMPSSDKViewController: UIViewController {
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            makeButton(title: "打开游戏中心", action: #selector(openWebView)),
            makeButton(title: "打开 Bridge Demo", action: #selector(openBridgeDemo)),
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
        title = "Lamps Demo"
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
        if !Lamps.showGameCenter(from: self) {
            NSLog("[LampsSDK Demo] gameCenterPage unavailable")
        }
    }

    @objc private func openBridgeDemo() {
        let webVC = LampsWebViewController(htmlString: BridgeDemoHTML.content)
        navigationController?.pushViewController(webVC, animated: true)
    }

    @objc private func openDevTools() {
        LampsDevTools.push(from: self)
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
      <button onclick="bridgeReady()">调用 Native bridgeReady</button>
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
                if (methodOrCb === 'hoorah.ad.rewardedVideoStatus') {
                  log('激励状态: ' + JSON.stringify(data));
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
        function bridgeReady() {
          LampsBridge.call('lamps.common.bridgeReady', {}, function(result) {
            log('bridgeReady 成功: ' + JSON.stringify(result));
          }, function(error) {
            log('bridgeReady 失败: ' + JSON.stringify(error));
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
