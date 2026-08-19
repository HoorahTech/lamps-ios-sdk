//
//  SQRHCAdFetcherEncoder.h
//  ShuQiHCSDK
//
//  Created by ali on 2020/8/17.
//  Copyright © 2020 ShuQi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 编码数据：和 SQRHuiChuanAdFetcherDataSource 中 useWSG 一起使用
@protocol SQRHCAdFetcherEncoder <NSObject>
- (NSData *)encodeData:(NSData *)data;
@end

NS_ASSUME_NONNULL_END
