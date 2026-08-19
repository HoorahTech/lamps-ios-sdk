//
//  NACustomDrawAdProtocol.h
//  NoahSDK
//
//  Created by zhongyang on 2022/4/13.
//  Copyright © 2022 Alibaba Inc. All rights reserved.
//

#if NA_EXTERNAL == 0

#import <Foundation/Foundation.h>
#import "NACustomDrawAdDelegate.h"
#import "NoahCustomParamsKey.h"



NS_ASSUME_NONNULL_BEGIN


@protocol NACustomDrawAdProtocol <NSObject>

@required
// 初始化  listener开屏事件代理
-(void)dataWithPlacementId:(NSString *)placementId params:(NSDictionary*)params listener:(id<NACustomDrawAdDelegate>)listener;
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
-(double)getPrice:(int)index;
// 获取广告数据
-(NSObject *)getNativData;
// 获取优先级
-(double)getPriority:(int)index;
// 获取底价
-(double)getAdnFloorPrice:(int)adnId;

-(double)getAdnDspFloorPrice;
// 获取透传信息
-(NSDictionary<NSString*,NSString*>*)getExtraInfoForStats:(int)index;


@end

NS_ASSUME_NONNULL_END

#endif
