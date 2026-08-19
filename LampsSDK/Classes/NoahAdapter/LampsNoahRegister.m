#import <LampsSDK/LampsSDK-Swift.h>

@interface LampsNoahRegister : NSObject
@end

@implementation LampsNoahRegister

+ (void)load {
    [LampsNoahRewardAdapterRegistrar registerIfNeeded];
    [LampsNoahSDKInitializerRegistrar registerIfNeeded];
}

@end
