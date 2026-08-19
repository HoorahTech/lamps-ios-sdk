//
//  NAVoucherInfo.h
//  NoahSDK
//
//  Created by hwh on 2025/7/22.
//  Copyright © 2025 Alibaba Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NAVoucherInfo : NSObject

@property (nonatomic, assign) int amount;//金额（分）
@property (nonatomic, assign) BOOL isFixAmount;//是否是固定金额
@property (nonatomic, assign) BOOL hasCondition;//是否有门槛
@property (nonatomic, assign) BOOL isAll;//是否全平台通用

@end

NS_ASSUME_NONNULL_END
