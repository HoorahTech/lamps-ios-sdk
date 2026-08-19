//
//  SQRHuiChuanRewardVideoAd.h
//  ShuQiHuiChuanADSDK
//
//  Created by Ryan on 2020/8/19.
//

#import <UIKit/UIKit.h>
#import "SQRHuiChuanResponseModel.h"
#import "HCRewardAdFetcherProtocol.h"
#import "HCNoahDataProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class HCRewardVideoDownloadModel;

typedef NS_ENUM(NSUInteger, HCRewardAdRewardType) {
    HCRewardAdRewardTypeNormal    = 0,  // 基础奖
    HCRewardAdRewardTypeAdvance   = 1   // 进阶奖
};

@protocol SQRHuiChuanRewardedVideoAdDelegate;

@interface SQRHuiChuanRewardVideoAd : NSObject

@property (nonatomic,strong) id<HCRewardAdFetcherProtocol> fetcher;
@property (nonatomic, getter=isAdValid, readonly) BOOL adValid;
@property (nonatomic) BOOL videoMuted;
@property (nonatomic, assign, readonly) NSInteger expiredTimestamp;
@property (nonatomic, weak) id <SQRHuiChuanRewardedVideoAdDelegate> delegate;
@property (nonatomic, weak) id <HCNoahDataProtocol> noahDataDelegate;
@property (nonatomic, readonly) NSString *placementId;
/// 用于竞价的价格 单位：分   默认值 -1
@property (nonatomic,assign,readonly)double price;
@property (nonatomic,assign,readonly)double dspPriority;
/// 1:表示禁止广告，其他值或不存在均表示可以展示广告
@property (nonatomic, assign) HCForbiddenType adForbidden;
// 测试用的 mockUrl
@property (nonatomic, copy, nullable) NSString *mockUrl;

@property (nonatomic, assign) BOOL mute;
@property (nonatomic, assign) BOOL disableVideoClick;

// 奖励时间 mediation下发, noah_hc_rewardtime，单位秒，默认 45秒
@property (nonatomic, assign) NSInteger rewardtime;
// 关闭按钮出现时间 mediation下发, hcsdk_video_close_button_after，单位秒，默认 0秒，广告展示就开始出现关闭按钮
@property (nonatomic, assign) NSInteger skipShowTime;
// 关闭挽留弹框 mediation下发, hc_rdsd_enable，默认 打开
@property (nonatomic, assign) BOOL rewarddetain;
// 激励视频样式3 model
@property (nonatomic, strong) HCRewardVideoDownloadModel *downloadModel;
@property (nonatomic, assign, readonly) NSInteger raiseUpType;

@property (nonatomic, assign) BOOL mamaSpecialAdEnable;
@property (nonatomic, copy, nullable) NSString *mamaSpecialAdFailTips;

@property (nonatomic, assign) BOOL enableLogo;
@property (nonatomic, assign) BOOL enableEndCard;
@property (nonatomic, strong) UIImage *customLogoImg;

@property (nonatomic, assign) BOOL enableMaskView;
@property (nonatomic, assign) BOOL enableClickCallApp;
@property (nonatomic, assign) int maskViewDismissTime;
@property (nonatomic, assign) HCRewardAdRewardType rewardType;
//进阶发奖发进阶奖励时是否需要一起发基础奖
@property (nonatomic, assign) BOOL needRewardTogether;
@property (nonatomic, assign) BOOL enableShowCoupon;
@property (nonatomic, assign) BOOL forbidCloseAnimate;

@property (nonatomic, assign) BOOL isReplayFix;

#pragma mark - 双广告（多任务）属性
/// 第二条广告的完整物料模型（双广告模式）
@property (nonatomic, strong, nullable) SQRHuiChuanResponseAdModel *secondAdModel;
/// 是否为双广告模式（multi_task_type == 1 且 secondAdModel 存在）
@property (nonatomic, assign, readonly) BOOL isMultiAdMode;
/// 双广告价格加和（广告1 + 广告2 的 dsp_bid_price）
@property (nonatomic, assign, readonly) double combinedPrice;
/// 请求广告数量（双广告模式下设为 2）
@property (nonatomic, assign) NSInteger requestAdCount;
/// 是否禁止调端失败后的降级处理（打开落地页/AppStore），默认 NO（不禁止）
@property (nonatomic, assign) BOOL disableSchemeFailFallback;

- (instancetype)initWithPlacementId:(NSString *)placementId;/**
 *  构造方法
 *  详解：placementId - 广告位 ID
 *  ext_info: 扩展字段  目前有：
 *  {
 *    personalized_ad   (string)设置汇川禁止个性化广告,如果禁止就传0,   非0 或者不传，则开启个性化广告
 *  }
 */
- (instancetype)initWithPlacementId:(NSString *)placementId ext_info:(nullable NSDictionary *)ext_info;

- (instancetype)initWithPlacementId:(NSString *)placementId
                           ext_info:(nullable NSDictionary *)ext_info
                          adFetcher:(id<HCRewardAdFetcherProtocol>)fetcher;

- (void)loadAdData;

- (void)updateBottomView:(nullable UIView *)bottomView endView:(nullable UIView *)endView;

- (void)showAdFromRootViewController:(UIViewController *)rootViewController;

- (void)showAdFromRootViewController:(UIViewController *)rootViewController
                          completion:(void (^ __nullable)(void))completion;

/// 竞胜URL上报
/// - Parameters:
///   - sessionId: 外部传入的sessionId
///   - price: 媒体竞价的二价(当智能营销SDK竞价胜出时，竞价队列中次高价ADN的出价 + 1分，例如次高ADN出价100分，二价就是101分), 单位：分/ecpm
///   - priceAesStr: aes加密后的二价字符串
-(void)reportAdWinUrl:(NSString *_Nonnull)sessionId price:(int)price priceAesStr:(NSString *)priceAesStr;

/// 内容视图(视频或图片)
- (nullable UIView *)mediaView;

/// 规则引擎覆盖物料后，刷新内部缓存的 adModel 和 secondAdModel
- (void)refreshAdModelsFromResponse;

@end

@protocol SQRHuiChuanRewardedVideoAdDelegate <NSObject>

@optional

/**
 广告数据加载成功回调

 @param rewardedVideoAd SQRHuiChuanRewardVideoAd 实例
 */
- (void)hc_rewardVideoAdDidLoad:(SQRHuiChuanRewardVideoAd *)rewardedVideoAd;

/**
 数据请求成功回调
@param rewardedVideoAd SQRHuiChuanRewardVideoAd 实例
*/
- (void)huiChuanRewardFetcher:(SQRHuiChuanRewardVideoAd *)rewardedVideoAd receieved:(SQRHuiChuanResponseModel *)model;

/**
 汇川广告主信息获取
 */
- (NSString *_Nullable)advertiserForHuiChuanRewardFetcher:(SQRHuiChuanRewardVideoAd *)rewardedVideoAd;

/**
三方bid数据回传
 */
- (NSString *_Nullable)bidUploadDatasForHuiChuanRewardFetcher:(SQRHuiChuanRewardVideoAd *)rewardedVideoAd;

/**
 视频数据下载成功回调，已经下载过的视频会直接回调

 @param rewardedVideoAd SQRHuiChuanRewardVideoAd 实例
 */
- (void)hc_rewardVideoAdVideoDidLoad:(SQRHuiChuanRewardVideoAd *)rewardedVideoAd;

/**
 视频播放页即将展示回调

 @param rewardedVideoAd SQRHuiChuanRewardVideoAd 实例
 */
- (void)hc_rewardVideoAdWillVisible:(SQRHuiChuanRewardVideoAd *)rewardedVideoAd;

/**
 视频广告曝光回调

 @param rewardedVideoAd SQRHuiChuanRewardVideoAd 实例
 */
- (void)hc_rewardVideoAdDidExposed:(SQRHuiChuanRewardVideoAd *)rewardedVideoAd;

/**
 视频播放页关闭回调

 @param rewardedVideoAd SQRHuiChuanRewardVideoAd 实例
 @discussion 该方法与hc_rewardVideoAdDidClose区别在于WillClose在关闭动画前调用，DidClose在关闭动画完成后调用
 */
- (void)hc_rewardVideoAdWillClose:(SQRHuiChuanRewardVideoAd *)rewardedVideoAd;

/**
 视频播放页关闭回调

 @param rewardedVideoAd SQRHuiChuanRewardVideoAd 实例
 */
- (void)hc_rewardVideoAdDidClose:(SQRHuiChuanRewardVideoAd *)rewardedVideoAd;

/**
 视频广告信息点击回调

 @param rewardedVideoAd SQRHuiChuanRewardVideoAd 实例
 */
- (void)hc_rewardVideoAdDidClicked:(SQRHuiChuanRewardVideoAd *)rewardedVideoAd;

/**
视频广告信息点击跳过

@param rewardedVideoAd SQRHuiChuanRewardVideoAd 实例
*/
- (void)hc_rewardVideoAdDidSkip:(SQRHuiChuanRewardVideoAd *)rewardedVideoAd;

/**
 视频广告各种错误信息回调

 @param rewardedVideoAd SQRHuiChuanRewardVideoAd 实例
 @param error 具体错误信息
 */
- (void)hc_rewardVideoAd:(SQRHuiChuanRewardVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error;

/// 激励广告请求错误回调
/// @param rewardedVideoAd 实例
/// @param error 请求错误信息
- (void)hc_rewardVideoAd:(SQRHuiChuanRewardVideoAd *)rewardedVideoAd didRequestFailWithError:(NSError *)error;

/**
 视频广告播放达到激励条件回调

 @param rewardedVideoAd SQRHuiChuanRewardVideoAd 实例
 */
- (void)hc_rewardVideoAdDidRewardEffective:(SQRHuiChuanRewardVideoAd *)rewardedVideoAd;

/**
 视频广告视频播放完成

 @param rewardedVideoAd SQRHuiChuanRewardVideoAd 实例
 */
- (void)hc_rewardVideoAdDidPlayFinish:(SQRHuiChuanRewardVideoAd *)rewardedVideoAd;

/**
 视频广告调端打点

 @param rewardedVideoAd SQRHuiChuanRewardVideoAd 实例
 */
- (void)hc_rewardVideoAdDidCallApp:(SQRHuiChuanRewardVideoAd *)rewardedVideoAd dic:(NSDictionary *)dic;

/**
 下单广告请求上报

 @param rewardedVideoAd SQRHuiChuanRewardVideoAd 实例
 */
- (void)hc_rewardVideoAdOrderQueryReward:(SQRHuiChuanRewardVideoAd *)rewardedVideoAd params:(NSDictionary *)params type:(NSString *)type;

/**
 下单广告结果返回上报

 @param rewardedVideoAd SQRHuiChuanRewardVideoAd 实例
 */
- (void)hc_rewardVideoAdOrderQueryResult:(SQRHuiChuanRewardVideoAd *)rewardedVideoAd params:(NSDictionary *)params type:(NSString *)type isSuccess:(BOOL)isSuccess;

/// 自定义事件上报
- (void)hc_rewardVideoAd:(SQRHuiChuanRewardVideoAd *)rewardedVideoAd sendEvent:(int)eventId extInfo:(nullable NSDictionary *)extInfo;
@end

NS_ASSUME_NONNULL_END
