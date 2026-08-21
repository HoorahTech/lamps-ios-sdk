#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 封装 GDTDevToolSDK。该库为预编译 .a 且无 module map，Swift 无法 `canImport` / `import`。
@interface LampsGDTDevToolBridge : NSObject

+ (BOOL)isAvailable;
+ (nullable UIViewController *)makeToolViewController;

@end

NS_ASSUME_NONNULL_END
