//
//  NoahCustomSplashAdProtocol.h
//  NoahSDK
//
//  Created by zhongyang on 2021/12/27.
//  Copyright © 2021 Alibaba Inc. All rights reserved.
//

#if NA_EXTERNAL == 0

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NoahCustomSplashAdDelegate.h"


NS_ASSUME_NONNULL_BEGIN


@protocol NoahCustomSplashAdProtocol <NSObject>

@required
// 初始化  listener开屏事件代理
-(void)dataWithPlacementId:(NSString *)placementId params:(NSDictionary*)params listener:(id<NoahCustomSplashAdDelegate>)listener;
// 加载广告
-(void)loadAd;
// 展示广告
-(void)show;
// 关闭广告
-(void)close;
// 内存回收
-(void)destroy;
// 广告adid,没有返回 @""
-(NSString *)getAdId;
// 是否加载完毕，可展示
-(BOOL)isAdValid;
// 获取价格，没有返回 -1
-(double)getPrice;

@optional

- (nullable NSDictionary *)adResponse;

@end

NS_ASSUME_NONNULL_END

#endif
