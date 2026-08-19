//
//  ATokenSDK.h
//  AToken
//
//  Created by AToken on 8/29/20.
//  Copyright © 2020 AToken. All rights reserved.
//  3.0.0 in&c

#import <Foundation/Foundation.h>

@interface ATokenSDK : NSObject

/// 配置自定义域名（需在初始化之前设置,本地会缓存）
/// @param domain 域名字符串 如：https://www.xxxxxx.com
+ (void)configureDomain:(NSString *)domain;

/// CValue配置
/// - Parameters:
///   - sID: 来源ID
///   - sourceToken: 授权令牌
+ (void)sourceID:(NSString *)sID token:(NSString *)sourceToken;

/// SDK初始化，异步请求aToken
/// @param completion 请求aToken的回调，aToken为返回值，如果失败，aToken为空字符串@“”
+ (void)init:(void (^)(NSString *aToken))completion;

/// SDK初始化，异步请求aToken和cValue
/// @param aTokenBlock 请求aToken的回调，aToken为返回值，如果失败，aToken为空字符串@“”
/// @param cValueBlock 请求cValue的回调，cValue为返回值，如果失败，cValue为nil
+ (void)init:(void (^)(NSString *aToken))aTokenBlock cValue:(void (^)(NSArray *cValue))cValueBlock;

/// 同步获得aToken，失败返回空字符串@“”
+ (NSString *)getAToken;

/// 获取SDK版本号
+ (NSString *)getSDKVersion;

/// 获得resetToken
+ (NSString *)getResetToken;

/// 同步获得所有ID，失败返回@{}
+ (NSDictionary *)getAll;

/// 获取单因子
+ (NSString *)getTFactor;
/// 禁止采集单因子 不会添加到getAll中
+ (void)forbidTFactor;

/// 同步获得cValue，失败返回nil
+ (NSArray *)getCValue;
/// 禁止采集cValue 不会添加到getAll中且不会初始化cValue 需在init前调用
+ (void)forbidCValue;

/// 获取CValue启动时间单因子,失败返回@""
+ (NSString *)getCBootTimeInSec;
/// 禁止采集CValue启动时间单因子，不会添加到getAll中
+ (void)forbidCBootTimeInSec;

/// 获取CValue系统更新时间单因子,失败返回@""
+ (NSString *)getCSysFileTime;
/// 禁止采集CValue系统更新时间单因子，不会添加到getAll中
+ (void)forbidCSysFileTime;
///是否打印日志 YES：打印 默认不打印
+ (void)logEnable:(BOOL)isEnable;
@end
