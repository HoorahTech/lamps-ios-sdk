# LampsSDK

面向三方 App 的 iOS SDK：WebView + Bridge、激励视频、CM/PM/XM 监测上报。

当前仓库：`git@gitlab.hupu.com:HPBase/lamps-ios-sdk.git`

实现语言以 **Swift** 为主。公开 API 带 `@objc`，ObjC 宿主仍可调用。

## 分阶段

| 阶段 | 内容 | 状态 |
| --- | --- | --- |
| 1 | 工程骨架、对外入口、Demo | 完成 |
| 2 | WKWebView 展示 | 完成 |
| 3 | Bridge 通信 | 完成 |
| 4 | RM / WM / CM / PM / REM 上报 | 完成 |
| 5 | 激励视频框架（不含三方广告 SDK 二进制） | 完成 |
| 6 | 穿山甲 / 优量汇 / 汇川 Adapter（宿主已有则复用） | 完成 |
| 7 | xcframework 手动集成出包 | 完成 |

## 安装

```ruby
pod 'LampsSDK', :git => 'git@gitlab.hupu.com:HPBase/lamps-ios-sdk.git', :branch => 'main'
# 本地联调：
# pod 'LampsSDK', :path => '../lamps-ios-sdk', :subspecs => ['Core', 'CSJAdapter', 'GDTAdapter', 'NoahAdapter']

# 需要顺带拉广告 SDK 时：
# pod 'LampsSDK/CSJ'    # Ads-CN（公有源）
# pod 'LampsSDK/GDT'    # GDTMobSDK（公有源）
# pod 'LampsSDK/Noah'   # 自带汇川二进制（Vendor/Noah），无需私有 NoahAdSdks
# pod 'LampsSDK/Ads'    # CSJ + GDT + Noah

# 使用 Noah / Ads（默认 subspec 含 Noah）且未开 use_frameworks 时，需为 OC 依赖开 modular headers：
# pod 'AFNetworking', :modular_headers => true
# pod 'SDWebImage', :modular_headers => true
# pod 'YYModel', :modular_headers => true
# 或在 Podfile 全局：use_modular_headers!

# 宿主已自带对应广告 SDK 时，只编适配代码：
# pod 'LampsSDK/CSJAdapter'
# pod 'LampsSDK/GDTAdapter'
# pod 'LampsSDK/NoahAdapter'   # 已有 NoahSDK 时用这个，勿与 Noah 同时开
```

### 源码 / 二进制切换

根目录 [`LampsSDK.podspec`](LampsSDK.podspec) 顶部：

```ruby
use_binary = true   # true=Binary 下 xcframework；false=Classes 源码
```

| `use_binary` | Pods 里看到什么 |
| --- | --- |
| `true` | `LampsSDK/Binary/*.xcframework`（业务源码不可见） |
| `false` | `LampsSDK/Classes/**` 源码编译 |

出包并同步到 Binary：

```bash
./scripts/build_xcframeworks.sh
```

切换后宿主需重新 `pod install`。二进制模式下宿主仍建议加 `-ObjC`（Adapter `+load`）。

本地 Demo：

```bash
cd Example
pod install
open LampsSDK.xcworkspace
```

## 用法

```swift
import LampsSDK

let config = LampsSDKConfig()
config.appId = "your-app-id"
config.debugLogEnabled = true
config.environment = .prd // .dev -> https://api-dev.hoorahgo.com
config.csjAppId = ""
config.gdtAppId = ""
config.noahAppKey = ""
Lamps.start(config: config) { success, error in
    if !success {
        print(error?.localizedDescription ?? "")
        return
    }
    // 启动时会请求 GET /v1/lamps/config；失败不阻断 start
    _ = Lamps.remoteConfig // rewardAdSlots / token / monitorLinks
}

let webVC = LampsWebViewController(urlString: "https://www.hupu.com")
present(UINavigationController(rootViewController: webVC), animated: true)

// 也可以把 LampsWebView 当作独立视图嵌入
let webView = LampsWebView()
container.addSubview(webView)
webView.load(urlString: "https://www.hupu.com")
```

### 配置接口

`start` 本地校验通过后请求：

- prd: `https://api.hoorahgo.com/v1/lamps/config`
- dev: `https://api-dev.hoorahgo.com/v1/lamps/config`

Query：`appid` / `version` / `idfa` / `os`。成功后可通过 `Lamps.remoteConfig` 读取代码位、`token`、`monitorLinks`。IDFA 仅在宿主已获 ATT 授权时读取，SDK 不主动弹授权框。

启动时会先读本地磁盘缓存（按 `appId` + 环境隔离），再请求网络；请求成功覆盖内存并写回缓存，失败则保留已有缓存。

### 激励视频 / Adapter

默认包含 `Core` + 三家 `*Adapter`。未链入广告 SDK 时 `canImport` 跳过注册；链入后生效。

流程对齐 `HCADCommonRewardVideoManager`（无 getOther、无 adm）：

1. 读 `remoteConfig.rewardAdSlots`
2. `channelId` 映射渠道：`2/327`→CSJ，`348/349`→GDT，`417`→Noah
3. 已注册 Adapter **并行 load**
4. 全部返回后按真实价格竞价，只展示赢家（汇川/穿山甲 win-loss 回告）
5. 监测用本 SDK `LampsReporter`（RM/PM/CM/WM）

```swift
config.csjAppId = "..."
config.gdtAppId = "..."
config.noahAppKey = "..."

LampsRewardAd.show(from: self) { rewarded, error in }

LampsRewardAd.show(from: self, handler: { event in
    // loadSuccess / showSuccess / rewardArrived / close ...
}, completion: { rewarded, error in })
```

## 上报（RM / WM / CM / PM / REM）

不区分 SDK / API。流程：组装宏 → 替换 URL 占位符 → GET。

```swift
LampsReporter.reportCM(
    urls: ["https://xx.com/cm?t=__EVENT_TIME_MS__&x=__DOWN_X__"],
    adInfo: ["increasePrice": "10"],
    extra: ["down_x": "100", "down_y": "200", "linkType": "lp"]
)

LampsReporter.reportPM(urls: [...], adInfo: adInfo, extra: ["exposure_type": "1"])
LampsReporter.reportRM(urls: [...], adInfo: nil, extra: ["is_success": "1"])
LampsReporter.reportWM(urls: [...], adInfo: adInfo, extra: nil)
LampsReporter.reportREM(urls: [...], adInfo: nil, extra: nil)
```

REM 签名：使用配置接口返回的 `token`，对含 `__REM_SIGN__` 的 URL，按 query 中 `adpid/app_version/cid/forward_source/price/puid/request_id`（缺失跳过）字母序拼接，尾部直接拼 token，MD5 小写 hex 替换。

`extra` 里也可直接传 `__XXX__` 键覆盖宏值。

公共宏（各上报类型均替换）：

- `__SW__`：屏幕物理宽度（像素，`UIScreen.main.nativeBounds`）
- `__SH__`：屏幕物理高度（像素）
- `__UA__`：WebKit User-Agent（`Lamps.start` 时预取并缓存；可用 `extra["ua"]` 或 `__UA__` 覆盖）
- `__MAC__`：Wi‑Fi MAC（`en0`；iOS 对第三方多为占位 `02:00:00:00:00:00`；可用 `extra["mac"]` 覆盖）
- `__IDFA__`：广告标识符（未授权或不可用时为空）
- `__APPID__`：SDK 分配的 appId（`Lamps.start` 传入的 `config.appId`）
- `__SDK_VERSION__`：SDK 版本号（与 podspec `s.version` / `Lamps.sdkVersion` 一致）
- `__NETWORK__`：网络环境（`wifi` / `2g` / `3g` / `4g` / `5g` / `unknown`）
- `__IP__`：客户端 IP（配置接口返回的 `clientIp`；未拉取成功时为空）
- 也可通过 `extra` 的 `sw` / `sh` 或 `__SW__` / `__SH__` 覆盖

## Bridge

Native 只监听 `window.webkit.messageHandlers.lamps`，不注入 JS。H5 自行实现封装。

消息格式：

```js
window.webkit.messageHandlers.lamps.postMessage({
  method: 'ping',
  data: { from: 'h5' },
  successcb: 'cb_ok_1',
  errorcb: 'cb_err_1'
})
```

Native 回包 / 主动调 H5 会执行（H5 需实现）：

```js
// H5 → Native 的回调回包
window.LampsBridge._handle_(callbackId, data)

// Native → H5 主动调用
window.LampsBridge._handle_(method, data, successcb, errorcb)
```

H5 处理完 Native 主动调用后，用 callbackId 作为 `method` 回包：

```js
window.webkit.messageHandlers.lamps.postMessage({
  method: successcb,
  data: { ok: true }
})
```

Native 主动调 H5：

```swift
webView.bridge.send(
    method: "onNativeEvent",
    data: ["from": "native"],
    success: { result in
        // H5 成功回包
    },
    error: { result in
        // H5 失败回包
    }
)
```

按业务分组添加 Handler，`LampsBridge` 按 `method` 分发；本次调用的 success / error 回调直接传给 Handler，无需单独注册方法：

```swift
final class RewardBridgeHandler: NSObject, LampsBridgeHandler {
    weak var bridge: LampsBridge?

    var supportedMethods: [String] { ["showReward"] }

    func handle(method: String, data: [AnyHashable: Any], success: LampsBridgeToH5Callback?, error: LampsBridgeToH5Callback?) {
        // 激励视频逻辑
        success?(["rewarded": true])
    }
}

webView.bridge.addHandler(RewardBridgeHandler())
webView.closeHandler = { /* 关闭页面 */ }
```

默认已挂载：

- `LampsBaseBridgeHandler`：`ping`
- `LampsNavigationBridgeHandler`：`close`

## 手动 Framework（xcframework）集成

### 出包

```bash
./scripts/build_xcframeworks.sh
# 产物：build/xcframeworks/LampsSDK-iOS-0.1.0/
```

产出 4 个包：`LampsSDK`（Core）+ `LampsCSJAdapter` / `LampsGDTAdapter` / `LampsNoahAdapter`，以及可选 `ThirdParty/`（补宿主缺失的广告 SDK）。

详细接入（无 / 全有 / 只有部分广告 SDK）见 [scripts/FRAMEWORK_INTEGRATION.md](scripts/FRAMEWORK_INTEGRATION.md)。

### 原则（与 Pod Subspec 对齐）

- 必选：`LampsSDK.xcframework`
- 按渠道选 Adapter；缺哪家广告 SDK 就补 `ThirdParty` 里哪家；已有则只加 Adapter
- `Other Linker Flags` 加 `-ObjC`
- 不要打「含全部 Adapter 的单一静态大包」给所有宿主

| Pod | Framework |
| --- | --- |
| `LampsSDK/Core` | `LampsSDK.xcframework` |
| `LampsSDK/CSJAdapter` | `Adapters/LampsCSJAdapter.xcframework` |
| `LampsSDK/CSJ` | Adapter + `ThirdParty/Ads-CN` |
| `LampsSDK/GDTAdapter` | `Adapters/LampsGDTAdapter.xcframework` |
| `LampsSDK/GDT` | Adapter + `ThirdParty/GDTMobSDK` |
| `LampsSDK/NoahAdapter` | `Adapters/LampsNoahAdapter.xcframework` |
| `LampsSDK/Noah` | Adapter + `ThirdParty/Noah` |
