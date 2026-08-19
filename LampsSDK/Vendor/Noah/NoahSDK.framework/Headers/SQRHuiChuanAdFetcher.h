//
//  SQRHuiChuanAdFetcher.h
//  shuqireader
//
//  Created by ZhouPanpan on 2020/3/13.
//  Copyright © 2020 AliWenXue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQRHuiChuanHeaderModel.h"
#import "SQRHuiChuanAdFetcherSchemeManager.h"
#import "SQRHCAdFetcherEncoder.h"
#import "SQRHuiChuanResponseModel.h"
#import "HCRewardAdFetcherProtocol.h"

// 非标广告位
typedef NS_ENUM(NSUInteger, UCNonstandardAdType) {
    // 首页poplayer
    UCNonstandardAdPopType = 1,
    // 菜单栏气泡
    UCNonstandardAdMenuType = 2,
    // 个人中心悬浮小球
    UCNonstandardAdBallType = 3
};

NS_ASSUME_NONNULL_BEGIN

/// 汇川接口请求
@protocol SQRHuiChuanAdFetcherDelegate, SQRHuiChuanPassthroughHandlerDelegate;
@interface SQRHuiChuanAdFetcher : NSObject <HCRewardAdFetcherProtocol>

@property (nonatomic, strong) NSString *noahSlot;

// 调整UC里面以前注册appname的缺陷，只在UC里面设置即可
@property (nonatomic,copy,nullable)NSString *app_name;

// 外部必须
@property (nonatomic,copy)NSString * _Nonnull adcode;

// 外部非必须
@property (nonatomic,weak)id<SQRHuiChuanAdFetcherDelegate> _Nullable delegate;
@property (nonatomic, assign) double fetchDelay;
// 测试用的 mockUrl
@property (nonatomic, copy, nullable) NSString *mockUrl;

@property (nonatomic, copy, nullable) NSString *fetchUrl;

// 非标广告位----------------------------------------------
@property (nonatomic,strong, nullable) NSDictionary *adDic;
// =0 返回为空  =1 有返回广告-未超时   =2 有返回广告-已超时
@property (nonatomic,assign) int response_result;
// 从发起请求，到收到返回时中间等待耗时，单位毫秒
@property (nonatomic,assign) int response_time;
/// 1:表示禁止广告，其他值或不存在均表示可以展示广告
@property (nonatomic, assign) HCForbiddenType adForbidden;
@property (nonatomic, copy, nullable) NSString *wnurl;
@property (nonatomic, assign) BOOL isWolong;

- (instancetype _Nonnull )initWithADPos:(NSArray<SQRHuiChuanHeaderAdPosInfoModel *> *_Nonnull)adPosInfo;
- (instancetype _Nonnull )initWithADPos:(NSArray<SQRHuiChuanHeaderAdPosInfoModel *> *_Nonnull)adPosInfo screenInfo:(SQRHuiChuanHeaderScreenInfoModel *_Nullable)screenModel;
/**
 *  构造方法
 *  ext_info: 扩展字段  目前有：
 *  {
 *    personalized_ad   (string)设置汇川禁止个性化广告,如果禁止就传0,   非0 或者不传，则开启个性化广告
 *  }
 */
- (instancetype _Nullable )initWithADPos:(NSArray<SQRHuiChuanHeaderAdPosInfoModel *> *_Nonnull)adPosInfo ext_info:(NSDictionary *_Nullable)ext_info;
/**
 *  构造方法
 *  ext_info: 扩展字段  目前有：
 *  {
 *    personalized_ad   (string)设置汇川禁止个性化广告,如果禁止就传0,   非0 或者不传，则开启个性化广告
 *  }
 */
- (instancetype _Nullable )initWithADPos:(NSArray<SQRHuiChuanHeaderAdPosInfoModel *> *_Nonnull)adPosInfo screenInfo:(SQRHuiChuanHeaderScreenInfoModel *_Nullable)screenModel ext_info:(NSDictionary *_Nullable)ext_info;

//设置adTest信息
- (void)setExpTags:(NSArray<SQRHuiChuanHeaderExpInfoModel *> *_Nullable)arr;
/// 执行请求
- (void)fetchAd;
//设置蹊径请求包名
- (void)setXijingAppName:(nullable NSString *)xijingAppName;


// 广告的一些初始化全局设置 ------------------------------------------------------

// 否个性化，优先级低于传入的ext_info里面的设置， 默认  @"1" 开启  @"0" 关闭   非必须
+(void)setPersonailzed:(NSString *_Nonnull)personalized;
// 请求头加密方式 2: RSA加密；不设置 或者0 默认不加密。
// 目前内部就2 这一种加密方式， 比外部传入的加密方式优先级低   非必须
+(void)setHeaderEncodeStyle:(int)encodeStyle;

// ----------------------------------------------------------------------



// UC双十一非标展位 ------------------------------------------------------
// 初始化
/**
 *  构造方法
 *  ext_info: 扩展字段  目前有：
 *  {
 *    personalized_ad   (string)设置汇川禁止个性化广告,如果禁止就传0,   非0 或者不传，则开启个性化广告
 *  }
 */
- (instancetype _Nonnull )initWithSlotId:(NSString *_Nonnull)slotId adType:(UCNonstandardAdType)adType ext_info:(NSDictionary *_Nullable)ext_info;
// 默认个性化开关是打开的
- (instancetype _Nonnull )initWithSlotId:(NSString *_Nonnull)slotId adType:(UCNonstandardAdType)adType;
// 预加载内存广告, 提前加载广告，包括广告下载，物料下载
// 此方法只支持 UCNonstandardAdPopType(首页poplayer), UCNonstandardAdMenuType(菜单栏气泡),这两种类型UI
-(void)preAdLoadWithRequestBlock:(void(^_Nullable)(NSDictionary * _Nullable dic))requestBlock
                   responseBlock:(void(^_Nullable)(NSDictionary * _Nullable dic))responseBlock;
// 返回一个渲染好的UI, 如果广告还没准备好，则返回的为nil
// 此方法只支持 UCNonstandardAdPopType(首页poplayer), UCNonstandardAdMenuType(菜单栏气泡),这两种类型UI
-(UIView *_Nullable)getAdViewWithFrame:(CGRect)frame
                            closeBlock:(void(^_Nullable)(NSDictionary * _Nullable dic))closeBlock
                            clickBlock:(void(^_Nullable)(NSDictionary * _Nullable dic))clickBlock
                      imageLoadedBlock:(void(^_Nullable)(BOOL isSuccess))imageLoadedBlock;
// 返回广告素材
// 此方法只支持 UCNonstandardAdBallType(个人中心悬浮小球)类型
-(void)getAdWithDelay:(float)delay
         requestBlock:(void(^_Nullable)(NSDictionary * _Nullable dic))requestBlock
        responseBlock:(void(^_Nullable)(NSDictionary * _Nullable adData))responseBlock;
// 判断广告数据时间是否失效，YES: 已失效
+(BOOL)adIsInvalidWithDate:(NSDate *_Nonnull)date;
// 展示打点
-(void)reportAdShowSpm:(NSDictionary *_Nonnull)dic;
// 点击打点
-(void)reportAdClickSpm:(NSDictionary *_Nonnull)dic;
// 调端打点（传入完整的广告信息）
-(void)reportAdClientJumpAction:(NSDictionary *_Nonnull)dic appcode:(NSInteger)appcode jumpType:(NSInteger)jump;
// 调端打点(传入scheme_feedback_url)
+(void)reportAdClientJumpActionWithFeedbackUrl:(NSString *_Nonnull)schemeFeedbackUrl appcode:(NSInteger)appcode jumpType:(NSInteger)jump scheme:(NSString *_Nullable)scheme ulk:(NSString *_Nullable)ulk;
// 汇川素材下载失败打点
+(void)reportAdImageLoadErrorSpm:(NSDictionary *_Nonnull)dic;
// ----------------------------------------------------------------------

/// 竞胜URL上报
/// - Parameters:
///   - winUrl: 竞胜上报url
///   - sessionId: 外部传入的sessionId
///   - price: 媒体竞价的二价(当智能营销SDK竞价胜出时，竞价队列中次高价ADN的出价 + 1分，例如次高ADN出价100分，二价就是101分), 单位：分/ecpm
+(void)reportAdWinUrl:(NSString *_Nonnull)winUrl sessionId:(NSString *_Nonnull)sessionId price:(int)price;

/// 接口透传数据处理
+(void)setPassthroughDataHandler:(id<SQRHuiChuanPassthroughHandlerDelegate>_Nonnull)handler;

+ (void)setKeepAliveTimeout:(int)keepAliveTimeout;
+ (void)setReqOptimizeEnable:(BOOL)reqOptimizeEnable;

@end

NS_ASSUME_NONNULL_END

@class SQRHuiChuanHeaderModel;
@protocol SQRHuiChuanAdFetcherDelegate <NSObject>
@optional
- (void)huiChuanAdFetcher:(SQRHuiChuanAdFetcher *_Nonnull)fetcher receieved:(id _Nonnull )data;
- (void)huiChuanAdFetcher:(SQRHuiChuanAdFetcher *_Nonnull)fetcher failed:(NSError*_Nonnull)error;
//发起请求时获取缓存广告主
- (NSString *_Nullable)advertiserForHuiChuanAdFetcher:(SQRHuiChuanAdFetcher *_Nonnull)fetcher;
//发起请求时获取bid回传数据
- (NSString *_Nullable)bidUploadDatasForHuiChuanAdFetcher:(SQRHuiChuanAdFetcher *_Nonnull)fetcher;

- (void)huiChuanAdFetcher:(id<HCRewardAdFetcherProtocol> _Nonnull)fetcher didReceieved:(SQRHuiChuanResponseModel *_Nonnull)data;
- (void)huiChuanAdFetcher:(id<HCRewardAdFetcherProtocol> _Nonnull)fetcher didFailed:(NSError*_Nonnull)error;
@end

@protocol SQRHuiChuanPassthroughHandlerDelegate <NSObject>

- (void)didReceiveData:(SQRHuiChuanResponseModel *_Nonnull)data;

@end

@interface SQRHuiChuanAdFetcher (SQRRegistParams)

// 初始化必须实现的代理   一些媒体端的设置
+ (void)registerHeaderDataSource:(id<SQRHuiChuanAdFetcherDataSource>_Nonnull)dataSource;
// 初始化可选代理  媒体端实现的一些方法 目前主要UC实现的方法
+ (void)registerSchemeManager:(id<SQRHuiChuanAdFetcherSchemeManager>_Nonnull)schemeManager;
// 初始化可选代理  媒体端实现请求头加密方法  比如 无线保镖加密
+ (void)registerDataEncoder:(id<SQRHCAdFetcherEncoder>_Nonnull)encoder;
@end

