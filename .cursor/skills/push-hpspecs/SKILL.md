---
name: push-hpspecs
description: 给 LampsSDK 打 git tag，并 pod repo push 到虎扑中心仓 HPSpecs。用于用户提到「打 tag」「推中心仓」「HPSpecs」「pod repo push」「发布 LampsSDK 版本」时。
---

# 打 tag 并推送到虎扑中心仓

在 **lamps-ios-sdk** 仓库执行。中心仓只收 podspec；代码从源码仓 git tag 拉取。

**顺序必须是：确认/改版本号并提交推远程 → 打 tag 并推 tag → 再 push spec。** 没有远程 tag 时 lint/安装会失败。

## 要不要先改版本号

`s.version`、git tag、HPSpecs 目录三者必须相同，且 **一个版本只能发一次**。

| 情况 | 要不要改版本号 |
| --- | --- |
| 这个 `s.version` 远程 **还没有** 同名 tag，HPSpecs 也没有 | **不用改**，用 spec 里现有版本发 |
| HPSpecs **已有** 该版本 | **立刻停止**，告知用户已发过，不要 push、不要改 spec 覆盖。要发新内容请用户先升版本 |
| 远程 **已有** 同名 tag，HPSpecs 还没有 | 告知「tag 已存在」。用户只要补推中心仓 → 跳过打 tag，只 `pod repo push`；用户要发 **新提交** → 停止，请用户先升版本 |
| 用户已改好新版本并提交 | 按新 `s.version` 继续打 tag + push |

升版本时同步改这些地方（保持一致）：

- `LampsSDK.podspec` 的 `s.version`
- `Lamps.sdkVersion`（`LampsSDK/Classes/Public/Lamps.swift`）
- 同仓库独立 spec：`LampsDevTools.podspec`、`LampsCSJAdapter.podspec`、`LampsGDTAdapter.podspec`、`LampsNoahAdapter.podspec`（若本次也发它们）

改完后 **先 commit 并 `git push origin`**，再打 tag。未提交的版本号不要打 tag。

## 常量

| 项 | 值 |
| --- | --- |
| 源码仓 | `git@gitlab.hupu.com:HPBase/lamps-ios-sdk.git` |
| 中心仓 URL | `http://gitlab.hupu.com/iOSClient/HPSpecs.git` |
| 本机仓名 | `hupu-iosclient-hpspecs`（`pod repo push` 用这个，**不要传 URL**） |
| 主 spec | 仓库根目录 `LampsSDK.podspec` |

`--sources` 是 lint 找依赖的源，不是推送目标。`Ads-CN`、`GDTMobSDK` 不在 HPSpecs，必须带公有源。

本机 CocoaPods 仓名用 `pod repo list` 核对（需 `export CP_HOME_DIR=/Users/$(whoami)/.cocoapods`）。若本地名不是 `hupu-iosclient-hpspecs`，以 list 为准。

## 执行前确认

1. 先查是否已发过（必须做，命中则停止并告诉用户，**不要自行改版本号继续发**）：

```bash
VERSION="$(ruby -e 'puts File.read("LampsSDK.podspec")[/s\.version\s*=\s*['\''"]([^'\''"]+)/, 1]')"
git ls-remote --tags origin "refs/tags/${VERSION}"
ls "${CP_HOME_DIR:-$HOME/.cocoapods}/repos/hupu-iosclient-hpspecs/LampsSDK/${VERSION}" 2>/dev/null || true
```

   - HPSpecs 已有 `LampsSDK/<version>/` → **停止**，回复：`LampsSDK <version> 已在中心仓，不能重复发布。请先改版本号再执行。`
   - 远程已有同名 tag，且本次不是「只补推 spec」→ **停止**，回复：`源码仓已有 tag <version>，不能重打。要发新内容请先升版本。`
2. 工作区干净，当前分支已推到 `origin`（默认 `main`）。
3. 读 `LampsSDK.podspec`：`s.version`、`s.source` 的 `:tag`、`use_binary`。
4. 用户未给出版本时，用 spec 里的 `s.version`，并在动手前复述一遍（含 `use_binary` true/false）。这一版会冻死，接入方不能在 Podfile 里切源码/二进制。
5. 同名 tag 已存在则 **不要重打、不要 force push**。
6. `use_binary = true` 时确认 `LampsSDK/Binary/*.xcframework` 已进 git。

默认只发 `LampsSDK.podspec`。`LampsDevTools` / `Lamps*Adapter` 独立 spec 仅在用户明确要求时再发。

## 步骤

环境变量每次命令都带上（Cursor 沙箱会改 `CP_HOME_DIR`）：

```bash
export LANG=en_US.UTF-8
export CP_HOME_DIR="${HOME}/.cocoapods"
```

需要 git tag 推送、访问 GitLab、`pod repo push` 时用完整权限（网络 + git_write / `all`）。

### 1. 打 tag 并推源码仓

版本号 = `LampsSDK.podspec` 的 `s.version`（下例为 `VERSION`）。

```bash
cd "<lamps-ios-sdk 根目录>"
git tag -a "$VERSION" -m "LampsSDK $VERSION"
git push origin "$VERSION"
git ls-remote --tags origin "$VERSION"
```

tag 必须指向已推送的 commit。`s.source` 是 `:tag => s.version.to_s`。

### 2. 校验 spec（可在 push 前单独跑）

```bash
pod spec lint LampsSDK.podspec \
  --allow-warnings \
  --skip-import-validation \
  --sources='http://gitlab.hupu.com/iOSClient/HPSpecs.git,https://cdn.cocoapods.org,https://github.com/volcengine/volcengine-specs.git'
```

### 3. 推到 HPSpecs

```bash
pod repo push hupu-iosclient-hpspecs LampsSDK.podspec \
  --allow-warnings \
  --skip-import-validation \
  --no-overwrite \
  --commit-message="Add LampsSDK ${VERSION}" \
  --sources='http://gitlab.hupu.com/iOSClient/HPSpecs.git,https://cdn.cocoapods.org,https://github.com/volcengine/volcengine-specs.git'
```

成功后中心仓路径：`LampsSDK/<version>/LampsSDK.podspec`。

### 4. 告诉用户如何接入

```ruby
source 'http://gitlab.hupu.com/iOSClient/HPSpecs.git'

pod 'LampsSDK', '<version>', :subspecs => [
  'Core', 'CSJAdapter', 'GDTAdapter', 'NoahAdapter', 'DevTools'
]
```

然后 `pod repo update hupu-iosclient-hpspecs` 或 `pod install --repo-update`。

默认 subspec 是 `Core + CSJ + GDT + Noah`，会再拉穿山甲/优量汇/汇川。主工程应显式写 `*Adapter`。

## 禁止

- 不要 `git push --force` tag 或覆盖已发布的同一版本 spec。
- 不要把中心仓 URL 当作 `pod repo push` 的第一个参数。
- 不要只用 `--sources='http://gitlab.hupu.com/iOSClient/HPSpecs.git'`（找不到 `Ads-CN/BUAdSDK`）。
- 未得到用户明确版本/未确认 `use_binary` 时不要打 tag。
- 不要改 `git config`。

## 常见失败

| 现象 | 原因 | 处理 |
| --- | --- | --- |
| `Unable to find the 'hupu-iosclient-hpspecs' repo` | `CP_HOME_DIR` 指到沙箱 | 导出本机 `~/.cocoapods` 后再 list/push |
| `The specification does not validate` + `Ads-CN/BUAdSDK` | `--sources` 只有 HPSpecs | 补上 cdn + volcengine-specs |
| `Unable to find a specification for ...` 其它公有库 | 同上 | 同上 |
| lint 拉不到源码 | 远程没有对应 tag | 先 `git push origin <tag>` |
| `Git SSH URLs will NOT work...` | `s.source` 用了 git@ | 警告可忽略（`--allow-warnings`） |

| `[!] ... already present` / overwrite 被拒绝 | 中心仓已有该版本 | 停止告知用户，升版本后再发 |

`pod repo push` 可能要数分钟（会再 lint）。被中断后先看 HPSpecs 是否已有该版本目录，有则停止告知，不要重复 push。
