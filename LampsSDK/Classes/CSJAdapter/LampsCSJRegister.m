#import <LampsSDK/LampsSDK-Swift.h>

@interface LampsCSJRegister : NSObject
@end

@implementation LampsCSJRegister

+ (void)load {
    [LampsCSJRewardAdapterRegistrar registerIfNeeded];
    [LampsCSJSDKInitializerRegistrar registerIfNeeded];
}

@end
