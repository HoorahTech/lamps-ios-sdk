#import "LampsGDTDevToolBridge.h"

#if __has_include(<GDTDevToolSDK/GDTDevToolSDK.h>)
#import <GDTDevToolSDK/GDTDevToolSDK.h>
#define LAMPS_HAS_GDT_DEVTOOL 1
#elif __has_include("GDTDevToolSDK.h")
#import "GDTDevToolSDK.h"
#define LAMPS_HAS_GDT_DEVTOOL 1
#endif

@implementation LampsGDTDevToolBridge

+ (BOOL)isAvailable {
#if LAMPS_HAS_GDT_DEVTOOL
    return YES;
#else
    return NO;
#endif
}

+ (UIViewController *)makeToolViewController {
#if LAMPS_HAS_GDT_DEVTOOL
    return [GDTDevToolSDK ensureEnableToolVcInDebug:YES];
#else
    return nil;
#endif
}

@end
