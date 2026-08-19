//
//  HCSplashAd.h
//  ShuQiHCSDKSample
//  汇川开屏广告，目前只支持iPhone设备上展示垂直方向的开屏广告
//  Created by 金日成 on 2020/7/23.
//  Copyright © 2020 ShuQi. All rights reserved.

#import <Foundation/Foundation.h>
#import "SQRHuiChuanHeaderModel.h"
#import "SQRHuiChuanResponseModel.h"
#import "HCShakeDefineHeader.h"
#import "HCNoahDataProtocol.h"
#import <UIKit/UIKit.h>

@class SQRHuiChuanSplashAd;
@class SQRHCSplashADView;
@class SQRHuiChuanAdFetcher;
NS_ASSUME_NONNULL_BEGIN

@protocol SQRHuiChuanSplashAdDelegate <NSObject>

@optional

/**
* 数据请求成功
*/
- (void)huiChuanSplashAdFetcher:(SQRHuiChuanSplashAd *)fetcher receieved:(SQRHuiChuanResponseModel *)model;

/**
*  数据请求失败
*/

- (void)huiChuanSplashAdFetcher:(SQRHuiChuanSplashAd *)fetcher failed:(NSError*)error;

/**
 * 开屏广告成功展示
 */
- (void)splashAdSuccessPresentScreen:(SQRHuiChuanSplashAd *)splashAd;

/**
 *  开屏广告素材加载成功
 */
- (void)splashAdDidLoad:(SQRHuiChuanSplashAd *)splashAd;
/**
 *  开屏广告View回传
 */
- (void)splashAdView:(UIView *)view;

/**
 *  开屏广告素材加载失败
 */
- (void)splashAdDidLoadFaild:(SQRHuiChuanSplashAd *)splashAd;

/**
 *  开屏广告展示失败
 */
- (void)splashAdFailToPresent:(SQRHuiChuanSplashAd *)splashAd withError:(NSError *)error;

/**
 *  应用进入后台时回调
 *  详解: 当点击下载应用时会调用系统程序打开，应用切换到后台
 */
- (void)splashAdApplicationWillEnterBackground:(SQRHuiChuanSplashAd *)splashAd appInfo:(NSDictionary *)info;

/**
 *  开屏广告曝光回调
 */
- (void)splashAdExposured:(SQRHuiChuanSplashAd *)splashAd;

/**
 *  开屏广告点击回调
 */
- (void)splashAdClicked:(SQRHuiChuanSplashAd *)splashAd;

/**
 *  开屏广告调端结果回调
 */
- (void)splashAdCalledApp:(SQRHuiChuanSplashAd *)splashAd dic:(NSDictionary *)dic;

/**
 *  开屏广告将要关闭回调
 */
- (void)splashAdWillClosed:(SQRHuiChuanSplashAd *)splashAd;

/**
 *  开屏广告关闭回调
 */
- (void)splashAdClosed:(SQRHuiChuanSplashAd *)splashAd;

/**
*  开屏广告点击跳过回调
*/
- (void)splashAdDidClickSkip:(SQRHuiChuanSplashAd *)splashAd;

/**
 *  开屏广告点击以后即将弹出全屏广告页
 */
- (void)splashAdWillPresentFullScreenModal:(SQRHuiChuanSplashAd *)splashAd;

/**
 *  开屏广告点击以后弹出全屏广告页
 */
- (void)splashAdDidPresentFullScreenModal:(SQRHuiChuanSplashAd *)splashAd;

/**
 *  点击以后全屏广告页将要关闭
 */
- (void)splashAdWillDismissFullScreenModal:(SQRHuiChuanSplashAd *)splashAd;

/**
 *  点击以后全屏广告页已经关闭
 */
- (void)splashAdDidDismissFullScreenModal:(SQRHuiChuanSplashAd *)splashAd;

/**
 * 开屏广告剩余时间回调
 */
- (void)splashAdLifeTime:(NSUInteger)time;

/**
 * 联投广告到列表
 */
- (void)splashAdShouldInsertToList;

/**
 * 联投广告（暗投）插入广告信息到信息流
 */
- (void)splashAdShouldInsertAdInfoToNewFlows;

- (NSString *_Nullable)advertiserForHuiChuanSplashAdFetcher:(SQRHuiChuanSplashAd *)fetcher;

- (NSString *_Nullable)bidUploadDatasForHuiChuanSplashAdFetcher:(SQRHuiChuanSplashAd *)fetcher;

/**
 *  开屏广告落地页关闭
 */
- (void)splashAdDidCloseController:(SQRHuiChuanSplashAd *)splashAd;

@end

@interface SQRHuiChuanSplashAd : NSObject

@property (nonatomic ,strong)SQRHuiChuanAdFetcher * fetcher;
/// 下发的背景图，原尺寸大小
@property (nonatomic,assign,readonly)CGSize originImgSize;
@property (nonatomic,assign,readonly)BOOL is_fullscreen;

/// 是否需要全屏素材半屏展示
@property (nonatomic,assign)BOOL isForceHalf;

///是否需要关闭落地页回调
@property (nonatomic,assign)BOOL needCloseWebViewCallback;

/// 用于竞价的价格 单位：分   默认值 -1
@property (nonatomic,assign,readonly)double price;


// uc 上用---------------------------------------------------------
// 点击区域  =0 非banner区域  =1 banner区域（互动区域） =2 点击红包雨的红包
@property (nonatomic, copy) NSString *clickArea;

/// 点击的按钮序号。在多按钮样式中，有多个按钮，对应的值：=1 点击第一个按钮，=2 点击第二个按钮，=3 点击第三个按钮。特别注意： =0，此参数无意义
@property (nonatomic, assign) int buttonIndex;

/// 标识进入落地页行为
/// =click 点按钮/点全屏进入时统计
/// =slither 滑动进入时统计
/// =shake 摇一摇进入时统计
@property (nonatomic, copy) NSString *clickAction;

@property (nonatomic, copy) NSString *turl;

/// 下发的广告是否有红包雨
@property (nonatomic, assign) BOOL haveRedPackRain;

/// 1:表示禁止广告，其他值或不存在均表示可以展示广告
@property (nonatomic, assign) HCForbiddenType adForbidden;

// ----------------------------------------------------------------



// noah SDK 中配置的参数  都是非必须----------------------------------------------
/**
 * 手动销毁闪屏视图，  noah以前的判断是否 媒体端自渲染，已弃用
 */
@property (nonatomic, assign) BOOL manualDismiss;
/// 摇一摇是否可点击
@property (nonatomic, assign) BOOL sdk_shake_clickable;
/// 摇一摇幅度 默认13  代理方式的数据设置优先级更高
@property (nonatomic, assign) int sdk_shake_accelertion;
// 摇一摇扩展参数
@property (nonatomic,strong,nullable) NSDictionary *shake_extInfo;
/// 开屏上滑解锁参数, 是否支持点击:scroll_unlock_able (bool), 滑动触发阈值:scroll_unlock_distance (float)
@property (nonatomic,strong) NSDictionary *scroll_unlock_extInfo;
/// 开屏样式     1:全屏可点  2:仅Banner可点  3:自定义（书旗特有功能，点击事件交书期客户端自行处理）  4:摇一摇
@property (nonatomic, assign) int splash_showtype;
/// 开屏样式兜底
@property (nonatomic, assign) int splash_showtype_reveal;
/// 是否noah聚合SDK调用    默认 NO
@property (nonatomic, assign) BOOL isNoahStly;
// 测试用的 mockUrl
@property (nonatomic, copy, nullable) NSString *mockUrl;
///是否回调媒体端打开落地页
@property (nonatomic,assign)BOOL isCallBackAppOpenTUrl;

// 摇一摇新参数 返回格式 @"15,35,3,0.3"(第一位：加速度，第二位：转动角度，第三位：持续时间，第四位：持续中断检测时间)
@property (nonatomic, copy, nullable) NSString *shakeParam;
// 规则引擎返回，优先级更高。格式同shakeParam
@property (nonatomic, copy, nullable) NSString *ruleShakeParam;
// 规则引擎返回，优先级更高。格式同can_shake
@property (nonatomic, copy, nullable) NSString *ruleCanShake;

// 摇一摇角度判断类型
@property (nonatomic, assign) HCShakeSwingType shakeSwingType;

// 组件模板配置信息
@property (nonatomic, copy, nullable) NSDictionary *templateConfig;

@property (nonatomic,strong,nullable)NSDictionary *ext_info;

@property (nonatomic, assign) BOOL enableShowCoupon;

/// CTA 按钮是否可点击触发广告跳转（SSP 开关 enable_splash_coupon_cta），默认 NO
@property (nonatomic, assign) BOOL enableSplashCouponCTA;
/// 是否展示通用预算弹窗（SSP 开关 enable_splash_budget_popup），默认 NO
@property (nonatomic, assign) BOOL enableSplashBudgetPopup;

// 是否是自渲染样式
-(BOOL)supportCustomRender;
// ------------------------------------------------------------------



/**
 *  委托对象
 */
@property (nonatomic, weak) id<SQRHuiChuanSplashAdDelegate> delegate;

@property (nonatomic, weak) id<HCNoahDataProtocol> noahDataDelegate;

/**
 *  拉取广告超时时间，默认为3秒
 *  详解：拉取广告超时时间，开发者调用loadAd方法以后会立即展示backgroundImage，然后在该超时时间内，如果广告拉
 *  取成功，则立马展示开屏广告，否则放弃此次广告展示机会。
 */
@property (nonatomic, assign) double fetchDelay;

/// 使用新裁剪
@property (nonatomic, assign) BOOL useNewImgScale;

/**
 *  开屏广告的背景色
 */
@property (nonatomic, copy) UIColor *backgroundColor;

/**
 * 跳过按钮的位置
 */
@property (nonatomic, assign) CGPoint skipButtonCenter;

/**
 *  详解：初始化加载已经返回的数据，用在预加载已经下好的数据，之后配合 showAdInWindow 即可展示，目前就UC在用
 *  初始化[SQRHuiChuanSplashAd new] 即可调用 show
 */
- (void)showInit:(SQRHuiChuanResponseModel *)data image:(UIImage *)showImage;

/**
 *  构造方法
 *  详解：placementId - 广告位 ID
 *  splashType:   0: 普通实时请求， 1：预推实时(先请求2.，再带入参数请求1)，   2：预推， 3：预加载(返回的preload_type类型有：0 不支持预加载，1 高优，2 兜底)
 */
- (instancetype)initWithPlacementId:(NSString *)placementId splashType:(NSString *)splashType;

/**
 *  构造方法
 *  详解：placementId - 广告位 ID
 *  splashType:   0 默认
 */
- (instancetype)initWithPlacementId:(NSString *)placementId;

/**
 *  构造方法
 *  详解：placementId - 广告位 ID
 *  ext_info: 扩展字段  目前有：
 *  {
 *    personalized_ad   (string)设置汇川禁止个性化广告,如果禁止就传0,   非0 或者不传，则开启个性化广告
 *  }
 */
- (instancetype)initWithPlacementId:(NSString *)placementId ext_info:(NSDictionary *)ext_info;

/**
 *  构造方法
 *  详解：placementId - 广告位 ID
 *  splashType:   0: 普通实时请求， 1：预推实时(先请求2.，再带入参数请求1)，   2：预推， 3：预加载(返回的preload_type类型有：0 不支持预加载，1 高优，2 兜底)
 *  ext_info: 扩展字段  目前有：
 *  {
 *    personalized_ad   (string)设置汇川禁止个性化广告,如果禁止就传0,   非0 或者不传，则开启个性化广告
 *  }
 */
- (instancetype)initWithPlacementId:(NSString *)placementId splashType:(NSString *)splashType ext_info:(nullable NSDictionary *)ext_info;

#pragma mark - Parallel method

/**
 * 返回广告是否可展示
 * 对于并行请求，在调用showAdInWindow前时需判断下
 * @return 当广告已经加载完成且未曝光时，为YES，否则为NO
 */
- (BOOL)isAdValid;

/**
 *  发起拉取广告请求，只拉取不展示
 *  详解：广告素材及广告图片拉取成功后会回调splashAdDidLoad方法，当拉取失败时会回调splashAdFailToPresent方法
 */
- (void)loadAd;

/**
 *  展示广告，调用此方法前需调用isAdValid方法判断广告素材是否有效
 *  详解：广告展示成功时会回调splashAdSuccessPresentScreen方法，展示失败时会回调splashAdFailToPresent方法
 */
- (void)showAdInWindow:(UIWindow *)window withBottomView:(UIView *)bottomView skipView:(UIView *)skipView topLogoView:(UIView *)topLogoView;

- (SQRHCSplashADView*)getCurrentAdView;

/// 竞胜URL上报
/// - Parameters:
///   - sessionId: 外部传入的sessionId
///   - price: 媒体竞价的二价(当智能营销SDK竞价胜出时，竞价队列中次高价ADN的出价 + 1分，例如次高ADN出价100分，二价就是101分), 单位：分/ecpm
///   - priceAesStr: aes加密后的二价字符串
-(void)reportAdWinUrl:(NSString *_Nonnull)sessionId price:(int)price priceAesStr:(NSString *)priceAesStr;


@end

NS_ASSUME_NONNULL_END

