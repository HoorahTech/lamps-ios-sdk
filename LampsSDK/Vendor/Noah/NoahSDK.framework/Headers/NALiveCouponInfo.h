//
//  NALiveCouponInfo.h
//  NoahSDK
//
//  Created by hwh on 2022/11/21.
//  Copyright © 2022 Alibaba Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, NALiveCouponType) {
    NALiveCouponTypeHaveThreshold = 1,       //满减
    NALiveCouponTypeNoThreshold,             //立减
};

@interface NALiveCouponInfo : NSObject

@property (nonatomic, assign) NALiveCouponType liveCouponType;  //优惠类型
@property (nonatomic, assign) NSInteger threshold;              //满减门槛
@property (nonatomic, assign) double amount;                    //优惠券金额
@property (nonatomic, strong) NSString *startTime;              //优惠券开始生效时间
@property (nonatomic, strong) NSString *expireTime;             //优惠券过期时间
@property (nonatomic, assign) BOOL isFixedCoupon;               //是否固定金额优惠券（默认：YES）
@property (nonatomic, assign) NSInteger adnId;                  //adnId
@property (nonatomic, assign) BOOL isAll;                       //是否通用
@property (nonatomic, copy)   NSString *voucherTips;            //风险提示语

- (BOOL)isHcAd;

@end

NS_ASSUME_NONNULL_END
