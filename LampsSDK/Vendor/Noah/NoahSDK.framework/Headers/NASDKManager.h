//
//  NASDKManager.h
//  NoahSDK
//
//  Created by zzyong on 2025/5/27.
//  Copyright © 2025 Alibaba Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NoahSdkConfig;

NS_ASSUME_NONNULL_BEGIN

@interface NASDKManager : NSObject

/// SDK 初始化
/// - Parameters:
///   - sdkConfig: sdk 配置
///   - completion: 初始化结果回调
+ (void)initWithSdkConfig:(NoahSdkConfig *)sdkConfig completion:(void (^)(BOOL success, NSError *error))completion;

/// SDK 版本号
+ (NSString *)sdkVersion;

/// 调试日志开关，开发期间建议开启
+ (void)setDebugLogEnable:(BOOL)enable;

@end

NS_ASSUME_NONNULL_END
