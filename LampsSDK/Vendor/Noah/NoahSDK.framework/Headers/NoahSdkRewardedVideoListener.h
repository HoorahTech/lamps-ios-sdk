//
//  NoahSdkRewardedVideoListener.h
//  NoahSDK
//
//  Created by zhongyang on 2020/12/4.
//  Copyright © 2020 zhongyang.ywx. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, NARewardAdvanceAdStyle) {
    NARewardNoAdvanceAdStyle                 = 0,
    NARewardAdvanceAdDownloadStyle           = 18,
};

@class AdError, RewardedVideoAd;

NS_ASSUME_NONNULL_BEGIN

@protocol NoahSdkRewardedVideoListener <NSObject>

@optional
/**
 *  激励视频广告错误回调
 */
- (void)onReVidoAdError:(AdError *)error DEPRECATED_MSG_ATTRIBUTE("use onReVidoAdLoadFail:error:");
- (void)onReVidoAdLoadFail:(RequestInfo *)reqInfo error:(nullable AdError *)error;

/**
 *  激励视频广告加载完成回调
 */
- (void)onReVidoAdLoaded:(RewardedVideoAd *)ad;

/**
 *  激励视频广告展示回调
 */
- (void)onReVidoAdShown:(RewardedVideoAd *)ad;

/**
 *  激励视频广告结束回调
 */
- (void)onReVidoAdClosed:(RewardedVideoAd *)ad;

/**
 *  激励视频广告点击回调
 */
- (void)onReVidoAdClicked:(RewardedVideoAd *)ad;

/**
 *  激励视频广告播放开始回调
 */
- (void)onReVidoStart:(RewardedVideoAd *)ad;

/**
 *  激励视频广告播放结束回调
 */
- (void)onReVidoEnd:(RewardedVideoAd *)ad;

/**
 *  激励视频广告获得激励回调
 */
- (void)onReVidoRewarded:(RewardedVideoAd *)ad;

/**
 *  激励视频广告获得激励回调（新，接入进阶发奖后建议使用这个方法,rewardInfo中包含奖励信息）
 *  rewardInfo：{
 *      slotKey:广告位ID
 *      adnid：广告来源Id
 *      rewardType：奖励类型
 *      sid：请求id
 *  }
 */
- (void)onReVidoRewarded:(RewardedVideoAd *)ad rewardInfo:(NSDictionary *)rewardInfo;

@end

NS_ASSUME_NONNULL_END
