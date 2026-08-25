#import <Foundation/Foundation.h>
#import <objc/message.h>

@interface LampsCSJRegister : NSObject
@end

@implementation LampsCSJRegister

static void LampsInvokeRegisterIfNeeded(NSString *className) {
    Class cls = NSClassFromString(className);
    SEL sel = NSSelectorFromString(@"registerIfNeeded");
    if (cls && [cls respondsToSelector:sel]) {
        ((void (*)(Class, SEL))objc_msgSend)(cls, sel);
    }
}

+ (void)load {
    // Registrar 为 internal，不会进入 *-Swift.h，这里按运行时类名调用。
    LampsInvokeRegisterIfNeeded(@"LampsCSJRewardAdapterRegistrar");
    LampsInvokeRegisterIfNeeded(@"LampsCSJSDKInitializerRegistrar");
}

@end
