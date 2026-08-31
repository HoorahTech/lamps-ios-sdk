# LampsSDK

面向三方 App 的 iOS SDK：WebView + Bridge、激励视频、CM/PM/XM 监测上报。

当前仓库：`git@gitlab.hupu.com:HPBase/lamps-ios-sdk.git`

日常在 GitLab 开发，发版再同步 GitHub / CocoaPods。流程见 [`docs/开发与发版流程.md`](docs/开发与发版流程.md)。

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
#
# 注意：*Adapter 不声明三方 dependency，但源码无条件 import 对应 module。
# 宿主须在 post_install 把已有 SDK 的 FRAMEWORK_SEARCH_PATHS 挂到 LampsSDK（并建议 add_dependency），
# 缺配置会编译失败；参考主工程 ios/Podfile 的 lamps_wire_host_ad_sdks_for_adapters。
# 若希望 Lamps 自己拉公有源 SDK，改用 CSJ / GDT / Noah，不要用 *Adapter。

# DevTools（独立模块，源码/二进制都 `import LampsDevTools`；建议仅 Debug 引用）：
# pod 'LampsDevTools', :git => 'git@gitlab.hupu.com:HPBase/lamps-ios-sdk.git', :branch => 'main', :configurations => ['Debug']
# 本地：pod 'LampsDevTools', :path => '../lamps-ios-sdk', :configurations => ['Debug']
# import LampsDevTools
# LampsDevTools.present(from: self)  // 可切换配置环境 prd / dev
# use_binary=true 时也可用 pod 'LampsSDK/DevTools'（引入 xcframework，同样 import LampsDevTools）
```

### 源码 / 二进制切换

根目录 [`LampsSDK.podspec`](LampsSDK.podspec) 顶部：

```ruby
use_binary = true   # true=Binary 下 xcframework；false=Classes 源码
```

| `use_binary` | Pods 里看到什么 |
| --- | --- |
| `true` | `LampsSDK/Binary/*.xcframework`（含 Adapters、DevTools；业务源码不可见） |
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
Lamps.start(config: config) { success, error in
    if !success {
        print(error?.localizedDescription ?? "")
        return
    }
    // 启动时会请求 GET /v1/lamps/config；代码位与监测链接由 SDK 内部使用
}

// 打开游戏中心。可不传页面，SDK 会取当前最上层 VC。
// 有宿主导航则 push；要避开宿主导航栏时用 presentGameCenter。
Lamps.showGameCenter { success, error in
    if !success {
        print(error?.localizedDescription ?? "")
    }
}
Lamps.presentGameCenter { success, error in
    if !success {
        print(error?.localizedDescription ?? "")
    }
}

let webVC = LampsWebViewController(urlString: "https://www.hupu.com")
present(UINavigationController(rootViewController: webVC), animated: true)

// 游戏 H5：与上面相同，额外在右上角提供关闭按钮
let gameVC = LampsGameWebViewController(urlString: "https://example.com/game")
navigationController?.pushViewController(gameVC, animated: true)

// 也可以把 LampsWebView 当作独立视图嵌入
let webView = LampsWebView()
container.addSubview(webView)
webView.load(urlString: "https://www.hupu.com")
```

### 配置接口

`start` 本地校验通过后请求（默认正式环境）：

- prd: `https://api.hoorahgo.com/v1/lamps/config`
- dev: `https://api-dev.hoorahgo.com/v1/lamps/config`

测试环境请在 `LampsDevTools` 中切换；选择会写到本机，下次启动仍生效。宿主不要、也无法在 `LampsSDKConfig` 上设置环境。

Query：`appid` / `version` / `idfa` / `os`。成功后 SDK 内部使用 `channelList`（广告 SDK AppId）、代码位、`token`、`monitorLinks`，不向宿主开放。IDFA 仅在宿主已获 ATT 授权时读取，SDK 不主动弹授权框。

启动时会先读本地磁盘缓存（按 `appId` + 环境隔离），再请求网络；请求成功覆盖内存并写回缓存，失败则保留已有缓存。

### 激励视频 / Adapter

默认包含 `Core` + 三家 `*Adapter`（或 `CSJ`/`GDT`/`Noah`）。

| 宿主三方 SDK 集成方式 | 应选 subspec | 说明 |
| --- | --- | --- |
| 走 CocoaPods 公有源，交给 Lamps 拉 | `CSJ` / `GDT` / `Noah` | Adapter + dependency |
| 本地/其它 Pod 已集成（如 HPByteThirdParty） | `CSJAdapter` / `GDTAdapter` / `NoahAdapter` | 无 dependency；源码模式须 post_install 挂 module 路径，否则编译失败 |

未挂搜索路径且未改用 `CSJ`/`GDT`/`Noah` 时，源码编译会立刻报错（不再静默跳过注册）。

激励视频 **不向宿主开放 Native API**。宿主打开 Web 页后，由 H5 调用 `hra.ad.showRewardedVideo`，客户端完成 load → 竞价 → show。

流程对齐 `HCADCommonRewardVideoManager`（无 getOther、无 adm）：

1. 读内部 `remoteConfig.rewardAdSlots`
2. `channelId` 映射渠道：`CSJ`→穿山甲，`GDT`→优量汇，`NOAH`→汇川
3. 已注册 Adapter **并行 load**
4. 全部返回后按真实价格竞价，只展示赢家（汇川/穿山甲 win-loss 回告）
5. 监测由 SDK 内部上报（RM/PM/CM/WM/REM）

```swift
// 三方广告 SDK 的 AppId / AppKey 来自配置接口 `channelList.channelAppId`，宿主不必再传。
// channelAppId 为空或未下发该渠道时，Lamps 跳过对应 SDK init。

// 由 Lamps 负责 init 时可用的通用开关（有默认值，可不设）：
// config.personalizedRecommendEnabled = true  // 个性化推荐（优量汇）
// config.shakeAdsEnabled = true               // 摇一摇（穿山甲 / 优量汇）
// config.allowLocation = false                // 定位（汇川；默认禁止）
```

## 上报（RM / WM / CM / PM / REM）

监测上报由 SDK 在激励流程中自动完成，**不向宿主开放 Native API**。不区分 SDK / API。流程：组装宏 → 替换 URL 占位符 → GET。URL 来自配置接口的 `monitorLinks`。

REM 签名：使用配置接口返回的 `token`，对含 `__REM_SIGN__` 的 URL，按 query 中 `adpid/app_version/cid/forward_source/price/puid/request_id`（缺失跳过）字母序拼接，尾部直接拼 token，MD5 小写 hex 替换。

`extra` 里也可直接传 `__XXX__` 键覆盖宏值。

公共宏（各上报类型均替换）：

- `__SW__`：屏幕物理宽度（像素，`UIScreen.main.nativeBounds`）
- `__SH__`：屏幕物理高度（像素）
- `__UA__`：WebKit User-Agent（`Lamps.start` 时预取并缓存）
- `__MAC__`：Wi‑Fi MAC（`en0`；iOS 对第三方多为占位 `02:00:00:00:00:00`）
- `__IDFA__`：广告标识符（未授权或不可用时为空）
- `__IDFV__`：Vendor 标识符（`UIDevice.identifierForVendor`；不可用时为空）
- `__APPID__`：SDK 分配的 appId（`Lamps.start` 传入的 `config.appId`）
- `__SDK_VERSION__`：SDK 版本号（与 podspec `s.version` / `Lamps.sdkVersion` 一致）
- `__PACKAGE_NAME__`：宿主 App 包名（`Bundle.main.bundleIdentifier`）
- `__NETWORK__`：网络环境（`wifi` / `2g` / `3g` / `4g` / `5g` / `unknown`）
- `__IP__`：客户端 IP（配置接口返回的 `clientIp`；未拉取成功时为空）
- `__REQUEST_ID__`：激励会话 requestId（同一次激励内 RM/WM/CM/PM/REM 共用）
- `__FORWARD_SOURCE__`：H5 传入的场景来源

## Bridge

Bridge 挂在 `LampsWebView` 内部，**不作为宿主 Native API 开放**（不能 `addHandler` / `send`）。打开 `LampsWebViewController` / `LampsGameWebViewController` 或嵌入 `LampsWebView` 后，H5 即可调用内置方法。

Native 只监听 `window.webkit.messageHandlers.chatMessage`，不注入 JS。H5 自行实现封装。

消息格式：

```js
window.webkit.messageHandlers.chatMessage.postMessage({
  method: 'ping',
  data: { from: 'h5' },
  id: 'cb_1'
})
```

内置方法：

- `ping`
- `lamps.ui.pageclose`
- `lamps.common.statusBar`
- `lamps.ad.showRewardedVideo`
- `lamps.common.request`
- `lamps.common.track`
- `lamps.game.open`

Native 主动调 H5 会执行（H5 需实现 `window.HoorahBridge._handle_`）：

```js
window.HoorahBridge._handle_(method, data, successcb, errorcb)
```

### 激励视频 Bridge

H5 调用 `hra.ad.showRewardedVideo` 一次，客户端完成 load → 竞价 → show。忙态由 `LampsRewardVideoManager` 处理。

入参 `data`：

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `forward_source` | string | 否 | 场景来源，写入监测 `__FORWARD_SOURCE__` |

```json
{ "forward_source": "h5_game" }
```

生命周期全部通过 Native → H5 `hoorah.ad.rewardedVideoStatus` 回调，用 `callbackName` 区分（如 `loadSuccess` → `onLoadSuccess`）：

```json
{ "callbackName": "onLoadSuccess" }
```

失败时带 `data.errCode` / `data.errMsg`，例如全部 SDK 加载失败：

```json
{
  "callbackName": "onLoadError",
  "data": {
    "errCode": 2009,
    "errMsg": "all reward ad SDKs failed to load"
  }
}
```

### 通用 HTTP Bridge

H5 调用 `lamps.common.request`，由客户端 `URLSession` 发 GET / POST，不走 WebView JS 网络。

入参 `data`：

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `url` | string | 是 | 完整 `http(s)` URL |
| `method` | string | 是 | `get` 或 `post`（大小写不敏感） |
| `data` | object | 否 | GET 拼到 query；POST 按 `Content-Type` 编成 JSON 或 form body |
| `header` | object | 否 | 请求头。`Content-Type` 忽略大小写；`Referer` 不发送 |

```json
{
  "url": "https://api.example.com/v1/data",
  "method": "get",
  "data": { "page": "1", "size": "20" },
  "header": {
    "Content-Type": "application/json",
    "Authorization": "Bearer xxx"
  }
}
```

成功时通过本次 invoke 回调返回：

```json
{
  "msg": "",
  "data": {
    "status": 200,
    "statusText": "ok",
    "data": "<URL-encoded response body>"
  }
}
```

`data.data` 已按 `encodeURIComponent` 规则编码，H5 用 `decodeURIComponent` 还原。参数非法或网络失败走 error 回调，`msg` 为原因。

### 性能/事件上报 Bridge

H5 调用 `lamps.common.track`，Native 对入参 `url` 直接发 GET，不改写地址。

入参 `data`：

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `url` | string | 是 | 完整上报 `http(s)` URL |
| `type` | string | 否 | 预留，暂无业务含义，Native 不使用 |

```json
{
  "type": "page_load",
  "url": "https://example.com/page"
}
```

收到合法 `url` 后发起 GET，完成后通过本次 invoke 回调：成功 `{ "msg": "" }`，失败 `{ "msg": "原因" }`（含非法 url、网络错误、非 2xx）。

### 关闭 H5 页 Bridge

H5 调用 `lamps.ui.pageclose`，客户端关闭当前容器：模态则 `dismiss`，否则 `pop`。无入参。

`LampsWebViewController` / `LampsGameWebViewController` 已接好关闭。若宿主自己嵌入 `LampsWebView`，需设置 `closeHandler`：

```swift
webView.closeHandler = { /* 关闭页面 */ }
```

成功 `{ "msg": "success" }`；找不到可关闭容器走 error 回调。

### 状态栏 Bridge

H5 调用 `lamps.common.statusBar`，控制状态栏显隐、沉浸式布局、背景色和文字颜色。

入参 `data`：

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `showStatusBar` | boolean | 否 | `true` 显示系统状态栏；`false` 隐藏。默认 `true` |
| `statusBarImmersive` | boolean | 否 | `true` 沉浸式，WebView 从屏幕顶部布局；`false` 从状态栏下方开始。默认 `true` |
| `backgroundColor` | string | 否 | 状态栏区域背景色（iOS 状态栏本身无颜色，设置的是容器背景），hex，如 `#FFFFFF` |
| `statusBarFontStyle` | number | 否 | `0` 浅色；`1` 深色。默认 `1` |

```json
{
  "showStatusBar": true,
  "statusBarImmersive": true,
  "backgroundColor": "#FFFFFF",
  "statusBarFontStyle": 1
}
```

未传的布尔 / 字号字段按上表默认值生效；`backgroundColor` 未传或非法则不改容器背景。成功 `{ "msg": "success" }`；找不到 `LampsWebViewController` 容器走 error 回调。

### 打开游戏页 Bridge

游戏中心仍走 `LampsWebViewController` / `makeGameCenterView()`。从中心跳进具体游戏时，H5 调用 `lamps.game.open`，客户端打开带右上角关闭按钮的 `LampsGameWebViewController`。

入参 `data`：

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `url` | string | 是 | 完整游戏页 `http(s)` URL |

```json
{ "url": "https://example.com/game?appid=xxx" }
```

有导航栈则 `push`，否则全屏 `present`。成功 `{ "msg": "" }`；`url` 非法或找不到宿主页面走 error 回调。

## 手动 Framework（xcframework）集成

### 出包

```bash
./scripts/build_xcframeworks.sh
# 产物：build/xcframeworks/LampsSDK-iOS-0.0.1/
```

产出 5 个包：`LampsSDK`（Core）+ 三家 Adapter + `LampsDevTools`，以及可选 `ThirdParty/`（补宿主缺失的广告 SDK）。

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
