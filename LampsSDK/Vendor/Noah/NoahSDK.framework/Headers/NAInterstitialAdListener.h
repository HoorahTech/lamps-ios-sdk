//
//  NAInterstitialAdListener.h
//  NoahSDK
//
//  Created by chenlei on 2025/3/31.
//  Copyright © 2025 Alibaba Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AdError, NAInterstitialAd, RequestInfo;

NS_ASSUME_NONNULL_BEGIN

@protocol NAInterstitialAdListener <NSObject>

@optional
/**
 *  插屏广告加载错误
 */
- (void)onInterstitialAdError:(AdError *)error DEPRECATED_MSG_ATTRIBUTE("use onInterstitialAdLoadFail:error:");
- (void)onInterstitialAdLoadFail:(RequestInfo *)reqInfo error:(nullable AdError *)error;

/**
 *  插屏广告加载完成
 */
- (void)onInterstitialAdLoaded:(NAInterstitialAd *)ad;

/**
 *  插屏广告展示
 */
- (void)onInterstitialAdShown:(NAInterstitialAd *)ad;

/**
 *  插屏广告点击
 */
- (void)onInterstitialAdClicked:(NAInterstitialAd *)ad;

/**
 *  插屏广告关闭
 */
- (void)onInterstitialAdClosed:(NAInterstitialAd *)ad;

@end

NS_ASSUME_NONNULL_END
