//
//  RequestInfo+Private.h
//  NoahSDK
//
//  Created by zzyong on 2025/7/18.
//  Copyright © 2025 Alibaba Inc. All rights reserved.
//

#ifndef RequestInfo_Private_h
#define RequestInfo_Private_h

#import <UIKit/UIKit.h>
#import "RequestInfo.h"
#import "NoahCustomParamsKey.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, NASplashSwitchOption) {
    NASplashSwitchOptionAllowAll    = 0, //允许所有的adn
    NASplashSwitchOptionAllowMarket = 1, //只允许阿里妈妈market
    NASplashSwitchOptionAllowNone   = 2, //禁止所有的adn
};

@protocol IAdTaskEventListener, ICustomAdnLevelDelegate;

// 原生视频播放器自定义播放控制类型
typedef NS_OPTIONS(NSUInteger, NANativeVideoPlayControlOptions) {
    NANativeVideoPlayControlNone  = 0,      // 无需控制
    NANativeVideoPlayControlGDT   = 1 << 0, // 广点通
    NANativeVideoPlayControlBaidu = 1 << 1, // 百度
    NANativeVideoPlayControlTanx  = 1 << 2, // Tanx
    NANativeVideoPlayControlHC    = 1 << 3, // HC
    NANativeVideoPlayControlKS    = 1 << 4, // 快手
};

typedef NS_OPTIONS(NSUInteger, NARepeatAdMode) {
    NARepeatAdModeOnlyImageId        = 1, // 只判断image_id
    NARepeatAdModeOnlyRules          = 2, // 只判断rules
    NARepeatAdModeImageIdBeforeRules = 3, // 先判断image_id再判断rules（默认）
    NARepeatAdModeImageIdOrRules     = 4, // 判断image_id或rules任意一种
};

//广告流量价值等级
typedef NS_ENUM(NSInteger, NAAdValueLevel) {
    NAAdValueLevelLow    = 0,
    NAAdValueLevelNormal,
    NAAdValueLevelHigh
};

@class NASdkNodeService;

@interface RequestInfo ()

// 请求指定的appKey,在需要区分不同的appKey场景下用到,比如uc小说和uc小游戏需要使用不同的appKey(暂时没用，后续扩展)
// 非必须
@property (strong, nonatomic) NSString *mRequestAppKey;

// UC闪屏采用的分段式超时
@property(assign,nonatomic)BOOL isUseDistributedTimeout;
@property(assign,nonatomic)BOOL isColdStart;
@property(strong,nonatomic)NSDictionary* personalExt;
@property(weak,nonatomic)id<ICustomAdnLevelDelegate> levelDelagate;
//指定使用rerank缓存策略
@property(assign,nonatomic)BOOL useRerankCacheMediation;
//指定使用rerank-preload
@property(assign,nonatomic)BOOL demandRerankCache;
//循环rerank-preload
@property(assign,nonatomic)BOOL demandRerankRecyle;

//汇川，曝光打点，是否需要判断View可见，默认为YES
@property(assign,nonatomic)BOOL hcShowIsNeedCheckViewVisible;
//汇川，View可见判断，是否需要判断露出的面积（50%），默认为YES。特别注意，此参数生效的前置条件是hcShowIsNeedCheckViewVisible为YES
@property(assign,nonatomic)BOOL hcShowIsNeedCheckVisibleArea;

///汇川是否回调媒体端打开落地页
@property (assign,nonatomic)BOOL hcIsCallBackAppOpenTUrl;

@property(strong,nonatomic,nullable)NASdkNodeService* sdkNodeService;

// 是否执行负反馈操作
@property(assign,nonatomic) BOOL needDisslikeAction;
// 负反馈失败是否用规则二
@property(assign,nonatomic) BOOL disslikeHackFailAction;
// 负反馈新策略开关
@property(assign,nonatomic) BOOL enableDislikePolicy;
// 负反馈新策略忽略adnId列表
@property(strong,nonatomic,nullable) NSArray<NSString *> *disableDislikeAdns;


// 媒体端提前传入返回view的size
@property(assign,nonatomic) CGSize rtViewSize;

// 开屏预估价格打点数据
@property(strong,nonatomic) NSDictionary *splashEstPriceInfo;

/// 是否使用媒体侧的开屏配置
@property (nonatomic, assign) BOOL isUseAppSplashConfig;//默认为NO
/// 媒体侧配置的开屏开关
@property (nonatomic, assign) NASplashSwitchOption appSplashSwitchOption;//默认为NASplashSwitchOptionAllowAll
/// 媒体侧配置的market key白名单列表（appSplashSwitchOption为NASplashSwitchOptionAllowMarket时，才会用到这个白名单列表）
@property (nonatomic, copy, nullable) NSArray *appConfigMarketKeyWhileList;

// 媒体端提前传入返回广告背景图size
@property(assign,nonatomic) CGSize adBgImageSize;

/// 模版渲染，媒体提前设置adView size
@property (nonatomic, assign) CGSize expressAdViewSize;

/// 广告刷数 信息流列表和合一页才有值
@property (nonatomic, assign) NSUInteger refreshNum;

/// 合一页广告的上一个卡片 articleRecordId
@property (nonatomic, copy) NSString *articleRecordId;

/// 媒体是否允许开启横滑点击，默认YES
@property (nonatomic, assign) BOOL appEnableSlidClick;

/// 媒体是否允许开启扩展区域点击，默认YES
@property (nonatomic, assign) BOOL appEnableExtendClick;

/// 媒体是否打开个性化策略，默认NO
@property (nonatomic, assign) BOOL appEnablePersonalized;

// 媒体透传tanx UserId
@property (copy,nonatomic) NSString *tanxUserId;

// 是否允许所有adn激励视频异步查奖
@property (nonatomic, assign) BOOL enableAsyncQueryReward;

/// 流量价值预估价格
@property (nonatomic, strong) NSNumber *adEstPrice;
/// 流量价值预估等级（决策是否发起adn请求）
@property (nonatomic, assign) NAAdValueLevel adValueLevel;
/// 媒体是否触发了超时，同步读取缓存
@property (nonatomic, assign) BOOL appTimeout;

/// 媒体透传数据
@property (nonatomic, strong) NSDictionary *userData;

/// 用于媒体侧透传上下文信息，在返回的Ad对象中的RequestInfo中可以获取到这个信息
@property (nonatomic, strong) NSDictionary *externalContextInfo;

/**
 mForbidPersonalizedAd ---  @"0":禁止个性化开关， 其他开启个性化
 bootView 非必须，开屏底部logo view，不需要传nil。主要针对穿山甲需要初始化之前传入半屏信息
 extInfo 非必须，没有传nil，
 listener --- 事件监听器，非必须，没有传nil
 */
-(instancetype)init:(nullable NSString *)mForbidPersonalizedAd bootView:(nullable UIView *)bootView extInfo:(nullable NSDictionary *)extInfo listener:(nullable id<IAdTaskEventListener>)listener;
/**
extInfo 非必须，没有传nil，
listener --- 事件监听器，非必须，没有传nil
*/
-(instancetype)initExtInfo:(nullable NSDictionary *)extInfo listener:(nullable id<IAdTaskEventListener>)listener;

// 返回整体extInfo字段
-(NSDictionary *)getExtInfoDic;

/**
    * 外部主动终止RTB竞价
    */
-(void)abortAdTask;

-(void)unBindAdTask;

// 返回事件监听器
-(id<IAdTaskEventListener>)getTaskEventListener;

// 获取开屏底部logo view
-(UIView *)getBootView;

// 设置noah custom请求过程中的数据
-(void)setNoahResultKey:(NSString *)key data:(NSObject *)data;
-(NSObject * _Nullable)getNoahDateFromKey:(NSString *)key;
-(void)removeDateFromKey:(NSString *)key;

// 媒体端打点透传字典
-(void)updateRequestExtraInfoForStats:(NSDictionary *)extInfo;
-(NSDictionary *)getRequestExtraInfoForStats;

// 是否查询激励下单订单状态
- (BOOL)isQueryRewardOrderStatus;

// 自动播放策略（媒体用户设置）
@property (nonatomic, assign) NAVideoAutoPlayPolicy userSettingAutoPlayPolicy;

@end

#pragma mark - Custom Config

@interface RequestInfo ()

/// 请求指定 Adn 列表，如有值，则只请求列表里的 Adn，优先级高于广告配置文件，主要用于媒体灰度实验。非必要不使用！！！
@property (nonatomic, strong) NSArray<NSString *> *specifyAdnReqList;

/// 手动曝光百度原生广告，默认 NO；兼容广告视图提前缓存场景
@property (nonatomic, assign) BOOL manualExposeBaiDuNativeAd;

/// 是否需要加载穿山甲直播广告 SDK
@property (nonatomic, assign) BOOL shouldLoadBuLiveSdks;

/// 默认 YES
@property (nonatomic, assign) BOOL enableAdTaskDelegate;

@property (nonatomic, assign) int demandAdnId;

/// 是否需要自定义上报广告曝光事件，适用非标广告位
@property (nonatomic, assign) BOOL customImpressionEnable;

/// 是否使用自定义adn的广告数量作为返回广告条数（此参数为YES时，返回多少条广告，以自定义adn的广告数量为准；
/// 此参数为NO时，返回多少条广告，则以requestCount为准）
@property (nonatomic, assign) BOOL useCustomAdnRequireSizeEnable;

/// 是否允许在没有汇川信息流返回的时候loaded广告
@property (nonatomic, assign) BOOL enableLoadedAdWithoutHCIflow;

/// 是否需要重复广告过滤
@property (nonatomic, assign) BOOL enableRepeatAdFilter;

/// 缓存场景key。当此参数，不为空时，缓存的key-value使用这个key；当此参数为空时，缓存的key-value使用slotId使用这个key；
@property (nonatomic, copy, nullable) NSString *cacheSceneKey;

/// 自定义播放器是否frame自适应，默认为YES
@property (nonatomic, assign) BOOL enableCustomVideoPlayerFrameAdapt;

/// 自定义播放器是否以原始比例播放视频，YES为原始比例，NO为拉伸，默认NO
@property (nonatomic, assign) BOOL enableCustomVideoPlayerScaleAspect;

// 是否开启native广告的同步abort能力，默认NO
@property (nonatomic, assign) BOOL enableNativeAdSyncAbort;

/// 自定义播放器加载完是否能自动播放，默认为YES
@property (nonatomic, assign) BOOL customVideoPlayerAutoPlayAfterLoadEnable;

/// 是否屏蔽三方SDK广告，包括 汇川(不包括汇川 预加载和品牌，和adm)；默认不屏蔽
@property (nonatomic, assign) BOOL needAbandonOtherSDK;

/// 自定义播放器，播放按钮宽度，默认为64
@property (nonatomic, assign) CGFloat customVideoPlayerPlayBtnWidth;

/// 自定义播放器，播放按钮是否默认显示。1:默认显示，即只有播放状态才不显示；0:默认不显示，即只有暂停状态才显示。 默认：1
@property (nonatomic, assign) BOOL customVideoPlayerPlayBtnDefaultShow;

/// 自定义播放器，是否需要循环播放，0:不需要，1:需要，默认：0
@property (nonatomic, assign) BOOL customVideoPlayerNeedLoopPlay;

@property (nonatomic, assign) NANativeVideoPlayControlOptions nativeVideoPlayControlOptions;

@property (nonatomic, assign) BOOL ksNativeUseRegisterActionViews;

@property (nonatomic, assign) BOOL enableHcUrlReplaceSdkPrice;

@property (nonatomic, copy) NSString *iflowDicountExpCfg;

// adn黑名单，传入adnid黑名单，可以控制Noah不使用某些adn。
// 此处传入的黑名单，只会控制当前这个RequestInfo对应的请求，不会影响其他请求
// 示例：@[@"1"], 此示例表示禁用汇川 adn
@property (nonatomic, strong) NSArray<NSString *> *blockAdnList;

@property (nonatomic, assign) double appFloorPrice;

/// 重复广告动态模版渲染字典
@property (nonatomic, strong) NSDictionary *repeatAdDynamicRenderDic;

/// 视频播放器，播放按钮隐藏，默认：NO
@property (nonatomic, assign) BOOL videoPlayerPlayBtnHidden;

@property (nonatomic, assign) BOOL isSliderControlEnable;

@property (nonatomic, assign) BOOL isGiftShowEnable;

@property (nonatomic, assign) BOOL isVideoPlayLoopEnable;
// 三方sdk仅从cache中请求
@property (nonatomic, assign) BOOL onlyRequestCache;

@property (nonatomic, assign) BOOL isShieldAdnInfoControlEnable;

@property (nonatomic, assign) BOOL enableRecycleAdOnDestroy;
@property (nonatomic, assign) int recycleAdOnDestroyRefreshGap;
@property (nonatomic, assign) int recycleAdOnDestroyInterval;

@property (nonatomic, assign) BOOL enableRepeatAdSort;
@property (nonatomic, assign) int repeatAdSortGap;
@property (nonatomic, assign) int repeatAdSortEffectiveTime;
@property (nonatomic, strong) NSString *repeatAdSortRule;
@property (nonatomic, strong) NSArray<NSString *> *repeatAdSortBlack;
@property (nonatomic, assign) NARepeatAdMode repeatAdMode;

@property (nonatomic, assign) BOOL customVideoPlayerVisibleAutoPlay;

@property (nonatomic, assign) BOOL timeoutFloorPriceOpt;
@property (nonatomic, assign) BOOL timeoutLoadedCountsOpt;
//场景名
@property (nonatomic, strong) NSString *appSceneName;

@property (nonatomic, assign) BOOL enableRulerBullet;
@property (nonatomic, assign) BOOL customVideoPlayerForbidCache;

// 是否支持原生激励
@property (nonatomic, assign) BOOL enableReward;

// 媒体给开屏的整体超时时间，单位ms
@property (nonatomic, assign) NSTimeInterval splashDurationLimit;

/// tanx闪屏Preview需要用到的参数，当参数有值时，会屏蔽其他所有ADN
@property (nonatomic, strong, nullable) NSString *tanxPreviewCreativeId;

@end

#pragma mark - Splash Ad

@interface RequestInfo ()

///开屏广告背景颜色
@property (nonatomic, strong, nullable) UIColor *splashBackgroundColor;

/// 是否禁止汇川广告开屏摇一摇功能，YES:禁止，NO:不禁止，默认：NO
@property (nonatomic, assign) BOOL forbidSplashShakeStyle;

/// 是否禁止开屏旋转互动功能，YES禁止，仅UC使用
@property (nonatomic, assign) BOOL forbidSplashRotateStyle;

@end

#pragma mark - MediaView

@interface RequestInfo ()

/// MediaView 是否需要高斯模糊背景，仅适用于单图并且图片 h > w 的场景
@property (nonatomic, assign) BOOL isNeedBlurEffectBg;

/// 是否需要将视频广告降级为图片广告，适用于：汇川、百度、穿山甲、广点通、快手、Tanx、京东
@property (nonatomic, assign) BOOL videoToImageEnable;

/// 是否允许视频转图片的adn列表,默认[@"*"],默认的这个*，则表示是所有Adn都允许，此配置，在videoToImageEnable为YES才有效
@property (nonatomic, strong) NSArray<NSString *> *allowVideoToImageAdnList;

@property (nonatomic, assign) BOOL enableImagesToSingleImage;

/// MediaView 占位图名
@property (nonatomic, strong, nullable) NSString *mediaViewPlaceholderImageName;

@end

#pragma mark -激励进阶相关功能参数

@interface RequestInfo ()

/// 激励视频基础奖励金额
@property (nonatomic, copy) NSString *rewardInfoCount;

/// 激励视频基础奖励单位
@property (nonatomic, copy) NSString *rewardInfoContent;

/// 激励视频进阶奖励金额
@property (nonatomic, copy) NSString *adVanceRewardInfoCount;

/// 激励视频进阶奖励单位
@property (nonatomic, copy) NSString *adVanceRewardInfoContent;

/// 激励进阶是否需要合并发奖
@property (nonatomic, assign) BOOL supportRewardCombine;

/// 汇川激励进阶是否需要连发奖励
@property (nonatomic, assign) BOOL enableHcRewardTogether;

/// 是否支持广点通进阶发奖
@property (nonatomic, assign) BOOL enableGdtAdvReward;

/// 激励视频场景
@property (nonatomic, copy, nullable) NSString *rewardScene;

@property (nonatomic, copy, nullable) NSString *visualSlotKey;

@property (nonatomic, assign) int visualAdnId;
@property (nonatomic, copy, nullable) NSString *visualSessionId;

@end

#pragma mark - 激励视频场景【再看一个】

// 激励视频【再看一个】事件通知
typedef NS_ENUM(NSInteger, NARewardOMEventType) {
    NARewardOMEventGuideShow = 1,         ///< 引导弹窗展示
    NARewardOMEventGuideDismiss,          ///< 引导弹窗消失
    NARewardOMEventGuideClickGetReward,   ///< 引导弹窗点击获取奖励
    NARewardOMEventGuideClickQuit,        ///< 引导弹窗点击退出
    NARewardOMEventFailAdnNotSupport,     ///< 未达到弹窗条件：ADN不支持
    NARewardOMEventFailNotGetRewards,     ///< 未达到弹窗条件：本次没有获得奖励
    NARewardOMEventFailSdkSwitchOff,      ///< 未达到弹窗条件：SDK开关关闭
    NARewardOMEventFailSdkTimesLimit,     ///< 未达到弹窗条件：SDK次数限制
    NARewardOMEventFailAppJudgeDisable,   ///< 未达到弹窗条件：app传入开关关闭
    NARewardOMEventFailRewardInfoInvalid, ///< 未达到弹窗条件：app传入参数无效
    NARewardOMEventProcessEnd,            ///< 激励视频【再看一个】流程结束（包含达到最大次数，点击退出，条件不符等）
};

typedef NSString *NARewardOneMoreKey NS_TYPED_EXTENSIBLE_ENUM;
// 返回key
FOUNDATION_EXTERN NARewardOneMoreKey const NARewardOMEnable;         ///< 功能开关，value为NSNumber
FOUNDATION_EXTERN NARewardOneMoreKey const NARewardOMRewardCount;    ///< 奖励数量，value为NSNumber
FOUNDATION_EXTERN NARewardOneMoreKey const NARewardOMRewardContent;  ///< 奖励内容，value为NSString
// 参数key
FOUNDATION_EXTERN NARewardOneMoreKey const NARewardOMEcpm;           ///< ecpm，value为NSNumber

@protocol NARewardOneMoreProtocol <NSObject>
/// 获取【再看一个】配置信息（包含NARewardOMEnable等信息）
- (NSDictionary<NARewardOneMoreKey, id> *)getOneMoreRewardInfo:(NSDictionary<NARewardOneMoreKey, id> *)adInfo
                                                   fromRequest:(RequestInfo *)reqInfo;

/// 触发【再看一个】请求，收到该回调后，媒体需要发出一个新的激励视频请求
- (void)triggerOneMoreRequest:(BOOL)isRetry fromRequest:(RequestInfo *)reqInfo;

/// 【再看一个】事件回调
- (void)onEvent:(NARewardOMEventType)event fromRequest:(RequestInfo *)reqInfo;

@end

@interface RequestInfo ()

/// 激励【再看一个】控制器
@property (nonatomic, weak) id<NARewardOneMoreProtocol> rewardOneMoreController;

/// 标识是否【再看一个】触发的请求（由 triggerOneMoreRequest:fromRequest: 通知触发）
@property (nonatomic, assign) BOOL isRewardOneMoreRequest;

/// 标识是否【再看一个】最后一次重试
@property (nonatomic, assign) BOOL isRewardOneMoreLastRetry;

/// 标识是否由媒体控制视频播放（非必要不使用）
@property (nonatomic, assign) BOOL isAppControlPlay;
/// 标识是否贴片广告
@property (nonatomic, assign) BOOL isPasterAd;

@end

NS_ASSUME_NONNULL_END

#endif /* RequestInfo_Private_h */
