//
//  SQRHCSplashADView.h
//  ShuQiHCSDK
//
//  Created by 金日成 on 2020/7/24.
//  Copyright © 2020 ShuQi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SQRHuiChuanResponseModel.h"
#import "HCShakeDefineHeader.h"
#import "HCNoahDataProtocol.h"

@class SQRHCVideoPlayer;
@protocol SQRHCSplashADViewDelegate <NSObject>
@optional
/// 图片下载完成
- (void)imageDidLoad;

/// 图片下载失败
- (void)imageLoadFailed;

- (void)beginCountDown;

- (void)splashAdFailToPresent;

/**
 *  开屏广告曝光回调
 */
- (void)splashAdExposured;

/**
 *  开屏广告点击回调
 */
- (void)splashAdClicked:(NSString *)clickArea buttonIndex:(int)buttonIndex clickAction:(NSString *)clickAction turl:(NSString *)turl;

/**
 *  开屏广告将要关闭回调
 */
- (void)splashAdWillClosed;

/**
 *  开屏广告关闭回调
 */
- (void)splashAdClosed;

/**
*  开屏广告点击跳过回调
*/
- (void)splashAdDidClickSkip;

/**
 *  开屏广告点击以后即将弹出全屏广告页
 */
- (void)splashAdWillPresentFullScreenModal;

/**
 *  开屏广告点击以后弹出全屏广告页
 */
- (void)splashAdDidPresentFullScreenModal;

/**
 *  点击以后全屏广告页将要关闭
 */
- (void)splashAdWillDismissFullScreenModal;

/**
 *  点击以后全屏广告页已经关闭
 */
- (void)splashAdDidDismissFullScreenModal;

/**
 * 开屏广告剩余时间回调
 */
- (void)splashAdLifeTime:(NSUInteger)time;

//@"app_id":appid
- (void)splashAdApplicationForAppInfo:(NSDictionary *)info;

/**
 * 联投广告到列表
 */
- (void)splashAdShouldInsertToList;

/**
 * 联投广告（暗投）插入广告信息到信息流
 */
- (void)splashAdShouldInsertAdInfoToNewFlows;

/**
 *  开屏广告落地页关闭
 */
- (void)splashAdDidCloseWebView;

@end

@interface SQRHCSplashADView : UIView
@property (nonatomic ,weak) id<SQRHCSplashADViewDelegate>delegate;
@property (nonatomic ,weak) id<HCNoahDataProtocol> noahDataDelegate;
@property (nonatomic ,strong)UIButton *timerButton;
@property (nonatomic ,assign)BOOL is_fullscreen;
@property (nonatomic ,assign)CGSize originImgSize;
@property (nonatomic ,strong)SQRHuiChuanResponseModel *adParams;


// noah SDK 中配置的参数  都是非必须----------------------------------------------
// noah以前的判断是否 媒体端自渲染，已弃用
@property (nonatomic ,assign)BOOL manualDismiss;
/// 摇一摇是否可点击
@property (nonatomic, assign) BOOL sdk_shake_clickable;
/// 摇一摇幅度 默认13  代理方式的数据设置优先级更高
@property (nonatomic, assign) int sdk_shake_accelertion;
// 摇一摇扩展参数
@property (nonatomic,strong) NSDictionary *shake_extInfo;
/// 开屏上滑解锁参数, 是否支持点击:scroll_unlock_able (bool), 滑动触发阈值:scroll_unlock_distance (float)
@property (nonatomic,strong) NSDictionary *scroll_unlock_extInfo;
/// 开屏样式
@property (nonatomic, assign) int splash_showtype;
/// 开屏样式兜底
@property (nonatomic, assign) int splash_showtype_reveal;
/// 是否noah聚合SDK调用    默认 NO
@property (nonatomic, assign) BOOL isNoahStly;

/// 使用新裁剪
@property (nonatomic, assign) BOOL useNewImgScale;

///是否回调媒体端打开落地页
@property (nonatomic,assign)BOOL isCallBackAppOpenTUrl;

// 摇一摇新参数 返回格式 @"15,35,3,0.3"(第一位：加速度，第二位：转动角度，第三位：持续时间，第四位：持续中断检测时间)
@property (nonatomic,copy) NSString *shakeParam;
// 规则引擎返回的高优先级配置，格式与shakeParam相同(摇一摇普通样式或优化样式，都优先读取此开关)
@property (nonatomic,copy) NSString *ruleShakeParam;
// 规则引擎返回的高优先级配置，格式与汇川接口返回的can_shake相同
@property (nonatomic,copy) NSString *ruleCanShake;

// 摇一摇角度判断类型
@property (nonatomic, assign) HCShakeSwingType shakeSwingType;

// 组件模板配置信息
@property (nonatomic, copy) NSDictionary *templateConfig;

@property (nonatomic,strong)NSDictionary *ext_info;

/// 开屏，是否禁止摇一摇功能，YES：禁止，NO：不禁止，默认：NO
@property (nonatomic, assign) BOOL splashShakeIsClose;

/// 开屏，是否禁止旋转功能，YES：禁止，NO：不禁止，默认：NO
@property (nonatomic, assign) BOOL splashShakeOptIsClose;

/// 蹊径打点 查询slotKey
@property (nonatomic, copy) NSString *slotKey;
/// 是否禁止调端失败后的降级处理（打开落地页/AppStore），默认 NO（不禁止）
@property (nonatomic, assign) BOOL disableSchemeFailFallback;

@property (nonatomic,copy) NSString *appSceneName;

@property (nonatomic, assign) BOOL enableShowCoupon;

/// CTA 按钮是否可点击触发广告跳转，默认 NO
@property (nonatomic, assign) BOOL enableSplashCouponCTA;
/// 预算弹窗 CTA 文案配置字典（由 ad_cta_word_list 配置传入，key="0"通用/"1"下载）
@property (nonatomic, copy) NSDictionary *budgetPopupCtaWordList;
/// 是否展示通用预算弹窗（预算类型=1），默认 NO
@property (nonatomic, assign) BOOL enableSplashBudgetPopup;

@property (nonatomic, assign) BOOL isForceHalf;

@property (nonatomic, assign) BOOL needCloseWebViewCallback;

// 是否是摇一摇样式
-(BOOL)isShakeStly;
// 是否是自渲染样式
-(BOOL)supportCustomRender;
- (SQRHCVideoPlayer*)getVideoPlayView;
// ------------------------------------------------------------------



- (instancetype)initWithParams:(SQRHuiChuanResponseModel *)params;
// 加载预加载下载好的图片
- (instancetype)initWithParams:(SQRHuiChuanResponseModel *)params image:(UIImage *)showImage;

- (void)loadFile;

- (void)showAdInWindow:(UIWindow *)window withBottomView:(UIView *)bottomView skipView:(UIView *)skipView topLogoView:(UIView *)topLogoView;
- (void)dismiss:(void (^)(void))animations;
@end
