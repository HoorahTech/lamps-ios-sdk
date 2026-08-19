//
//  NADrawAd.h
//  NoahSDK
//
//  Created by zhongyang on 2022/4/11.
//  Copyright © 2022 Alibaba Inc. All rights reserved.
//

#if NA_EXTERNAL == 0

#import <NoahSDK/NoahSDK.h>

@protocol NADrawAdListener;
@class RequestInfo;
@class AdAdapter;


NS_ASSUME_NONNULL_BEGIN

@interface NADrawAd : NABaseAd

- (instancetype)init:(id<NADrawAdListener>)listener ad:(AdAdapter *)ad;
/**
 *   加载广告
 */
+(void)getAdWithSlot:(NSString *)slotKey requestInfo:(RequestInfo* _Nullable) requestInfo listener:(id<NADrawAdListener>)listener controller:(UIViewController *)controller;

+(void)preloadAdWithSlot:(NSString *)slotKey requestInfo:(RequestInfo*)info  listener:(id<IAdPreloadListener>)listener controller:(UIViewController * _Nullable)controller;

-(void)show;

-(SdkAssets *)getAdAssets;
-(nullable UIView *)getMediaView;
-(nullable void(^)(void))getMediaPlayBlock;

// 获取某次请求返回的 RequestInfo
-(RequestInfo *)getRequestInfo;

@end

NS_ASSUME_NONNULL_END

#endif
