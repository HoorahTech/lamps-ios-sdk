//
//  BaseNativeAd.h
//  NoahSDK
//
//  Created by zhongyang on 2020/11/3.
//  Copyright © 2020 Alibaba Inc. All rights reserved.
//

#import "NABaseAd.h"
#import "NASDKNativeTemplateDefines.h"
#import "NAVideoAdReporter.h"
#import "NAVideoInfoModel.h"

@protocol IVideoLifeCallback, NANativeViewDataSource, NANativeViewDelegate, NANativeViewProtocol;

NS_ASSUME_NONNULL_BEGIN

@protocol NANativeViewDataSource, NANativeViewDelegate, NANativeViewProtocol;

@interface NAAdActionConfig : NSObject

@property (nonatomic,assign) BOOL isSlidable;

@end

@interface BaseNativeAd : NABaseAd

/// 是否允许自定义播放器功能，若要开启请联系商务同学
@property (nonatomic, assign, readonly) BOOL allowCustomVideoPlayer;

/// 视频播放信息上报（适用于媒体自定义视频播放）
@property (nonatomic, strong, readonly, nullable) id<NAVideoAdReporter> videoAdReporter;

/// 媒体视图：单图 / 多图 / 视频
/// 视频广告，allowCustomVideoPlayer配置为YES，而且有获取到视频URL，则此mediaView将返回nil
- (nullable UIView *)getMediaView;

/// 获取视频信息（allowCustomVideoPlayer为NO，此参数一定返回nil；allowCustomVideoPlayer 为YES，此参数可能返回有值，返回有值，则媒体可以自定义播放器，同时，getMediaView将返回为空；如果此参数返回为空，则媒体可以继续调用getMediaView获取到mediaView使用）
- (nullable NAVideoInfoModel *)getVideoInfo;

/// 原生广告渲染类型
- (NANativeRenderType)nativeRenderType;

/// 原生模版广告 View，适用于渲染类型为：NANativeRenderSDK
/// @param dataSource 数据源
/// @param delegate 回调代理
- (UIView<NANativeViewProtocol> *)nativeAdViewWithDataSource:(nullable id<NANativeViewDataSource>)dataSource delegate:(nullable id<NANativeViewDelegate>)delegate;

/// 注册原生广告可点击视图
/// @param containerView 原生广告容器视图
/// @param clickableViews 可点击视图
- (void)registerContainer:(__kindof UIView *)containerView clickableViews:(NSArray<UIView *> *)clickableViews;

/// 注册原生广告交互行为
/// @param actionViews 可交互视图
/// @param config 交互行为配置，可通过 isSlidable 属性控制是否开启横划手势，默认不开启
- (void)registerActionViews:(NSArray<UIView *> *)actionViews withConfig:(NAAdActionConfig *)config;

/// 注销可点击视图
- (void)unregisterView;

@end

NS_ASSUME_NONNULL_END
