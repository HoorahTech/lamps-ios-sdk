//
//  SdkConfig.h
//  SdkConfig
//
//  Created by zhangliuke on 2020/8/4.
//  Copyright © 2020 uc. All rights reserved.
//


#ifndef SdkConfig_h
#define SdkConfig_h

NS_ASSUME_NONNULL_BEGIN

/**
 *  请求价格不需要加密:
 */
extern int const TEST_MODE_PRICE_ENCRYPT;
/**
 * 是否加密
 * 不传则加密
 */
extern int const TEST_MODE_MEDIATION_ENCRYPT;
extern int const TEST_MODE_ADREQUEST_ENCRYPT;

/**
 * 是否根据country取广告资源
 *  不传则由用户ip取
 */
extern int const TEST_MODE_MEDIATION_FROM_COUNTRY;
extern int const TEST_MODE_ADREQUEST_FROM_COUNTRY;
extern int const TEST_MODE_PRICEREQUEST_FROM_COUNTRY;

/**
 * 使用mock的fetch config url
 */
extern int const TEST_MODE_MOCK_REQUEST;

extern const NSString* TEST_MODE_REQUEST_PARAMETER;

/**
 * 初始化传参
 */
extern int const INIT_ALL_KEY_VALUE_MAP      ;
extern int const INIT_APP_KEY                ;
extern int const INIT_UTDID                  ;
extern int const INIT_SVER                   ;
extern int const INIT_AID                    ;
extern int const INIT_CITY                   ;
extern int const INIT_PROVINCE               ;
extern int const INIT_COUNTRY                ;
extern int const INIT_IMG_LOADER             ;
extern int const INIT_SLOT_ID                ;
extern int const INIT_MODE                   ;
extern int const INIT_START_COUNT            ;
extern int const INIT_LANG_APP               ;
extern int const INIT_EV_AC                  ;
extern int const INIT_BID                    ;
extern int const INIT_COUNT                  ;
extern int const INIT_EMPTY_COUNT            ;
extern int const INIT_ERROR_CODE             ;
extern int const INIT_JSTAG                  ;
extern int const INIT_AD_STYLE               ;
extern int const INIT_CHANNEL                ;
extern int const INIT_TESTMODE               ;
extern int const INIT_USER_GROUP             ;
extern int const INIT_CLICK_HANDLER          ;
extern int const INIT_LOW_MACHINE            ;
extern int const INIT_VERSION_NAME           ;
extern int const INIT_NET_CONNECTOR          ;
extern int const INIT_NET_LIB_TYPE           ;
extern int const INIT_PLAYER_CREATOR         ;
extern int const INIT_MOCK_FETCH_CONFIG_URL  ;
extern int const INIT_TEST_DEVICES           ;
extern int const INIT_LONGTITUDE             ;
extern int const INIT_LATITUDE               ;
extern int const INIT_GPS_TIME               ;
extern int const INIT_AMAP_CODE              ;
extern int const INIT_CP                     ;
extern int const INIT_OAID                   ;

/**
 * 打点用参数
 */
extern int const LOG_MATCH_TIME              ;
extern int const LOG_USEFUL_IMG              ;
extern int const INIT_IMG_LOADER_STORAGE     ;
extern int const INIT_ADID                   ;
extern int const INIT_PROCESS_NAME           ;
extern int const INIT_HARDWARE_ACCELERATION  ;
extern int const SPLASH_IMG_ERROR_CODE       ;

typedef void(^NABidLogReporter)(NSDictionary *logInfo);

@interface SdkConfig : NSObject

- (NSString*) getAppKey;
- (NSString*) getSver;
- (NSString*) getAid;
- (NSString*) getUtdid;
- (NSString*) getChannel;
- (NSString*) getCity;
- (NSString*) getProvince;
- (NSString*) getCountry;
- (int) getNetLibType;
- (NSString*) getMode;
- (int) getTestMode;
- (NSString*) getStartCount;
- (NSString*) getLang;
- (NSString*) getBid;
- (NSString*) getCount;
- (BOOL) getRequestByORTB;
- (NSString*) getMockFetchConfigUrl;
- (NSString*) getTestDevice:(int)idInt;
- (NSString*) getOaid;
-(void) forceUpdateSlotKeyForDebug:(NSString*) key;

@end

#pragma mark - CD

@interface SdkConfig ()

@property (nonatomic, assign) BOOL adCrashProtectEnable;

/// 价格相同是否使用 hash 竞价，确保同步竞价的唯一性
@property (nonatomic, assign) BOOL hashBidEnable;

@property (nonatomic, assign) BOOL disableAdOptimization;

@property (nonatomic, assign) BOOL enableBuFastUA;

@property (nonatomic, assign) BOOL banBuCrashEnable;

@property (nonatomic, assign) BOOL banBuWebViewHook;

@property (nonatomic, assign) BOOL enableBuOfflineTypeNone;

/// 端计算开关
@property (nonatomic, assign) BOOL enableNoahDai;

/// UIApplicationDidReceiveMemoryWarningNotification userInfo 内存警告过滤标志
/// 如果媒体传了对应的 memoryWarningFilterKey ，则忽略带有该标志的内存警告通知
@property (nonatomic, strong) NSString *memoryWarningFilterKey;

/// UC 商增一体日志上报
@property (nonatomic, assign) BOOL reportBidLogEnbale;
@property (nonatomic, copy) NABidLogReporter bidLogReporter;

@property (nonatomic, assign) BOOL bdSplashAJumpFixEnable;
@property (nonatomic, assign) BOOL bdSplashShowCheckEnable;

@property (nonatomic, assign) BOOL exloadCacheOpt;
/// 三方开屏调端拦截开关
@property (nonatomic, assign) BOOL splashOpenAppInterceptEnable;

@end

#pragma mark - App info

@interface SdkConfig ()

- (nullable NSString *)getUserId;

- (nullable NSString *)dateVersion;

- (nullable NSDictionary *)deviceMotionInfo;

- (nullable NSString *)appVersion;

- (nullable NSString *)sn;

- (nullable NSString *)ucAbtestTag;

- (nullable NSArray *)ucAbtestTagFillter;

@end

#endif /* SdkConfig_h */

NS_ASSUME_NONNULL_END
