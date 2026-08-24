#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 运行时检测汇川调试页。DevTools 不依赖 NoahSDK，避免出包时 `canImport` 被写死成「未集成」。
@interface LampsNoahDevToolBridge : NSObject

+ (BOOL)isAvailable;
+ (nullable UIViewController *)makeToolViewController;

@end

NS_ASSUME_NONNULL_END
