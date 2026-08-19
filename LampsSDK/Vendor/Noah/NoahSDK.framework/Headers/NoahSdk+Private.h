//
//  NoahSdk+Private.h
//  NoahSDK
//
//  Created by 蛮牛 on 2025/5/27.
//  Copyright © 2025 Alibaba Inc. All rights reserved.
//

#import "NoahSdkConfig.h"
#import "GlobalConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoahSdk : NSObject

/// NoshSDK 初始化
/// @param config sdk 配置
/// @param globalConfig 全局配置
+ (void)initWithConfig:(NoahSdkConfig *)config globalConfig:(nullable GlobalConfig *)globalConfig;

/// 获取 SDK 版本
+ (NSString *)sdkVersion;

/// 获取 SDK build 号
+ (int)sdkVersionCode;

/// NoahSdkConfig
+(NoahSdkConfig *)getNoahSdkConfig;

@end

NS_ASSUME_NONNULL_END
