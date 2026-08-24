#import "LampsNoahDevToolBridge.h"

@implementation LampsNoahDevToolBridge

+ (BOOL)isAvailable {
    return NSClassFromString(@"NAAdExternalMockViewController") != nil;
}

+ (UIViewController *)makeToolViewController {
    Class cls = NSClassFromString(@"NAAdExternalMockViewController");
    if (cls == nil) {
        return nil;
    }
    return [[cls alloc] init];
}

@end
