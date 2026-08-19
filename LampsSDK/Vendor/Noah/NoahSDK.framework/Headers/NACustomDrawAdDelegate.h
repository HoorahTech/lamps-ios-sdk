//
//  NACustomDrawAdDelegate.h
//  NoahSDK
//
//  Created by zhongyang on 2022/4/13.
//  Copyright © 2022 Alibaba Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#if NA_EXTERNAL == 0

NS_ASSUME_NONNULL_BEGIN

@protocol NACustomDrawAdProtocol;


@protocol NACustomDrawAdDelegate <NSObject>

/**
 *  draw广告素材加载  成功 error为空
 */
- (void)customDrawAdDidLoad:(id<NACustomDrawAdProtocol>)drawAd error:(NSError* _Nullable)error;
/**
 *  draw广告点击回调
 */
- (void)customDrawAdClicked:(id<NACustomDrawAdProtocol>)drawAd;
/**
 *  draw广告曝光回调
 */
- (void)customDrawAdExposured:(id<NACustomDrawAdProtocol>)drawAd;

@end

NS_ASSUME_NONNULL_END

#endif
