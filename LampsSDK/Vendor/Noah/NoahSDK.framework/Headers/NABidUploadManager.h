//
//  NABidUploadManager.h
//  NoahSDK
//
//  Created by chenjunru on 2024/4/22.
//  Copyright © 2024 Alibaba Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NABidUploadManager : NSObject

+ (instancetype)sharedInstance;

+ (BOOL)enableBidInfo;

- (NSString *)getBidUploadJson:(NSString *)slotKey;

@end

NS_ASSUME_NONNULL_END
