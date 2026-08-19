//
//  NABaseAd.h
//  NoahSDK
//
//  Created by zhongyang on 2020/11/3.
//  Copyright © 2020 zhongyang.ywx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NAAdBidProtocol.h"

@class RequestInfo;

NS_ASSUME_NONNULL_BEGIN

@interface NABaseAd : NSObject <NAAdBidProtocol>

/// 广告请求信息
@property(nonatomic, strong, readonly) RequestInfo *requestInfo;

/// 广告价格
@property(nonatomic, assign, readonly) double price;

/// 广告有效时长，单位为毫秒
- (long)getExpiredTime;

/// 广告是否有效，YES:有效，NO:无效
- (BOOL)isValid;

/// 广告额外信息
- (nullable NSDictionary *)getExtraInfo;

@end

NS_ASSUME_NONNULL_END
