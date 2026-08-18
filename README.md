# LampsSDK

面向三方 App 的 iOS SDK：WebView + Bridge、激励视频、CM/PM/XM 监测上报。

当前仓库：`git@gitlab.hupu.com:HPBase/lamps-ios-sdk.git`

实现语言以 **Swift** 为主。公开 API 带 `@objc`，ObjC 宿主仍可调用。

## 分阶段

| 阶段 | 内容 | 状态 |
| --- | --- | --- |
| 1 | 工程骨架、对外入口、Demo | 进行中 |
| 2 | WKWebView 展示 | 未开始 |
| 3 | Bridge 通信 | 未开始 |
| 4 | CM / PM / XM 上报 | 未开始 |
| 5 | 激励视频框架（不含三方广告 SDK 二进制） | 未开始 |
| 6 | 穿山甲 / 优量汇 / 汇川 Adapter（宿主已有则复用） | 未开始 |
| 7 | xcframework 手动集成出包 | 未开始 |

## 安装

```ruby
pod 'LampsSDK', :git => 'git@gitlab.hupu.com:HPBase/lamps-ios-sdk.git', :branch => 'main'
```

本地 Demo：

```bash
cd Example
pod install
open LampsSDK.xcworkspace
```

## 第一阶段用法

```swift
import LampsSDK

let config = LampsSDKConfig()
config.appId = "your-app-id"
config.debugLogEnabled = true
LampsSDK.start(config: config) { success, error in
    if !success {
        print(error?.localizedDescription ?? "")
    }
}
```

WebView / 激励视频 / 上报目前只有占位 API，调用后不会真正加载页面或广告。
