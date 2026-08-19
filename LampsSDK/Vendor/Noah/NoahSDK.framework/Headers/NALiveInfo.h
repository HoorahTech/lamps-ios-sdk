//
//  NALiveInfo.h
//  NoahSDK
//
//  Created by zzyong on 2022/5/18.
//  Copyright © 2022 Alibaba Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NALiveCouponInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface NALiveInfo : NSObject

/// 主播名称
@property (nonatomic, strong) NSString *authorName;
/// 主播头像
@property (nonatomic, strong) NSString *avatarUrl;
/// 提示文本
@property (nonatomic, strong) NSString *liveTipText;
/// 在线观看人数
@property (nonatomic, assign) NSInteger watchCount;
/// 主播粉丝数
@property (nonatomic, assign) NSInteger followerCount;
/// 优惠券原始信息
@property (nonatomic, strong, nullable) NSDictionary *coupon;
/// 优惠券解析后信息
@property (nonatomic, strong, nullable) NALiveCouponInfo *couponInfo;
/// 商品信息
@property (nonatomic, strong, nullable) NSDictionary *product;
/// adnId
@property (nonatomic, assign) NSInteger adnId;

@end

NS_ASSUME_NONNULL_END
