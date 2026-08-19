//
//  HCNoahDataProtocol.h
//  ShuQiHCSDK
//
//  Created by hwh on 2025/12/8.
//  Copyright © 2025 Alibaba Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@protocol HCNoahDataProtocol <NSObject>

@optional

// 爱采购进阶元宝数
- (NSInteger)ucAcgSyceeCount;
// 爱采购域名
- (nullable NSString *)ucAcgDomain;
// 爱采购 js
- (nullable NSString *)ucAcgJs;
// 是否爱采购
- (BOOL)isUcAcg;

/// 获取Noah版本号
- (NSString *)hcNDGetNoahVersion;

/// 广告是否是千问预算
- (BOOL)hcNDAdIsQwenBudget;

/// 获取web中间页的URL
- (NSString *)hcNDGetWebIPageUrl;

/// 获取web中间页组件的 ext 配置字典
- (nullable NSDictionary *)hcNDGetWebIPageComponentExt;

/// 获取当前组件模板ID
- (NSString *)hcNDGetTemplateId;

/// web中间页是否要展示关闭按钮
- (BOOL)hcNDWebIPageShowCloseBtn;

/// web中间页是否支持右滑返回
- (BOOL)hcNDWebIPageAllowSwipeToDismiss;

/// web中间页是否跳过挽留弹窗
- (BOOL)hcNDWebIPageSkipRetain;

/// web中间页，是否只有下载类型需要展示，默认：NO（所有类型的都可以展示）
- (BOOL)hcNDWebIPageOnlyDownloadNeedShow;

/// 打印Noah Log
/// - Parameter msg: 获取日志信息的block，跟NALog的逻辑一样，日志没有开启的情况下，这个block直接是不执行的
-(void)hcNDNaLog:(id (^)(void))msg;

/// web中间页，即将展示
- (void)hcNDWebIPageWillShow;

/// web中间页，已经关闭
- (void)hcNDWebIPageDidClosed;

/// 获取点击行为类型
- (int)hcNDGetClickActionType;

/// 是否存在web中间页组件
- (BOOL)hcNDHaveWebIPageComponent;

/// 是否直接展示web中间页
- (BOOL)hcNDCanDirectShowWebIPage;

/// 是否需要web中间页的打点
- (BOOL)hcNDEnableWebIPageMonitorStat;

- (void)hcNDUpdateClickType:(int)clickType;

- (int)hcNDWebIPageLoadTimeout;

/// 执行规则
/// - Parameters:
///   - ruleName: 规则名称
///   - ruleParams: 规则参数
///   - completion: 结果回调
- (void)hcNDRunRuleWithName:(NSString *)ruleName
                 ruleParams:(NSDictionary *)ruleParams
                     isSync:(BOOL)isSync
                 completion:(void(^_Nullable)(int ruleResultType, NSString * _Nullable errMsg, NSObject * _Nullable ruleResult))completion;

/// wa打点
/// - Parameters:
///   - category: category
///   - action: action
///   - statParams: 额外参数
///   - completion: 结果回调
- (void)hcNDCustomStatWithCategory:(NSString *)category
                            action:(NSString *)action
                        statParams:(NSDictionary *)statParams
                        completion:(void(^_Nullable)(NSDictionary * _Nullable statResult))completion;

/// 获取SSP配置
/// - Parameters:
///   - key: key
///   - completion: 结果回调
- (void)hcNDGetSspConfigWithKey:(NSString *)key
              isGetCommonConfig:(BOOL)isGetCommonConfig
                     completion:(void(^_Nullable)(id _Nullable value))completion;

/// 获取当前选中模板的完整组件配置（componentTemplateDic 原样透传）
- (nullable NSDictionary *)hcNDGetComponentTemplateDic;
@end

NS_ASSUME_NONNULL_END
