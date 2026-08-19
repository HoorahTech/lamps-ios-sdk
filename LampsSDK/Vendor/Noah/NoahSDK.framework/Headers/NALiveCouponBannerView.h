//
//  NALiveCouponBannerView.h
//  NoahSDK
//
//  Created by chenlei on 2024/7/4.
//  Copyright © 2024 Alibaba Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

OBJC_EXTERN NSNotificationName NALiveCouponViewDidAppearNotification;

typedef void(^NAThemeChangeBlock)(BOOL isNightMode);
typedef void(^NAAdReadyShowBlock)(UIView *superview);

@protocol NALiveCouponProtocol <NSObject>
@optional
// UI
- (void)hiddenAllSubviewsForShowCoupon;
- (void)setNotifyAdFirstShowBlock:(NAAdReadyShowBlock)block;
// Theme
- (BOOL)isNightModeForCoupon;
- (void)setNotifyCouponThemeChangeBlock:(NAThemeChangeBlock)block;
@end

@class NALiveCouponInfo, NativeAd;

@interface NALiveCouponBannerView : UIView

- (instancetype)initWithFrame:(CGRect)frame couponInfo:(NALiveCouponInfo *)couponInfo;

/// 延迟展示优惠券视图
/// - Parameters:
///   - superView: 父视图，遵守NALiveCouponProtocol
///   - clickResponseView: 广告点击响应视图
///   - couponInfo: 优惠券信息
///   - ad: 广告信息
+ (void)delayShowOnView:(UIView/*<NALiveCouponProtocol>*/ *)superview
      clickResponseView:(UIView *)clickResponseView
             couponInfo:(NALiveCouponInfo *)couponInfo
                     ad:(NativeAd *)ad;

/// 功能总开关
+ (BOOL)couponEnable:(NSString *)slotKey;

@property (nonatomic, assign) BOOL isNightMode;

@end

NS_ASSUME_NONNULL_END
