//
//  NABaseAd+Private.h
//  NoahSDK
//
//  Created by zzyong on 2025/7/18.
//  Copyright © 2025 Alibaba Inc. All rights reserved.
//

#ifndef NABaseAd_Private_h
#define NABaseAd_Private_h

#import <UIKit/UIKit.h>
#import "NABaseAd.h"
#import "NAAdBidProtocol.h"
#import "NAQueryRewardCodeDefine.h"
@protocol IAdPreloadListener;
@class RequestInfo, AdContext, AdAdapter, SdkAssets;


NS_ASSUME_NONNULL_BEGIN

@interface NABaseAd ()

@property(nonatomic,strong)AdAdapter * mAdapter;
@property(nonatomic,strong)SdkAssets * mSdkAssets;

-(instancetype)initWithAd:(AdAdapter *)ad;
-(NSInteger)getAdType;
-(void)destroy;
+(BOOL)isReady:(NSString *)slotKey adContext:(AdContext *)adContext;
+(void)preloadAd:(UIViewController * _Nullable)window
       adContext:(AdContext *)adContext
          adType:(int)adType
         slotKey:(NSString *)slotKey
     requestInfo:(nullable RequestInfo*)info
        listener:(nullable id<IAdPreloadListener>)listener;
+ (void)statAppCallDicWithCid:(nullable NSString *)cid Sid:(nullable NSString *)sid eventType:(NSUInteger)eventType Url:(NSString *)url callType:(NSUInteger)callType callResult:(BOOL)result jumpType:(NSUInteger)jumpType linkType:(NSUInteger)linkType sceneType:(NSUInteger)sceneType;
+ (void)statAppCallDicWithCid:(nullable NSString *)cid Sid:(nullable NSString *)sid eventType:(NSUInteger)eventType Url:(NSString *)url callType:(NSUInteger)callType callResult:(BOOL)result jumpType:(NSUInteger)jumpType linkType:(NSUInteger)linkType sceneType:(NSUInteger)sceneType dspId:(nullable NSString *)dspId adSourceType:(nullable NSString *)sourceType otherId:(nullable NSString *)otherId accountId:(nullable NSString *)accountId;
+ (void)statAppDownloadIfNeed:(nullable NSString *)cid Sid:(nullable NSString *)sid eventType:(NSUInteger)eventType Url:(NSString *)url sceneType:(NSUInteger)sceneType;
- (NSString *)getAdnPlacementId;
- (int)getAdnId;
- (NSString*)getAdnName;
- (BOOL)isAdExpire;
- (NSString*)getAdvertiserName;
- (int)getRewardType;
- (int)getRewardTaskType;
- (int)getRewardTaskConvertType;
- (int)getRewardTaskSugTime;
- (int)getRewardPauseTime;
- (NSString *)getRewardTaskText;
- (NSString *)getRewardButtonText;
- (NSString *)getReturnPromptText;
- (int)getRewardMomentType;
- (RequestInfo *)getRequestInfo;
+ (void)queryAdRewardResultWithSlotList:(NSArray *)slotKeyList requestInfo:(RequestInfo* _Nullable) requestInfo completion:(void(^)(NSDictionary * _Nullable resultInfo, NARewardQueryCode errCode))completion;

@end

NS_ASSUME_NONNULL_END

#endif /* NABaseAd_Private_h */
