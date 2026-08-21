# LampsSDK 手动 Framework（xcframework）集成说明

## 产物结构

```text
LampsSDK-iOS-x.y.z/
  LampsSDK.xcframework              # Core，必选
  Adapters/
    LampsCSJAdapter.xcframework
    LampsGDTAdapter.xcframework
    LampsNoahAdapter.xcframework
  DevTools/
    LampsDevTools.xcframework       # 可选调试页
  ThirdParty/                       # 仅补「宿主没有」的渠道
    Ads-CN/ ...
    GDTMobSDK/ ...
    Noah/ ...
  VERSIONS.txt
```

## 公共配置

1. 将需要的 `.xcframework` 拖入工程，勾选 **Embed & Sign**（静态库场景按团队惯例，至少保证 Link）
2. `Other Linker Flags` 增加 `-ObjC`（保证 Adapter 内 OC `+load` 注册生效）
3. Swift：`import LampsSDK`，入口 `Lamps.start(config:completion:)`
4. 需要激励时，再按渠道链接对应 Adapter 模块（`import LampsCSJAdapter` 等通常不必，注册靠 `+load`）
5. 需要调试页时，链 `DevTools/LampsDevTools.xcframework`，并保证宿主已有 `GDTDevToolSDK` / `BUAdTestMeasurement`（或 Debug 依赖）；入口 `LampsDevTools.present(from:)`

## 按渠道组合（无 / 全有 / 只有部分）

对每个渠道独立判断：

| 渠道需求 | 宿主已有该广告 SDK | 操作 |
| --- | --- | --- |
| 不需要 | — | 不链该 Adapter |
| 需要 | 是 | 只链 `Adapters/Lamps*Adapter.xcframework` |
| 需要 | 否 | 链 Adapter + `ThirdParty` 对应目录 |

### 示例 A：三家都没有，只要穿山甲 + 优量汇

- `LampsSDK.xcframework`
- `LampsCSJAdapter` + ThirdParty/Ads-CN
- `LampsGDTAdapter` + ThirdParty/GDTMobSDK

### 示例 B：已有穿山甲与优量汇，没有汇川

- `LampsSDK.xcframework`
- `LampsCSJAdapter`、`LampsGDTAdapter`（不拖 ThirdParty 里对应广告包）
- 若还要汇川：`LampsNoahAdapter` + ThirdParty/Noah

### 示例 C：三家都有

- `LampsSDK.xcframework` + 三个 Adapter，**不要**再拖 ThirdParty 广告包（避免双份）

## 与 CocoaPods Subspec 对照

| Pod | Framework |
| --- | --- |
| `LampsSDK/Core` | `LampsSDK.xcframework` |
| `LampsSDK/CSJAdapter` | `LampsCSJAdapter.xcframework`（宿主自备 BUAdSDK） |
| `LampsSDK/CSJ` | Adapter + ThirdParty/Ads-CN |
| `LampsSDK/GDTAdapter` | `LampsGDTAdapter.xcframework` |
| `LampsSDK/GDT` | Adapter + ThirdParty/GDTMobSDK |
| `LampsSDK/NoahAdapter` | `LampsNoahAdapter.xcframework`（宿主自备 Noah） |
| `LampsSDK/Noah` | Adapter + ThirdParty/Noah |
| `LampsSDK/DevTools` | `DevTools/LampsDevTools.xcframework`（另需调试依赖） |

## 注意

- Adapter 源码无条件 `import` 三方 SDK；`*Adapter` 场景须保证编译期能看到对应 module（post_install 挂路径，或改用 `CSJ`/`GDT`/`Noah`）。
- 预编译 Adapter 包在出包机上已编入广告调用，宿主运行时仍须提供对应广告 SDK（自有或 ThirdParty）。
- 宿主已有广告 SDK 时，主版本尽量与 `VERSIONS.txt` 中出包版本一致。
- 汇川：`Noah` 与 `NoahAdapter` 不要同时再拖两份 Noah 二进制。

## 出包命令

```bash
./scripts/build_xcframeworks.sh
# 产物目录：build/xcframeworks/
```
