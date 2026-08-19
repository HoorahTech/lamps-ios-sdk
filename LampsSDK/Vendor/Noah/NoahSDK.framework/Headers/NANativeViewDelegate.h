//
//  NANativeViewDelegate.h
//  NoahSDK
//
//  Created by zzyong on 2021/12/30.
//  Copyright © 2021 Alibaba Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NANativeViewProtocol;

@protocol NANativeViewDelegate <NSObject>

@optional

/// 关闭按钮点击
- (void)nativeAdViewDidClickCloseButton:(id<NANativeViewProtocol>)adView;

/// 播放结束回调 注：视频取视频播放结束为时机 图片使用配置的倒计时 默认：30s
- (void)nativeAdViewPlayFinish:(id<NANativeViewProtocol>)adView;

@end

NS_ASSUME_NONNULL_END
