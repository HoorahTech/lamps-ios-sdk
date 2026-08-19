//
//  NoahCustomSplashAdDelegate.h
//  NoahSDK
//
//  Created by zhongyang on 2021/12/24.
//  Copyright © 2021 Alibaba Inc. All rights reserved.
//

#if NA_EXTERNAL == 0

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN


@protocol NoahCustomSplashAdProtocol;

@protocol NoahCustomSplashAdDelegate <NSObject>
/**
 *  开屏广告素材加载成功
 */
- (void)customSplashAdDidLoad:(id<NoahCustomSplashAdProtocol>)splashAd;
/**
*  数据请求失败
*/
- (void)customSplashAdLoadFail:(id<NoahCustomSplashAdProtocol>)splashAd error:(NSError*)error;
/**
 *  开屏广告点击回调
 */
- (void)customSplashAdClicked:(id<NoahCustomSplashAdProtocol>)splashAd;
/**
 *  开屏广告展示
 */
- (void)customSplashAdShow:(id<NoahCustomSplashAdProtocol>)splashAd;
/**
 *  开屏广告曝光回调
 */
- (void)customSplashAdExposured:(id<NoahCustomSplashAdProtocol>)splashAd;
/**
 *  开屏广告将要关闭回调
 */
- (void)customSplashAdWillClosed:(id<NoahCustomSplashAdProtocol>)splashAd;
/**
 * 开屏广告倒计时结束回调
 */
- (void)customSplashAdTimeOver:(id<NoahCustomSplashAdProtocol>)splashAd;
/**
*  开屏广告点击跳过回调
*/
- (void)customSplashAdDidClickSkip:(id<NoahCustomSplashAdProtocol>)splashAd;
/**
 *  开屏广告关闭回调
 */
- (void)customSplashAdClosed:(id<NoahCustomSplashAdProtocol>)splashAd;
/**
 *  点击以后全屏广告页已经关闭回调
 */
- (void)customSplashAdDidDismissFullScreenModal:(id<NoahCustomSplashAdProtocol>)splashAd;

@end

NS_ASSUME_NONNULL_END

#endif
