import UIKit

/// 游戏 H5 容器：在 `LampsWebViewController` 之上增加悬浮菜单条（更多 + 关闭）。
/// 菜单可拖拽吸边，静止 3s 收成贴边半圆弧。Bridge、加载、导航栏隐藏与 `closePage()` 行为与父类一致。
@objcMembers
public final class LampsGameWebViewController: LampsWebViewController {
    private lazy var menuBar: LampsGameMenuBar = {
        let bar = LampsGameMenuBar()
        bar.onClose = { [weak self] in
            self?.closePage()
        }
        bar.onRestart = { [weak self] in
            self?.reloadPage()
        }
        return bar
    }()

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(menuBar)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        menuBar.relayoutForSuperviewBoundsChange()
    }
}
