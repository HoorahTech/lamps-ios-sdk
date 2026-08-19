# Vendor / Noah

本目录为方案 B：将汇川（Noah）官方二进制随 `LampsSDK/Noah` 分发，**不依赖**私有 pod `NoahAdSdks`。

## 内容

- `NoahSDK.framework`（含 bundle）
- `Other/ATokenSDK.framework`
- `Other/UTDID.framework`

来源可从内部 `NoahAdSdks` 同步，或从汇川官方包整理后放入同名路径。

## 更新方式

```bash
# 示例：从本机已 pod 的 NoahAdSdks 同步
SRC=~/Documents/iOS/Pods/NoahAdSdks/NoahAdSdks
DST=LampsSDK/Vendor/Noah
rm -rf "$DST"
mkdir -p "$DST/Other"
cp -R "$SRC/NoahSDK.framework" "$DST/"
cp -R "$SRC/Other/"*.framework "$DST/Other/"
```

若后续官方包增加 `Ads/hc` 等目录，需同步拷入并在 `LampsSDK.podspec` 的 `Noah` Subspec 中补充 `vendored_frameworks` / `resources`。

## 接入说明

- 需要汇川且无自带 SDK：`pod 'LampsSDK/Noah'`
- 宿主已自带 `NoahSDK`：只用 `pod 'LampsSDK/NoahAdapter'`，**不要**再开 `Noah`，避免双份二进制
