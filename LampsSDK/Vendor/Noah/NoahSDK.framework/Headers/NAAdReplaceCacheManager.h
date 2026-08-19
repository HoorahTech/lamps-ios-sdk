//
//  NAAdReplaceCacheManager.h
//  NoahSDK
//
//  Created by canzi on 2024/1/17.
//  Copyright © 2024 Alibaba Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NAAdReplaceCacheManager : NSObject

// 信息流
+ (nullable NSString *)getAdvertiserJsonWithChannelId:(NSString *)channelId slotId:(NSString *)slotId;

@end

NS_ASSUME_NONNULL_END
