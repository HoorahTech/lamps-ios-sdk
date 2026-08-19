//
//  NativeAd+Private.h
//  NoahSDK
//
//  Created by zzyong on 2025/7/18.
//  Copyright © 2025 Alibaba Inc. All rights reserved.
//

#ifndef NativeAd_Private_h
#define NativeAd_Private_h

#import "NativeAd.h"
#import "NoahCustomParamsKey.h"

@protocol NoahSdkNativeListener, IAdPreloadListener;
@class RequestInfo, AdAdapter;

NS_ASSUME_NONNULL_BEGIN

@interface NativeAd ()

// 设置视频广告自动播放模式
@property (nonatomic, assign) NAVideoAutoPlayPolicy autoPlayPolicy;

/// 是否开启title、Desc中的长文案放上面
@property (nonatomic, assign, readonly) BOOL enableLongTextAbove;

/// 是否开启文案跑马灯
@property (nonatomic, assign, readonly) BOOL enableTextMarquee;

/// 该广告是否可以滑动互动
@property (nonatomic, assign, readonly) BOOL isSliderControlEnable;

/// 该广告iflow中是否可以滑动互动
@property (nonatomic, assign) BOOL isIflowSliderControlEnable;

/// 该广告是否可以展示礼盒样式
@property (nonatomic, assign, readonly) BOOL isGiftShowEnable;

/// 礼盒样式是否使用规则引擎结果
@property (nonatomic, assign, readonly) BOOL isGiftShowUseRuleEngine;

/// 该广告iflow中是否可以展示礼盒样式
@property (nonatomic, assign) BOOL isIflowGiftControlEnable;

/// 该广告是否开启视频循环播放
@property (nonatomic, assign, readonly) BOOL isVideoPlayLoopEnable;

- (instancetype)initWithAd:(AdAdapter *)ad delegate:(id<NoahSdkNativeListener>)delegate;
/**
 *   加载广告
 */
+(void)getAdWithSlot:(NSString *)slotKey requestInfo:(RequestInfo* _Nullable) requestInfo  listener:(id<NoahSdkNativeListener>)delegate controller:(nullable UIViewController *)controller;

+(void)getAdWithSlot:(NSString *)slotKey listener:(id<NoahSdkNativeListener>)delegate controller:(UIViewController *)controller;

+(void)preloadAdWithSlot:(NSString *)slotKey requestInfo:(RequestInfo*)info  listener:(id<IAdPreloadListener>)listener controller:(UIViewController * _Nullable)controller;

/**
 *   广告是否加载完成
 */
+(BOOL)isReady:(NSString *)slotKey;

// 获取某次请求返回的 RequestInfo
-(RequestInfo *)getRequestInfo;

/// 停止对应的广告流程，并立即获取到已经请求到的广告
/// 必现UI主线程调用，否则会有异常！！！
+ (nullable NSMutableArray<NativeAd*>*)getAdByAbortRequestWithSlot:(NSString *)slotKey requestInfo:(RequestInfo *)requestInfo listener:(id<NoahSdkNativeListener>)delegate;

+ (nullable NSMutableArray<NativeAd*>*)getAdByAbortRequestWithSlot:(NSString *)slotKey requestInfo:(RequestInfo *)requestInfo listener:(id<NoahSdkNativeListener>)delegate filterArr:(NSMutableArray*)filterArr;

/// 该广告iflow中是否可以"摇一摇"
- (void)setIsIflowShakeEnable:(BOOL)isIflowShakeEnable;

+ (void)statCustomWaEvent:(NSString *)category action:(NSString *)action data:(NSDictionary *)data;

- (void)addExtraStatParams:(NSDictionary *)extParams;

- (void)setClickArea:(NANativeAdClickArea)clickArea;

- (nullable NSNumber *)nfVerticalAdStyle;

- (nullable NSNumber *)ruleVideoAutoPlayPolicy;  // 规则引擎视频自动播放配置

- (void)queryAdReward;

@end

@interface NativeAd ()  // ExtendTouchArea

/// 是否开启横滑点击，默认NO
- (BOOL)enableSlidClick;

/// 是否开启扩展区域点击，默认NO
- (BOOL)enableExtendClick;

- (BOOL)enableQWenTag;
- (NSArray<NSString *> *)qwenTagList;

/// 获取扩展区域高度
- (CGFloat)extendTouchAreaHeight;

/// 获取横滑点击命中规则
- (NSDictionary *)slidClickCondition;

/// 获取扩展区域点击命中规则
- (NSDictionary *)extendClickCondition;

/// 触发扩展区域UI事件
/// - Parameter eventInfo: 事件信息
- (void)triggerExtendTouchAdEvent:(nullable NSDictionary *)eventInfo;

/// 统计扩展区域touch事件响应失败
/// - Parameter eventInfo: 事件信息,  { @"e_code" : 错误码 }
- (void)statExtendTouchEventFail:(NSDictionary *)info;

/// 横滑响应
/// - Parameter resultBlock: 结果回调
/// handleEnable: 是否可以处理
/// callToAction: handleEnable  YES 时返回横滑响应处理 Action，NO 返回 nil
- (void)handleHorizontalSlidingAction:(void(^)(BOOL handleEnable, void(^ __nullable callToAction)(NSDictionary * __nullable callInfo)))resultBlock;

/// 额外区域点击
/// - Parameter 媒体端传入手势
+ (BOOL)triggerExtraTouchAdGesture:(nullable UIGestureRecognizer *)ges;

@end

NS_ASSUME_NONNULL_END

#endif /* NativeAd_Private_h */
