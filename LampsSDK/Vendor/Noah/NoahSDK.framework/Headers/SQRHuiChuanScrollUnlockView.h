//
//  ScrollUnlockAnimView.h
//  ShuQiHCSDKSample
//
//  Created by 小瓜瓜 on 2021/9/27.
//  Copyright © 2021 ShuQi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SQRHuiChuanScrollUnlockView : UIView

// 此控件目前适用于 开屏，滑动解锁, 支持上滑或者左右滑
// frame 一般情况 width:屏幕宽度 height: 半屏180 全屏214
// isVertical 
// scrollDistance 滑动距离阈值
// isShowRedPackRain 是否有展示红包
// shakeOkBlock
// 摇一摇成功回调block 
- (instancetype)initWithFrame:(CGRect)frame
                   isVertical:(BOOL)isVertical
               scrollDistance:(float)scrollUnlockDistance
            isShowRedPackRain:(BOOL)isShowRedPackRain
                   clickBlock:(nullable void (^)(void))clickBlock
                unLockOkBlock:(void (^)(void))unLockOkBlock
                      extInfo:(nullable NSDictionary *)extInfo;

// 上滑+按钮，可用此函数
- (instancetype)initWithFrame:(CGRect)frame
                   isVertical:(BOOL)isVertical
               scrollDistance:(float)scrollUnlockDistance
            isShowRedPackRain:(BOOL)isShowRedPackRain
                   clickBlock:(nullable void (^)(void))clickBlock
                unLockOkBlock:(void (^)(void))unLockOkBlock
            isNeedClickBanner:(BOOL)isNeedClickBanner
             clickBannerTitle:(nullable NSString *)clickBannerTitle
             bannerClickBlock:(nullable void (^)(void))bannerClickBlock
                 isFullscreen:(BOOL)isFullscreen
             unlockAreaHeight:(CGFloat)unlockAreaHeight
                      extInfo:(nullable NSDictionary *)extInfo;

// 展示
-(void)addToView:(UIView *)parentView;

// 销毁
-(void)destory;

- (NSSet<UITouch *> *)getViewEndTouches;

@end

NS_ASSUME_NONNULL_END
