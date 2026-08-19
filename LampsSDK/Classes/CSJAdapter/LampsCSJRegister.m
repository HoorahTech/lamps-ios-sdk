#if __has_include("LampsSDK-Swift.h")
#import "LampsSDK-Swift.h"
#else
#import <LampsSDK/LampsSDK-Swift.h>
#endif

@interface LampsCSJRegister : NSObject
@end

@implementation LampsCSJRegister

+ (void)load {
    [LampsCSJRewardAdapterRegistrar registerIfNeeded];
    [LampsCSJSDKInitializerRegistrar registerIfNeeded];
}

@end
