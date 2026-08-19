//
//  SdkAdDetail.h
//  NoahSDK
//
//  Created by Reus on 2022/1/18.
//  Copyright © 2022 Alibaba Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SdkAdDetail : NSObject

// 直播新增字段 =0 纯图片样式（静态图样式） =1 直播样式
@property (nonatomic, copy) NSString *subtype;

/// 扩展，通过parser解析出来的内容会放在这里
@property (nonatomic,strong,nullable)NSDictionary *extInfos;

- (void)mergeExtInfo:(NSDictionary *)extInfo;

/// SDK 具体广告id
@property (nonatomic,copy,nullable)NSString *adid;

/// 原始数据的json字符串，业务层不要设置，以免影响解析
@property (nonatomic, copy  ,nullable) NSString *rawJson;

@end

NS_ASSUME_NONNULL_END
