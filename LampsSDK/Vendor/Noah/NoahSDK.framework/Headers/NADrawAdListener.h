//
//  NADrawAdListener.h
//  NoahSDK
//
//  Created by zhongyang on 2022/4/13.
//  Copyright © 2022 Alibaba Inc. All rights reserved.
//

#if NA_EXTERNAL == 0

#import <Foundation/Foundation.h>


@class AdError;
@class NADrawAd;


NS_ASSUME_NONNULL_BEGIN

@protocol NADrawAdListener <NSObject>

@optional
/**
 *  Draw广告错误回调
 */
-(void)onDrawAdError:(AdError *)error;
/**
 *  Draw广告加载完成回调
 */
-(void)onDrawAdLoaded:(NADrawAd *)ad;
/**
 *   多条Draw广告加载完成回调
 */
-(void)onMultiDrawAdLoaded:(NSArray<NADrawAd*> *)ads;
/**
 *  Draw广告展示回调
 */
-(void)onDrawAdShown:(NADrawAd *)ad;
/**
 *  Draw广告结束回调
 */
-(void)onDrawAdClosed:(NADrawAd *)ad;
/**
 *  Draw广告点击回调
 */
-(void)onDrawAdClicked:(NADrawAd *)ad;
/**
 *  Draw广告播放开始回调
 */
-(void)onDrawAdVideoPlayStart:(NADrawAd *)ad;
/**
 *  Draw广告播放完毕回调
 */
-(void)onDrawAdVideoPlayFinish:(NADrawAd *)ad;

@end

NS_ASSUME_NONNULL_END

#endif
