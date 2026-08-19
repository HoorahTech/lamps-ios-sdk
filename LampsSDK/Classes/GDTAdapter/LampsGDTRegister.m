#import <LampsSDK/LampsSDK-Swift.h>

@interface LampsGDTRegister : NSObject
@end

@implementation LampsGDTRegister

+ (void)load {
    [LampsGDTRewardAdapterRegistrar registerIfNeeded];
    [LampsGDTSDKInitializerRegistrar registerIfNeeded];
}

@end
