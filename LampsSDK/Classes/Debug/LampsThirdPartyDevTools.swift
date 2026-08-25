import UIKit

/// 运行时打开优量汇调试页。GDTDevToolSDK 无 module map，不能 `import`。
enum LampsGDTDevTool {
    static var isAvailable: Bool {
        NSClassFromString("GDTDevToolSDK") != nil
    }

    static func makeToolViewController() -> UIViewController? {
        guard let cls = NSClassFromString("GDTDevToolSDK") else { return nil }
        let meta = cls as AnyObject
        let sel = NSSelectorFromString("ensureEnableToolVcInDebug:")
        guard meta.responds(to: sel) else { return nil }
        typealias Maker = @convention(c) (AnyObject, Selector, Bool) -> UIViewController?
        return unsafeBitCast(meta.method(for: sel), to: Maker.self)(meta, sel, true)
    }
}

/// 运行时打开汇川调试页。DevTools 不编译依赖 NoahSDK。
enum LampsNoahDevTool {
    static var isAvailable: Bool {
        NSClassFromString("NAAdExternalMockViewController") != nil
    }

    static func makeToolViewController() -> UIViewController? {
        guard let cls = NSClassFromString("NAAdExternalMockViewController") as? UIViewController.Type else {
            return nil
        }
        return cls.init()
    }
}
