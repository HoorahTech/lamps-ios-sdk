# Binary xcframeworks

由 `./scripts/build_xcframeworks.sh` 同步到本目录，供根目录 `LampsSDK.podspec` 在 `use_binary = true` 时引用。

```text
LampsSDK/Binary/
  LampsSDK.xcframework
  LampsSDKResources.bundle
  Adapters/
    LampsCSJAdapter.xcframework
    LampsGDTAdapter.xcframework
    LampsNoahAdapter.xcframework
```

切换源码 / 二进制：改 `LampsSDK.podspec` 顶部的 `use_binary`，然后宿主 `pod install`。
