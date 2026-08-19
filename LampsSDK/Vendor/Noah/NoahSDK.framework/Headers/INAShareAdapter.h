//
//  INAShareAdapter.h
//  NoahSDK
//
//  Created by hwh on 2021/12/7.
//  Copyright © 2021 Alibaba Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol INAShareAdapter <NSObject>

//微信分享
- (void)wechatShare:(NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END
