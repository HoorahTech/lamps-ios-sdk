//
//  BaseNativeAd+Private.h
//  NoahSDK
//
//  Created by zzyong on 2025/7/18.
//  Copyright © 2025 Alibaba Inc. All rights reserved.
//

#ifndef BaseNativeAd_Private_h
#define BaseNativeAd_Private_h

#import "SdkAssets.h"
#import "BaseNativeAd.h"
#import "BaseNativeAdView.h"

typedef NS_ENUM(int, NANativeAdClickType) {
    NANativeAdClickNormal      = 1, ///< 用户正常点击
    NANativeAdClickHorizontal  = 2, ///< 横滑
    NANativeAdClickExtendArea  = 3, ///< 扩展区域
    NANativeAdClickShake       = 4, ///< 摇一摇
};

@protocol IVideoLifeCallback;

NS_ASSUME_NONNULL_BEGIN

@interface BaseNativeAd ()

///【注意】onNativeAdClick 点击回调之后会自动重置点击类型：NANativeAdClickNormal
@property (nonatomic, assign) NANativeAdClickType clickType;

/// 广告是否有效，适用非标广告位
@property (nonatomic, assign, readonly) BOOL isValid;

/// 广告展示时间，值为【 -1 】时使用媒体侧展示时间
@property (nonatomic, assign, readonly) NSTimeInterval showTime;

@property (nonatomic, strong, nullable) NSArray<BaseNativeAd *> *subNativeAds;

@property (nonatomic, assign) NSUInteger groupTemplateAdPosition;

/// 更新媒体视图：单图 / 多图 / 视频 frame
- (void)updateMediaViewFrame:(CGRect)frame;

/// 获取信息流模版Id
- (NSString *)getRepeatAdTemplateId;

/// 是否是重复广告
- (BOOL)isRepeatAd;

/// 获取 ADN 广告容器，有的三方广告一定使用其内部类作为自渲染的基础容器，如果 nil 则表示可以使用任意 UIView
/// 如果不为 nil，则必须要用返回的视图作为自渲染广告的基础容器！！！！！
- (nullable UIView *)nativeAdContainerView;

/// 上报自定义广告曝光事件，适用非标广告位
- (void)recordCustomImpression;

- (void)triggerShowAd;
- (void)triggerClickAd;

/// 原生广告展示，兼容三方广告的状态刷新，
/// 例如：百度视频需要在展示的时候重新播放、广告曝光的检测
- (void)adDidAppear;

- (nullable void(^)(void))getMediaPlayBlock;
- (nullable void(^)(void))getMediaPauseBlock;
- (nullable void(^)(void))getMediaResumeBlock;
- (nullable void(^)(void))getMediaAutoResumeBlock;
- (nullable void(^)(BOOL isMute))getMediaMuteBlock;

- (nullable NSString *)getHcSecondHighestPrice;

- (BOOL)gdtRegisterViewFixEnable;

@end

@class NALiveInfo;

@interface BaseNativeAd ()

/// 直播信息
@property (nonatomic, strong, readonly, nullable) NALiveInfo *liveInfo;
/// 广告类型
@property (nonatomic, assign, readonly) NAAdCreateType adCreateType;

@end

@interface BaseNativeAd ()

-(SdkAssets *)getAdAssets;
-(void)setVideoLifeDelegate:(id<IVideoLifeCallback>) delegate;
-(void)registerViewForInteractionWithController:(UIViewController *)controller  nativeView:(BaseNativeAdView *)nativeView clickable:(NSArray<UIView *> *)clickable;

@end

NS_ASSUME_NONNULL_END


#endif /* BaseNativeAd_Private_h */
