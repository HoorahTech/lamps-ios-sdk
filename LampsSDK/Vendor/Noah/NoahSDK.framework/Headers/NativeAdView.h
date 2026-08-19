//
//  NativeAdView.h
//  NoahSDK
//
//  Created by Reus on 2020/12/3.
//  Copyright © 2020 zhongyang.ywx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NoahSDK/BaseNativeAdView.h>
#import <NoahSDK/NativeAd.h>

NS_ASSUME_NONNULL_BEGIN

@interface NativeAdView : BaseNativeAdView

-(void)bindAdViewWithAd:(NativeAd *)ad customView:(UIView *)customView;

@end

NS_ASSUME_NONNULL_END
