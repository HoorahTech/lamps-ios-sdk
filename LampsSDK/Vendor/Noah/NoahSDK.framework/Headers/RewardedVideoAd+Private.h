//
//  RewardedVideoAd+Private.h
//  NoahSDK
//
//  Created by zzyong on 2025/7/18.
//  Copyright © 2025 Alibaba Inc. All rights reserved.
//

#ifndef RewardedVideoAd_Private_h
#define RewardedVideoAd_Private_h

#import "RewardedVideoAd.h"
#import "NAQueryRewardCodeDefine.h"
#import "NoahSdkRewardedVideoListener.h"

@protocol NoahSdkRewardedVideoListener, IAdPreloadListener;
@class RequestInfo;

typedef NS_ENUM(int, NAHcRewardAdvanceAdType) {
    NAHcRewardAdvanceAdTypeError              = -1,
    NAHcRewardAdvanceAdTypeNone               = 0,
    NAHcRewardAdvanceAdTypeDownLoad           = 3,
    NAHcRewardAdvanceAdTypeOrder              = 4,
    NAHcRewardAdvanceAdTypeConsulting         = 5, ///< 咨询
};


NS_ASSUME_NONNULL_BEGIN

@interface RewardedVideoAd ()

/// 广告落地页控制器
@property(nonatomic, weak) UIViewController *adViewController;

- (void)show;

/**
 *   加载广告
 */
+ (void)getAdWithSlot:(NSString *)slotKey requestInfo:(RequestInfo* _Nullable) requestInfo listener:(id<NoahSdkRewardedVideoListener>)listener controller:(nullable UIViewController *)controller;


+ (void)getAdWithSlot:(NSString *)slotKey listener:(id<NoahSdkRewardedVideoListener>)listener controller:(UIViewController *)controller;

/**
 *  异步查奖（暂时只针对tanx）
 *   resultInfo 奖励信息，可为空
 *   errCode 查看  NAQueryRewardCodeDefine.h
 *   此方法后续不再维护，建议使用queryAdRewardResultWithSlot: requestInfo: completion:
 */
+ (void)queryAdRewardResultWithSlot:(NSString *)slotKey completion:(void(^)(NSDictionary * _Nullable resultInfo, NARewardQueryCode errCode))completion;


/**
 *  异步查奖
 *   resultInfo 奖励信息，可为空
 *   errCode 查看  NAQueryRewardCodeDefine.h
 *   通过requestInfo中的enableAsyncQueryReward控制
 *   enableAsyncQueryReward为YES：针对所有adn生效，内部缓存奖励信息，需要调用消费接口rewardConsumeSuccessWithSlot: rewardSuccessId: completion: 核销奖励信息
 *   enableAsyncQueryReward为NO：只针对TANX广告查奖，不缓存奖励信息，不需要调用消费接口
 */
+ (void)queryAdRewardResultWithSlot:(NSString *)slotKey requestInfo:(RequestInfo* _Nullable) requestInfo completion:(void(^)(NSDictionary * _Nullable resultInfo, NARewardQueryCode errCode))completion;



//消费接口，发奖完成删除缓存内奖励信息
+ (void)rewardConsumeSuccessWithSlot:(NSString *)slotKey rewardSuccessId:(NSString *)successId completion:(void(^)(BOOL success))completion;

- (NSMutableDictionary*)getBidMessage;

- (BOOL)isTanxAdnvancedAd;

- (NAHcRewardAdvanceAdType)getHcAdvanceType;

- (NSString *)getTanxSessionId;

@end

NS_ASSUME_NONNULL_END

#endif /* RewardedVideoAd_Private_h */
