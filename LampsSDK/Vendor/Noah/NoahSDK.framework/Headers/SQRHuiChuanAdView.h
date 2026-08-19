//
//  SQRHuiChuanAdView.h
//  ShuQiHCSDK
//
//  Created by ZhouPanpan on 2020/5/28.
//  Copyright © 2020 ShuQi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HCNoahDataProtocol.h"

NS_ASSUME_NONNULL_BEGIN
extern const int SQRHuiChuanAutoPlayConfigNO;
extern const int SQRHuiChuanAutoPlayConfigWIFI;
extern const int SQRHuiChuanAutoPlayConfigNET;
#define HCViewVisibleCheckDefaultInterval 300
/// 汇川广告控件
@class SQRHuiChuanResponseModel;
@class SQRHuiChuanResponseAdModel;
@protocol SQRHuiChuanAdViewDelegate;
@interface SQRHuiChuanAdView : UIView

/// 设计播放器渲染，必填
@property (nonatomic,assign)CGFloat adWidth;

/// 用于竞价的价格 单位：分   默认值 -1
@property (nonatomic,assign,readonly)double price;

/// 是否需要将视频转换为图片，仅适用于 NoahSDK 原生 banner 广告。由于之前的架构设计原因，该属性是为了解决播放器的创建和第一次点击无法跳转的问题（视频第一次点击是走播放视频逻辑）
@property (nonatomic,assign)BOOL isNeedVideoToImage;

/// 是否需要自定义上报广告曝光事件，适用非标广告位
@property (nonatomic, assign) BOOL customImpressionEnable;


@property (nonatomic, assign) BOOL enablePlayControl;

/// 跳转的 ctrl
@property (nonatomic,weak)UIViewController *presentCtrl;
@property (nonatomic,assign)BOOL mute;
@property (nonatomic,assign)int autoPlayConfig;
@property (nonatomic,weak)id<SQRHuiChuanAdViewDelegate> delegate;
@property (nonatomic,weak)id<HCNoahDataProtocol> noahDataDelegate;
@property (nonatomic,assign)BOOL isReplayFix;

/// 是否需要在show打点时，检查view是否可见，默认为NO（此参数，需要在将SQRHuiChuanAdView对象添加到superView之前设置）
@property (nonatomic,assign)BOOL isNeedCheckViewVisible;

/// View可见判断，是否需要判断露出的面积（50%），默认为YES。特别注意，此参数使用的前置条件是isNeedCheckViewVisible为YES（此参数，需要在将SQRHuiChuanAdView对象添加到superView之前设置）
@property (nonatomic,assign)BOOL showIsNeedCheckVisibleArea;

/// 汇川广告是否可见检查间隔，单位为毫秒，代码中默认为300ms。不配置，或者当配置<=10毫秒时，也是走默认值300毫秒（此参数，需要在将SQRHuiChuanAdView对象添加到superView之前设置）
@property (nonatomic,assign)int viewVisibleCheckInterval;

///是否回调媒体端打开落地页
@property (nonatomic,assign)BOOL isCallBackAppOpenTUrl;

@property (nonatomic,assign)CGSize mediaSize;

@property (nonatomic,assign)BOOL forbidVideoPlay;//是否禁止视频播放（媒体侧自定义播放器的需要设置为YES，禁止后，汇川SDK内部不会创建视频播放器）, YES:禁止,NO:不禁止，默认：NO

/// 蹊径打点 查询slotKey
@property (nonatomic, copy) NSString *slotKey;
/// 是否禁止调端失败后的降级处理（打开落地页/AppStore），默认 NO（不禁止）
@property (nonatomic, assign) BOOL disableSchemeFailFallback;

@property (nonatomic, assign) BOOL playNeedVisible;

@property (nonatomic, assign) BOOL isShowing;

@property (nonatomic, assign) BOOL isAppControlPlay;

@property (nonatomic, assign) BOOL enableLoadSubThread;

@property (nonatomic, assign) BOOL forbidVideoAutoRepeatPlay;//是否禁止视频自动重播，默认：NO
@property (nonatomic, assign) BOOL forbidVideoClickToJump;//是否禁止视频点击响应跳转，默认：NO

/// 上报自定义广告曝光事件，适用非标广告位
- (void)recordCustomImpression;

/// 上报自定义广告点击事件
- (void)recordCustomClick;

/// 触发广告点击响应
- (void)click;

// 绑定responseModel
/// @param responseModel 返回数据
- (void)bindResponseModel:(SQRHuiChuanResponseModel *)responseModel;

// 绑定AdModel
/// @param adModel 物料
- (void)bindAdModel:(SQRHuiChuanResponseAdModel *)adModel;
/// 刷新并展示 AdView
/// @param adModel 物料
- (void)refreshAndShowAdView:(SQRHuiChuanResponseAdModel *)adModel;
/// 是否为横版物料 NO:竖版物料
/// @param admodel 资源
+ (BOOL)isVerticalMaterial:(SQRHuiChuanResponseAdModel *)admodel;
/// 横版物料下，依据宽度获取合适的高度
/// @param width 宽度
/// @param admodel 物料
+ (CGFloat)height4Width:(CGFloat)width adModel:(SQRHuiChuanResponseAdModel *)admodel;
/// 竖版物料下，依据高度获取合适的宽度
/// @param height 宽度
/// @param admodel 物料
+ (CGFloat)width4Height:(CGFloat)height adModel:(SQRHuiChuanResponseAdModel *)admodel;

/// 取消检查View是否可见的定时器
- (void)cancelViewVisibleCheckTimer;

/// 获取点击类型
/// @return 点击类型值，用于区分不同的点击交互方式
- (int)getClickType;

#pragma mark -- 关联点击视图设置

/// 注册一个 UI，使之响应本视图的点击事件
/// @param view 链接视图
- (void)registLinkedView:(__kindof UIView *)view;

/// 注册一个 UI，使之响应本视图的滑动手势事件
/// @param view 需要添加滑动手势的视图
- (void)registActionView:(__kindof UIView *)view;

/// 取消注册链接视图
/// @param view 视图
- (void)unRegistLinkedView:(__kindof UIView *)view;

/// 取消所有关联的视图集合
- (void)unRegistAllLinkedViews;
@end

typedef NS_ENUM(NSUInteger, HCVideoPlayerStatus) {
    HCVideoPlayerInit    = 0, ///< 初始状态
    HCVideoPlayerStart   = 1, ///< 开始播放
    HCVideoPlayerFinish  = 2, ///< 播放结束
    HCVideoPlayerResume  = 3, ///< 继续播放
    HCVideoPlayerPause   = 4, ///< 播放暂停
};

@protocol SQRHuiChuanAdViewDelegate <NSObject>
@optional

/// 加载完成 可addsubview 展示
/// @param adView ui
/// @param adModel model
- (void)adView:(SQRHuiChuanAdView *)adView load4Model:(SQRHuiChuanResponseAdModel *)adModel;

/// 展示
/// @param adView ui
/// @param adModel model
- (void)adView:(SQRHuiChuanAdView *)adView show4Model:(SQRHuiChuanResponseAdModel *)adModel;

/// 点击事件
/// @param adView ui
/// @param adModel model
- (void)adView:(SQRHuiChuanAdView *)adView clicked4Model:(SQRHuiChuanResponseAdModel *)adModel;

/// 调端事件
- (void)onNativeAdCalledApp:(NSDictionary *)dic;

/// 视频状态
- (void)hcAdView:(SQRHuiChuanAdView *)adView videoStatusDidChange:(HCVideoPlayerStatus)status;

/// 视频播放进度
- (void)hcAdView:(SQRHuiChuanAdView *)adView currentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime;

#pragma mark - 行为激励回调（点淘适配）

/// 6、外部跳转回调（跳转到其他 App）
- (void)hcAdViewDidJumpToExternalApp:(SQRHuiChuanAdView *)adView;

/// 7、从外部跳转返回回调
- (void)hcAdViewDidReturnFromExternalAppJump:(SQRHuiChuanAdView *)adView;

/// 8、进入 H5 落地页回调
- (void)hcAdViewDidEnterLandingPage:(SQRHuiChuanAdView *)adView;

/// 9、从 H5 落地页返回回调
- (void)hcAdViewDidReturnFromLandingPage:(SQRHuiChuanAdView *)adView;

/// 10、进入 AppStore 半屏详情回调
- (void)hcAdViewDidEnterAppStore:(SQRHuiChuanAdView *)adView;

/// 11、从 AppStore 半屏详情返回回调
- (void)hcAdViewDidLeaveAppStorePage:(SQRHuiChuanAdView *)adView;

@end
@interface SQRHuiChuanAdView (SQRDeprecated)
/// 刷新 AdView，但不负责展示图片类物料
/// @param adModel 物料
- (void)refreshAdView:(SQRHuiChuanResponseAdModel *)adModel  __attribute__((deprecated("历史原因使用，新建需求不推荐使用")));

- (UIView *)imageView __attribute__((deprecated("UC 历史原因使用，其它场景不推荐使用")));
- (UIView *)videoView __attribute__((deprecated("UC 历史原因使用，其它场景不推荐使用")));
@end

@interface SQRHuiChuanAdView (HCVideoReport)

/// 视频将要开始时上报此事件
- (void)willStartVideo;

/// 视频开始播放时上报此事件，duration为视频时长，单位毫秒
- (void)didStartVideoWithVideoDuration:(NSTimeInterval)duration;

/// 视频暂停时上报此事件，duration为视频暂停时视频已播放的时长，单位毫秒
- (void)didPauseVideoWithCurrentDuration:(NSTimeInterval)duration;

/// 视频播放完成时上报此事件，duration为视频播放完成时视频已播放的时长，单位毫秒
- (void)didFinishVideoWithCurrentDuration:(NSTimeInterval)duration;

/// 视频续播时上报此事件，duration为视频复播时视频已播放的时长，单位毫秒
- (void)didResumeVideoWithCurrentDuration:(NSTimeInterval)duration;

/// 视频播放异常时上报此事件，duration为出现异常时视频已播放的时长，单位毫秒
- (void)didFailVideoWithCurrentDuration:(NSTimeInterval)duration error:(nullable NSError *)error;

@end

@interface SQRHuiChuanAdView (HCVideoPlayControl)

- (void)playVideo;

- (void)pauseVideo;

@end

NS_ASSUME_NONNULL_END
