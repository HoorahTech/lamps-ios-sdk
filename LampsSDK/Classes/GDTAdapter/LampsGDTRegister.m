#if __has_include("LampsGDTAdapter-Swift.h")
#import "LampsGDTAdapter-Swift.h"
#elif __has_include(<LampsGDTAdapter/LampsGDTAdapter-Swift.h>)
#import <LampsGDTAdapter/LampsGDTAdapter-Swift.h>
#elif __has_include("LampsSDK-Swift.h")
#import "LampsSDK-Swift.h"
#else
#import <LampsSDK/LampsSDK-Swift.h>
#endif

@interface LampsGDTRegister : NSObject
@end

@implementation LampsGDTRegister

+ (void)load {
    [LampsGDTRewardAdapterRegistrar registerIfNeeded];
    [LampsGDTSDKInitializerRegistrar registerIfNeeded];
}

@end
