//
//  NoahSplashAdListener.h
//  NoahSDK
//
//  Created by Reus on 2020/11/18.
//  Copyright © 2020 zhongyang.ywx. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SplashAd, AdError, RequestInfo;

NS_ASSUME_NONNULL_BEGIN

@protocol NoahSplashAdListener <NSObject>

@optional
/**
 *  开屏广告错误回调
 */
- (void)onSplashAdError:(AdError *)error DEPRECATED_MSG_ATTRIBUTE("use onSplashAdLoadFail:error:");
- (void)onSplashAdLoadFail:(RequestInfo *)reqInfo error:(nullable AdError *)error;

/**
 *  开屏广告加载完成回调
 */
- (void)onSplashAdLoaded:(SplashAd *)ad;

/**
 *  开屏广告展示回调
 */
- (void)onSplashAdShown:(SplashAd *)ad;

/**
 *  开屏广告点击回调
 */
- (void)onSplashAdClicked:(SplashAd *)ad;

/**
 *  开屏广告点击跳过回调
 */
- (void)onSplashAdSkip:(SplashAd *)ad;

/**
 *  开屏广告播放完成回调
 */
- (void)onSplashAdTimeOver:(SplashAd *)ad;

/**
 *  开屏广告将要关闭回调
 */
- (void)onSplashAdWillClosed:(SplashAd *)ad;

/**
 *  开屏广告关闭回调
 */
- (void)onSplashAdClosed:(SplashAd *)ad;

#if NA_EXTERNAL == 0
/**
 *  TopView点击
 */
-(void)onSplashTopViewClick:(SplashAd *)ad;
/**
 *  TopView关闭
 */
-(void)onSplashTopViewClosed:(SplashAd *)ad;
/**
 *  TopView倒计时
 */
-(void)onSplashTopViewTimeOver:(SplashAd *)ad;

/**
 *   点击以后全屏广告页已经关闭
 */
- (void)onSplashAdDidDismissFullScreenModal:(SplashAd *)ad;
#endif
@end

NS_ASSUME_NONNULL_END
