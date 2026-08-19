//
//  NASplashWindow.h
//  NoahSDK
//
//  Created by zzyong on 2022/10/31.
//  Copyright © 2022 Alibaba Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

// window tag
#define NA_SPLASH_WINDOW_TAG 10001

NS_ASSUME_NONNULL_BEGIN

@interface NASplashWindow : UIWindow

+ (NASplashWindow *)adWindow;

/// 重置 window，移除其标记位和广告相关 subview，主线程调用
+ (void)resetSplashWindow;

@end

NS_ASSUME_NONNULL_END
