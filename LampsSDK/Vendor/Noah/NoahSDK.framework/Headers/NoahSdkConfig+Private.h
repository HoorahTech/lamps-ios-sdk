//
//  NoahSdkConfig+Private.h
//  NoahSDK
//
//  Created by zzyong on 2025/7/21.
//  Copyright © 2025 Alibaba Inc. All rights reserved.
//

#ifndef NoahSdkConfig_Private_h
#define NoahSdkConfig_Private_h

#import "NoahSdkConfig.h"
#import "NAAppInfoDataSource.h"

NS_ASSUME_NONNULL_BEGIN

// Key值
FOUNDATION_EXTERN NSString * const kSplashUserInfo;
FOUNDATION_EXTERN NSString * const kSplashHotReqInterval;
FOUNDATION_EXTERN NSString * const kSplashShowInterval;

@interface NoahSdkConfig ()

@property (nonatomic, strong) NSMutableDictionary *mOptions;

// 实时屏蔽保护
@property (nonatomic, assign) BOOL rtAdBlockEnable;
@property (nonatomic, strong) NSArray *rtAdInitBlackList;
@property (nonatomic, strong) NSArray *rtAdSendBlackList;

@property (nonatomic, assign) BOOL tanxFileBlockFixEnable;
@property (nonatomic, assign) BOOL banKsCacheProtocol;
@property (nonatomic, assign) BOOL jdAsyncLoadCacheEnable;
@property (nonatomic, assign) BOOL enableAdConfigProtector;
@property (nonatomic, assign) BOOL enableBidInfoUpload;
@property (nonatomic, strong) NSArray<NSString *> *forceOnlineSlots;
@property (nonatomic, weak) id<NAAppInfoDataSource> appInfoDataSource;

// adn黑名单，传入adnid黑名单，可以控制Noah不使用某些adn。
// 此处传入的黑名单，是全局的控制，所有的请求都受控这个黑名单
// 示例：@[@"1"], 此示例表示禁用汇川 adn
@property (nonatomic, strong) NSArray<NSString *> *blockAdnList;

// 是否禁止个性化广告推荐，YES 表示关闭个性化，默认 NO
@property (nonatomic, assign) BOOL forbidPersonalizedAd;

-(NoahSdkConfig *)init:(NSMutableDictionary*)p;
-(void)setAppKeyValue:(NSString *)value;
-(void)setUtdid:(NSString *)value;

@property (nonatomic, assign) BOOL baiduNativeAdLoadAsync;
@property (nonatomic, assign) BOOL gdtNativeAdLoadAsync;
@property (nonatomic, assign) BOOL ksNativeAdLoadAsync;
@property (nonatomic, assign) BOOL csjNativeAdLoadAsync;
@property (nonatomic, assign) BOOL tanxNativeAdLoadAsync;

-(void)setHcSdkConfigWithKey:(NSString *)key value:(NSObject *)value;
-(id)getHcSdkConfigWithKey:(NSString *)key;
-(id)getHcSdkConfigWithKey:(NSString *)key slotId:(nullable NSString *)slotId;
-(BOOL)appSupportTurnPage:(int)adnId;
-(nullable NSDictionary *)locationInfo;

// 避免UC修改UserAgent
@property (nonatomic, assign) BOOL ucUserAgentImmutable;

@end

NS_ASSUME_NONNULL_END

#endif /* NoahSdkConfig_Private_h */
