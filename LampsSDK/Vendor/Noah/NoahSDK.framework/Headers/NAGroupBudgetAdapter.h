//
//  NAGroupBudgetAdapter.h
//  NoahSDK
//
//  Created by chenlei on 2024/7/31.
//  Copyright © 2024 Alibaba Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 接口返回信息
typedef NS_ENUM(NSInteger, NAGroupBudgetAdResult) {
    NAGroupBudgetAdSuccess    = 0,    ///< 成功
    NAGroupBudgetAdParamError = -1,   ///< 参数错误
    NAGroupBudgetAdReqAdFail  = -2,   ///< 请求广告失败
    NAGroupBudgetAdNotFound   = -3,   ///< 未找到对应广告
    NAGroupBudgetAdAdnError   = -4,   ///< 广告adn错误
};

@class NativeAd;

@interface NAGroupBudgetAdapter : NSObject

/// 获取广告
+ (void)loadNativeAd:(NSString *)slotId
              appKey:(NSString * _Nullable)appKey
          completion:(void(^)(NAGroupBudgetAdResult result, NativeAd * _Nullable adModel))completion;

/// 通知广告展示
+ (NAGroupBudgetAdResult)onNativeAdShow:(NSString *)sid slotId:(NSString *)slotId;

/// 通知广告点击
+ (NAGroupBudgetAdResult)onNativeAdClick:(NSString *)sid slotId:(NSString *)slotId;

/// 通知广告关闭
+ (NAGroupBudgetAdResult)onNativeAdClose:(NSString *)sid slotId:(NSString *)slotId;

/// 通知广告绑定任务
+ (void)notifyAdBindTask:(NSDictionary *)adInfo completion:(void(^)(NSData * _Nullable data, NSError * _Nullable error))completion;

/// 自定义点击上报
+ (NAGroupBudgetAdResult)notifyCustomClickStat:(NSString *)sid slotId:(NSString *)slotId;

@end

NS_ASSUME_NONNULL_END
