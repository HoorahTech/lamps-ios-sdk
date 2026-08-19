#if __has_include("LampsCSJAdapter-Swift.h")
#import "LampsCSJAdapter-Swift.h"
#elif __has_include(<LampsCSJAdapter/LampsCSJAdapter-Swift.h>)
#import <LampsCSJAdapter/LampsCSJAdapter-Swift.h>
#elif __has_include("LampsSDK-Swift.h")
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
