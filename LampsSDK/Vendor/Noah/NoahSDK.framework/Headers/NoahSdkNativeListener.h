//
//  NoahSdkNativeListener.h
//  NoahSDK
//
//  Created by Reus on 2020/12/3.
//  Copyright © 2020 zhongyang.ywx. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AdError, NativeAd, RequestInfo;

NS_ASSUME_NONNULL_BEGIN

@protocol NoahSdkNativeListener <NSObject>

@optional

/**
 *   单条原生广告加载完成回调
 */
- (void)onNativeAdLoaded:(NativeAd *)ad DEPRECATED_MSG_ATTRIBUTE("use onNativeAdDidLoad:");
- (void)onNativeAdDidLoad:(NSArray<NativeAd *> *)nativeAds;

/**
 *   原生广告错误回调
 */
- (void)onNativeAdError:(AdError *)error DEPRECATED_MSG_ATTRIBUTE("use onNativeAdLoadFail:error:");
- (void)onNativeAdLoadFail:(RequestInfo *)reqInfo error:(nullable AdError *)error;

/**
 *   原生广告展示回调
 */
- (void)onNativeAdShown:(NativeAd *)ad;

/**
 *   原生广告点击回调
 */
- (void)onNativeAdClick:(NativeAd *)ad;

#if NA_EXTERNAL == 0
/**
 *   多条原生广告加载完成回调
 */
-(void)onMultiNativeAdLoaded:(NSArray<NativeAd*> *)ads;
#endif
/**
 *   原生广告事件回调
 */
-(void)onNativeAdEvent:(NativeAd *)ad eventId:(int)eventId ext:(nullable id)extInfo;

@end

NS_ASSUME_NONNULL_END
