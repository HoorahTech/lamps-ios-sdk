//
//  NoahCustomNativeAdDelegate.h
//  NoahSDK
//
//  Created by zhongyang on 2022/2/25.
//  Copyright © 2022 Alibaba Inc. All rights reserved.
//

#if NA_EXTERNAL == 0

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@protocol NoahCustomNativeAdProtocol;

@protocol NoahCustomNativeAdDelegate <NSObject>

/**
 *  custom原生广告素材加载  成功 error为空
 */
- (void)customNativeAdDidLoad:(id<NoahCustomNativeAdProtocol>)nativeAd error:(NSError* _Nullable)error;
/**
 *  custom原生广告点击回调
 */
- (void)customNativeAdClicked:(id<NoahCustomNativeAdProtocol>)nativeAd;
/**
 *  custom原生广告曝光回调
 */
- (void)customNativeAdExposured:(id<NoahCustomNativeAdProtocol>)nativeAd;

@end

NS_ASSUME_NONNULL_END

#endif
