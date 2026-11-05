#import <Foundation/Foundation.h>
#import <objc/message.h>

@interface LampsAlipayRegister : NSObject
@end

@implementation LampsAlipayRegister

+ (void)load {
    // Registrar 为 internal，不会进入 *-Swift.h，这里按运行时类名调用。
    Class cls = NSClassFromString(@"LampsAlipayPayRegistrar");
    SEL sel = NSSelectorFromString(@"registerIfNeeded");
    if (cls && [cls respondsToSelector:sel]) {
        ((void (*)(Class, SEL))objc_msgSend)(cls, sel);
    }
}

@end
