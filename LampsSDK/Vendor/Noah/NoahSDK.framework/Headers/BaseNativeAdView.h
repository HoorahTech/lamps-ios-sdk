//
//  BaseNativeAdView.h
//  NoahSDK
//
//  Created by Reus on 2020/12/2.
//  Copyright © 2020 zhongyang.ywx. All rights reserved.
//

#import <Foundation/Foundation.h>


@class NativeAdapter;


NS_ASSUME_NONNULL_BEGIN

@protocol NoahSdkCheckShowDelegate <NSObject>

-(void)didShowAd;

@end

@interface BaseNativeAdView : UIView
@property (nonatomic, assign) BOOL isNeedShowMediaLoading;//是否需要显示mediaView的loading，默认为YES。在这种场景：返回的native广告，是视频，但是媒体侧的实现是显示为图片，媒体侧可设置此参数为NO，那么显示出图片时，不会出现loading图标。

@property(nonatomic,weak)id<NoahSdkCheckShowDelegate> mShowDelegate;
-(UIView *)getRegisterContainer;
-(void)bindAdView:(NativeAdapter *)ad customView:(UIView *)customView;
-(void)setCustomView:(UIView *)view;
-(void)setNativeAd:(NativeAdapter *)ad;
-(void)didShowAd;
-(void)unregister;

@end

NS_ASSUME_NONNULL_END
