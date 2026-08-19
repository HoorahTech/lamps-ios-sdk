//
//  RequestInfo.h
//  NoahSDK
//
//  Created by 小瓜瓜 on 2021/6/28.
//  Copyright © 2021 zhongyang.ywx. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RequestInfo : NSObject

/// 广告位
@property(nonatomic, strong) NSString *slotKey;

/// 广告请求数量
@property(nonatomic, assign) int requestCount;

/// 广告请求超时时间，单位秒, 默认 15s
@property(nonatomic, assign) NSTimeInterval timeoutInterval;

/// 是否禁止个性化广告推荐
@property(nonatomic, assign) BOOL forbidPersonalizedAd;

@end

#pragma mark - Custom

@interface RequestInfo ()

/// 开屏广告底部自定义视图，例如：Logo
@property(nonatomic, strong, nullable) UIView *splashBottomView;

/// 原生广告 MediaView 封面占位图
@property(nonatomic, strong, nullable) UIImage *mediaViewPlaceholderImage;

@end

NS_ASSUME_NONNULL_END
