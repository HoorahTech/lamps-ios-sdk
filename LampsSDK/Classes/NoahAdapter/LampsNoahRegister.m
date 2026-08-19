#if __has_include("LampsNoahAdapter-Swift.h")
#import "LampsNoahAdapter-Swift.h"
#elif __has_include(<LampsNoahAdapter/LampsNoahAdapter-Swift.h>)
#import <LampsNoahAdapter/LampsNoahAdapter-Swift.h>
#elif __has_include("LampsSDK-Swift.h")
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
