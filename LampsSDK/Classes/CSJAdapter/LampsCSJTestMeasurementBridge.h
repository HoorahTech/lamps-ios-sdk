#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 运行时打开穿山甲测试工具 debugMode。不链接 BUAdTestMeasurement 时为空操作，避免正式包链接失败。
@interface LampsCSJTestMeasurementBridge : NSObject

+ (BOOL)isAvailable;
+ (void)enableDebugModeIfAvailable;

@end

NS_ASSUME_NONNULL_END
