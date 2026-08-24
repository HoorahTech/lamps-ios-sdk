#import "LampsCSJTestMeasurementBridge.h"
#import <objc/message.h>

@implementation LampsCSJTestMeasurementBridge

+ (BOOL)isAvailable {
    return NSClassFromString(@"BUAdTestMeasurementConfiguration") != nil;
}

+ (void)enableDebugModeIfAvailable {
    Class cls = NSClassFromString(@"BUAdTestMeasurementConfiguration");
    if (cls == nil) {
        return;
    }
    id config = nil;
    SEL configurationSel = NSSelectorFromString(@"configuration");
    if ([cls respondsToSelector:configurationSel]) {
        config = ((id (*)(id, SEL))objc_msgSend)(cls, configurationSel);
    }
    if (config == nil) {
        config = [[cls alloc] init];
    }
    SEL setDebugSel = NSSelectorFromString(@"setDebugMode:");
    if ([config respondsToSelector:setDebugSel]) {
        ((void (*)(id, SEL, BOOL))objc_msgSend)(config, setDebugSel, YES);
    }
}

@end
