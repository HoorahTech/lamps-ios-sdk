#if __has_include("LampsSDK-Swift.h")
#import "LampsSDK-Swift.h"
#else
#import <LampsSDK/LampsSDK-Swift.h>
#endif

@interface LampsNoahRegister : NSObject
@end

@implementation LampsNoahRegister

+ (void)load {
    [LampsNoahRewardAdapterRegistrar registerIfNeeded];
    [LampsNoahSDKInitializerRegistrar registerIfNeeded];
}

@end
