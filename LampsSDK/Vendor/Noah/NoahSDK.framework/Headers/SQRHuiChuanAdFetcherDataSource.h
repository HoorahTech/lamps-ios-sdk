//
//  SQRHuiChuanRequestHeaderDataSource.h
//  ShuQiHCSDK
//
//  Created by Satte on 2020/5/28.
//  Copyright © 2020 ShuQi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 协议文件：需要外部提供请求参数、行为
@protocol SQRHuiChuanAdFetcherDataSource <NSObject>

/// 广告位信息数组（目前只支持一个，多个会有问题）     非必须
- (NSString *)networkStatus; // 期望值： Unknown / 2G / 3G / 4G / Wifi
/// 非必须
- (BOOL)isNetReachable;
/// 必须
- (BOOL)isNetReachableViaWifi;
#pragma mark - 设备信息
/// 备选设备ID，仅IOS 6+有效 ,用于ios设备的用户识别和兴趣投放      非必须
- (NSString *)idfa;
/// 设备型号（需要归一化所有的设备型号）       非必须
- (NSString *)device;
/// 操作系统，枚举选项， android/ios/wp（默认ios） 用于操作系统定向投放       非必须
- (NSString *)os;
/// 操作系统版本（需要归一化所有的设备型号）            非必须
- (NSString *)osv;
/// mac 地址（小写归一化）           非必须
- (NSString *)mac;
///  网络类型 枚举值 Wi-Fi/2G/3G/4G/Unknown            非必须
- (NSString *)access;
/// 服务端转发必须填充该字段，客户端直连不需要填充，用于用户地域识别，广告地域投放和反作弊      非必须
- (NSString *)client_ip;
/// 手机品牌                    非必须
- (NSString *)brand;
/// 新广告标识符协议       非必须
- (NSString *)aaid;


#pragma mark - APP 信息
/// 平台分类 枚举值 android/iphone/other      必须实现
- (NSString *)fr;
/// 阿里UTDID，淘内强烈建议填充          非必须
- (NSString *)utdid;
/// 取bundle id（小写归一化）（对于ios直接取appstore上的包名） 必须实现
- (NSString *)pkg_name;
/// 版本号                               必须实现
- (NSString *)pkg_ver;
/// 应用名称（小写归一化）（对于ios直接取appstore上的app名称）  必须实现
- (NSString *)app_name;
///  User Agent，无法填充可以填空串             非必须
- (NSString *)ua;


// 都已同步的开关和操作 -----------------------------------------------------

/// 必须实现
- (void)loadURL:(NSString *)url completion:(void(^)(id retData,NSError *error))handler;

@optional

/// 新广告标识符协议，包含两个版本，广告协会规定         非必须
- (NSString *)cValue;

- (BOOL)webpEnable;

- (BOOL)adShowEndReportEnable;
- (void)adShowEndWithSlot:(NSString *)slot pid:(NSString *)pid showEndTime:(NSTimeInterval)endTime showDur:(NSTimeInterval)dur;

// 目前品牌和兜底的预加载使用到
// 图片下载
- (void)loadImageWithURL:(NSString *_Nonnull)url completed:(void(^_Nullable)(UIImage * _Nullable image, NSError * _Nullable error, NSURL * _Nullable imageURL))completedBlock;
// 文件下载，如视频文件
- (void)loadFileWithURL:(NSString *_Nonnull)url targetPath:(NSURL *_Nonnull)targetPath completed:(void(^_Nullable)(NSError * _Nullable error, NSURL * _Nullable filePath))completedBlock;

// noah中实现-----------------------------------------------------

// 上传RSA加密失败接口 目前有 name:加密方法 error:错误信息
-(void)reportRsaFail:(NSDictionary *)dic;



// 目前UC上开关 需要noah也同步下发开关实现-----------------------------------------------------

/// 获取开屏视频延迟多久不播放，就放弃，不实现或者<=0则不实现此功能，单位毫秒     非必须
- (float)getSplashVideoDelayTime;
/// 设置局部响应功能是否生效    (默认NO，全局可点)    非必须
- (BOOL)disableAllSplashclickSwitch;
/// 开屏弹窗上滑dialog 预加载黑名单cd    以 英文 , 分割     非必须，  默认没有
- (NSString *)splashPreRenderBlackHosts;
/// 开屏弹窗上滑预加载cd  @"0" 不预加载  @"1" 预加载    默认预加载
- (nullable NSString *)splashPreRender;
/// 摇一摇加速器设置    默认有重力加速度大约为10， 所以小于等于10 则用默认值 13    非必须
- (float)getShakeAccelertion;
/// 滑动解锁 距离阈值 默认50,默认必须大于0,小于屏幕宽度
- (float)getScrollUnlockDistance;
/// 小程序兜底链接跳转开关
- (BOOL)enableUseMiniAppId;
/// 四面八方滑动开关
- (BOOL)enableMultiSlide;
/// 四面八方滑动解锁 距离阈值 默认100,默认必须大于0,小于屏幕宽度
- (float)getMultiSlideDistance;
/// 四面滑动区域占开屏区域百分比 默认100
- (float)getMultiSlideAreaPercent;

// 目前UC上有 noah不需实现-----------------------------------------------------

// -----------操作类
/// arg1:事件类型,NSString
/// result: 页面加载过程结果,NSString
/// cost: 耗时,NSString
/// 上滑开屏 UT打点
- (void)statHuiChuanLoad:(NSDictionary *)data;
//微信分享， 非必须
- (void)onShareWeiXin:(NSDictionary *)params;
/// 接口url      非必须
- (nullable NSString *)getHuichunApiUrl;
/// 调端打点
- (void)statAppCall:(NSDictionary *)dic;
// -----------开关类
// 汇川品牌兜底预加载，是否打开了联投
- (BOOL)ucSplashAdShiftEnable;
// 汇川品牌兜底预加载，是否预加载联投视频
- (BOOL)ucHcHorizontalVideoAdPrefetch;
/// 外部实现的加密，比如 无线保镖加密           默认返回no
- (BOOL)useWSG;
/// 设置汇川banner是否可度配置     目前只有UC 里面通过人群去拉取不同的配置，默认NO
- (BOOL)enableHcBannerConfig;
/// < 运营商 枚举值 Unknown/ChinaMobile/ChinaUnicom/ChinaTelecom/ChinaTietong        非必须
- (NSString *)carrier;

/// 开屏，摇一摇功能是否关闭，非必须
- (BOOL)splashShakeIsClose;

/// 开屏，旋转功能是否关闭，非必须
- (BOOL)splashShakeOptIsClose;
// 转一转  兜底 1;35;1  【1.是否开启旋转，2.旋转角度，3.是否可点】
- (NSString *)splashShakeTurnControl;
// 扭一扭  兜底 1;35;1  【1.是否开启旋转，2.旋转角度，3.是否可点】
- (NSString *)splashShakeTwistControl;
// 前后倾  兜底 1;35;1  【1.是否开启旋转，2.旋转角度，3.是否可点】
- (NSString *)splashShakeFallControl;

// 转一转(分级策略)
- (NSString *)splashShakeTurnControlLevel;

// 转一转(分级策略)
- (NSString *)splashShakeTurnControlLevelAdsource;
// 转一转(分来源)
- (NSString *)splashShakeTurnControlAdSource;
// 扭一扭(分来源)
- (NSString *)splashShakeTwistControlAdSource;
// 前后倾(分来源)
- (NSString *)splashShakeFallControlAdSource;

/// 开屏，上滑样式可滑区域，=0 低区域，=1 中区域，=2 全屏区域，非必须
- (NSInteger)verticalSlideAreaType;
/// 开屏，横滑样式可滑区域，=0 低区域，=1 中区域，=2 全屏区域，非必须
- (NSInteger)horizontalSlideAreaType;
/// 开屏，上滑+点击 可滑区域，=0 低区域，=1 中区域，=2 全屏区域，非必须
- (NSInteger)slideAndClickAreaType;
/// 开屏，上滑+落地页 可滑区域，=0 低区域，=1 中区域，=2 全屏区域，非必须
- (NSInteger)slideDialogAreaType;
// UC汇川，是否打开了暗投
- (BOOL)ucIflowAdShiftEnable;
/// 是否允许uclink调起微信，默认为YES
- (BOOL)uclinkWeixinIsEnable;
/// 调用UC的ulog
- (void)uLogInfo:(NSString *)tag msg:(NSString *)msg;
/// 调用UC的UT打点
/// arg1:事件类型,NSString （必备，为空则不会进行打点）
/// eventId: 事件ID,NSString（必备，为空则不会进行打点）
/// 其他信息根据需要添加到params中
- (void)uStat:(NSDictionary *)params;
/// 在webView进程中断时，是否要进行reload
- (BOOL)webViewCanReloadWhenProcessDidTerminate;
/// webView加载链路是否进行UT打点 （默认为YES）
- (BOOL)webViewCanUTStat;
/// webView加载链路是否进行ULog打点 （默认为YES）
- (BOOL)webViewCanULog;
/// 回调出去给媒体APP自己根据需要打开媒体本身的落地页
/// @param url 落地页
/// @param videoUrl 视频播放地址
- (void)openUrl:(NSString * _Nonnull)url videoUrl:(NSString * _Nullable)videoUrl;

- (NSString *)getWechatRegisterAppId;
- (NSString *)getWechatRegisterUniversalLink;

// 开屏背景图加载方式
// 0:加载前链接ecode(默认，目前线上方式，处理链接含有中文，导致加载失败)
// 1:加载前链接decode(处理链接部分编码异常问题，导致加载失败)+ecode
// 2:不做任何处理
- (int)getSplashBgLoadMode;
// 开屏背景图展示方式
// 0:背景图下载失败也展示开屏(默认，目前线上方式)
// 1:下载成功才展示开屏
- (int)getSplashBgShowMode;

/// 设备初始化时间
- (NSString *)dit;
/// 系统更新时间
- (NSString *)sut;
/// 系统启动时间
- (NSString *)sst;

// fetchad参数拼接是否强非主线程
- (BOOL)fetchadParamForceNoMainThread;

// 非标fetchad是否强子线程
- (BOOL)nonstandardFetchadForceSubThread;

// 是否支持广告落地页点击坐标点回传到点击链接中,uc主客中默认传入1，noah中默认0
- (BOOL)needAdReClickUrlParams;


// 红包雨，控制配置，0:关闭；1:开启展示且可点击；2：仅开启展示，不支持点击； 默认1
- (int)redPackRainCtrlType;

// 是否支持背景图，适配屏幕分辨率，默认YES支持
- (BOOL)imageCanAdjustScreenScale;

// 是否支持广告点击检测坐标点回传到点击检测链接中,uc主客中默认传入1，noah中默认0
- (BOOL)needAdReClickDetectionUrlParams;

/// 是否开启落地页展示优化（默认：NO）
- (BOOL)webVcShowOptEnable;

/// 蹊径上报配置
- (nullable NSString *)getXijingAppName;

- (BOOL)enableXijingWithSlotKey:(NSString *)slotKey;

//蹊径应用市场slot
- (nullable NSString *)getXijingAppStoreSlotWithSlotKey:(NSString *)slotKey;

//蹊径调端slot
- (nullable NSString *)getXijingJumpAppSlotWithSlotKey:(NSString *)slotKey;

//nativead协议新增用户分层条件
- (nullable NSDictionary *)userTagDictWithSlotKey:(NSString *)slotKey;

/// 是否禁止获取位置信息（默认：NO）
- (BOOL)forbidGetLocationInfo;

///是否开启调端上报
- (BOOL)enableAppLifeCycleUpload;

///调端上报url
- (nullable NSString *)getAppLifeCycleUploadURL;

- (BOOL)isTurlSupportAppStoreLink;

///落地页UA是否添加HCSDK标记
- (BOOL)enableAddFlagForUA;

- (NSString *)realtimeUA;

- (int)maxAdLoadCount;
- (BOOL)adLoadOpt;

- (nullable UIWindow *)noahKeyWindow;

- (BOOL)fillGpsOpt;

- (BOOL)enableHiddenNavgationBar;

/// 落地页是否在 viewWillAppear 强制隐藏导航栏、viewWillDisappear 恢复（默认关闭）
- (BOOL)enableLandingPageForceHiddenNavBar;

- (NSString *)orderAesEncryptKey;

- (BOOL)splashClickBannerOpt;

- (BOOL)enableDestroyShakeViewFix;

@end

NS_ASSUME_NONNULL_END
