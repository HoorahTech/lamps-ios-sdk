//
//  SplashAd+Private.h
//  NoahSDK
//
//  Created by zzyong on 2025/7/18.
//  Copyright © 2025 Alibaba Inc. All rights reserved.
//

#ifndef SplashAd_Private_h
#define SplashAd_Private_h

#import "SplashAd.h"
#import "RequestInfo+Private.h"

@class SdkAdDetail;
@protocol NoahSplashAdListener, IAdPreloadListener;

typedef NS_ENUM(int, NAAdmWaType) {
    NAAdmWaUnknown,
    NAAdmWaShow,
    NAAdmWaClick
};

NS_ASSUME_NONNULL_BEGIN

@interface SplashAd ()

/// 跳过按钮，【注意】必须在 showSplashAdView 之前赋值
@property(nonatomic, strong, nullable) UIView *skipView;

/// 左上方自定义View，例如 App Logo，【注意】必须在 showSplashAdView 之前赋值
@property(nonatomic, strong, nullable) UIView *topLeftView;

/// 落地页跳转控制器，默认使用 adWindow.rootViewController【注意】必须在 showSplashAdView 之前赋值
@property(nonatomic, strong, nullable) UIViewController *rootViewController;

/// 广告展示 Window，【注意】非 showSplashAdView 方式展示广告时，请勿获取 adWindow，避免引起不必要的开销
@property(nonatomic, strong, readonly) UIWindow *adWindow;

/// 展示广告
- (void)showSplashAdView;

/// 移除广告
- (void)removeSplashAdView;

+ (BOOL)containAdmBusinessWithSlotKey:(NSString *)slotKey;

+ (int)shakeSwingTypeWithSlotKey:(NSString *)slotKey;

+ (void)reportAdmWaLog:(NSString *)slotKey type:(NAAdmWaType)type extraData:(nullable NSDictionary *)extraData;

+ (void)reportAppCustomLog:(NSString *)category action:(NSString *)action extraData:(nullable NSDictionary *)extraData;

@end

@interface SplashAd ()


/**
 *   加载广告
 */
+(void)getAdWithSlot:(NSString *)slotKey
            listener:(id<NoahSplashAdListener>)listener
          controller:(UIViewController *)controller;

+(void)getAdWithSlot:(NSString *)slotKey
            listener:(id<NoahSplashAdListener>)listener
          controller:(UIViewController *)controller
                stop:(BOOL *)stop;

+(void)getAdWithSlot:(NSString *)slotKey
            listener:(id<NoahSplashAdListener>)listener
          controller:(UIViewController *)controller
             timeout:(long)timeout;

+(void)getAdWithSlot:(NSString *)slotKey
            listener:(id<NoahSplashAdListener>)listener
          controller:(UIViewController *)controller
             timeout:(long)timeout
     useCustomRender:(BOOL)customRender;

+(nullable SplashAd*)getAdSyncWithSlot:(NSString *)slotKey
                     listener:(id<NoahSplashAdListener>)listener;

+(nullable SplashAd*)getCacheAdSyncWithSlot:(NSString *)slotKey
                          listener:(id<NoahSplashAdListener>)listener;

// slotKey 广告id，必填
// requestInfo 扩展字段，可为nil
// listener 代理，可为nil
// controller 展示容器，必填
// stop 取地址&stop，指针类型，外部控制是否可取消广告流程，可为nil，不需要控制
// timeout 超时控制，默认 -1L
// customRender 设置是否媒体端来： 1.控制开屏生命周期，包括关闭开屏广告； 2. 渲染跳过按钮，banner等； (目前只有穿山甲设置有效）（ 汇川，阿里妈妈 支持自渲染，但数据由noah后端控制)  默认NO
+(void)getAdWithSlot:(NSString *)slotKey
         requestInfo:(RequestInfo* _Nullable) requestInfo
            listener:(id<NoahSplashAdListener>)listener
          controller:(nullable UIViewController *)controller
                stop:(BOOL * _Nullable)stop
             timeout:(long)timeout
     useCustomRender:(BOOL)customRender;
/**
 *   预加载，加载时再调用 getAdWithSlot:listener:controller: 方法
 */
+(void)preloadAdWithSlot:(NSString *)slotKey listener:(id<IAdPreloadListener>) listener controller:(UIViewController *)controller;
// 汇川品牌&兜底，预加载 目前UC用的此方法 做汇川预加载广告，需要传入 RequestInfo
+(void)preloadAdWithSlot:(NSString *)slotKey requestInfo:(RequestInfo*)info  listener:(id<IAdPreloadListener>) listener controller:(UIViewController *)controller;
// 获取广告预估价值
+ (void)getAdEstPriceWithSlotKey:(NSString *)slotKey appKey:(NSString *)appKey elapsedTime:(CGFloat)elapsedTime completion:(void(^)(NSNumber * _Nullable estPrice, NAAdValueLevel adValueLevel))completion;
// wa上报预估价格事件
+ (void)statsSplashEstPriceReqEvent:(NSString *)slotKey appKey:(NSString *)appKey adGetValue:(NSNumber *)adGetValue loadTimeCfg:(NSString *)loadTimeCfg;
// 保存填充率数据
+ (void)saveSplashLoadedEvent:(NSString *)slotKey filled:(BOOL)filled;
+(void)preloadAdConfig:(NSString *)slotKey;


// 在onSplashAdLoaded 代理里面，window加载开屏之后，判断，如果需要自渲染，通过 getAdView视图给到媒体端去做自渲染
// 自渲染包括：跳过按钮，banner 等
// 自渲染媒体端接管的代理包括：
// 阿里妈妈： splashAdLifeTime  splashAdWillClosed  splashAdClosed  splashAdClickSkip
// 汇川： splashAdWillClosed  splashAdClosed  splashAdDidClickSkip  splashAdLifeTime
// 穿山甲：splashAdDidClose  splashAdWillClose splashAdDidClickSkip  splashAdCountdownToZero
// 目前只有 穿山甲，阿里妈妈，汇川支持 自渲染模式
-(BOOL)supportCustomRender;

-(UIView *)getAdView;

-(nullable UIView *)getTopView;

-(void)getFousView:(void(^)(UIView *view))block;

-(CGFloat)getTopViewDuration;

-(BOOL)isTopView;

-(CGFloat)getShowTime;

-(int)getLevelType;

-(void)dissmissSplashView;

-(SdkAdDetail*)getAdDetail;

-(NSString *)getAdnPlacementId;

- (NSDictionary *)getStatExtInfo;

- (BOOL)isUCMarketDefalutAD;  ///< 是否UC market默认广告（营销类型为内部推广/资源换入，排除监管类）

- (void)showSplashAdWithRootView:(UIViewController *)controller window:(nullable UIWindow *)window bottomView:(nullable UIView *)bottomView withTopView:(nullable UIView *)topView skipView:(nullable UIView *)skipView;

@end

NS_ASSUME_NONNULL_END

#endif /* SplashAd_Private_h */
