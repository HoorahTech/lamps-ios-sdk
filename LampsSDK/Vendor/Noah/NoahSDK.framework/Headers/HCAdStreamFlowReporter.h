//
//  HCAdStreamFlowReportCenter.h
//  ShuQiHCSDK
//
//  Created by chenjunru on 2023/11/1.
//  Copyright © 2023 Alibaba Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, HCAdCallType)
{
    HCAdCallTypeOpenApp = 1,    //调端
    HCAdCallTypeOpenAppStore = 2,   //打开appstore
    HCAdCallTypeOpenWx = 3,   //打开微信小程序
};

typedef NS_ENUM(NSUInteger, HCAdJumpType)
{
    HCAdJumpTypeUnknown = 0,   //
    HCAdJumpTypeOne = 1,    //直跳
    HCAdJumpTypeSec = 2   //落地页跳转
};

typedef NS_ENUM(NSUInteger, HCAdLinkType)
{
    HCAdLinkTypeUnknown = 0,   //
    HCAdLinkTypeScheme = 1,    //Scheme跳转
    HCAdLinkTypeUlk = 2   //Ulk跳转
};

typedef NS_ENUM(NSUInteger, HCAdScenarioType)
{
    HCAdScenarioTypUnknown = 0,   //其他
    HCAdScenarioTypeIFlow = 1,    //信息流场景
    HCAdScenarioTypeSDK = 2,      //SDK
    HCAdScenarioTypeNonstandard = 3, //非标
    HCAdScenarioTypeSearch = 4,   //搜索
    HCAdScenarioTypeNovel = 5,    //小说
    HCAdScenarioTypeFlashScreen = 6//闪屏
};

typedef NS_ENUM(NSUInteger, AppCallEventType)
{
    AppCallEventTypeBusness = 0,   //商业化流量
    AppCallEventTypeNature = 1     //自然流量
};

@class SQRHuiChuanResponseAdModel;

@interface HCAdStreamFlowReporter : NSObject

+ (instancetype)shareInstance;

/*
 * 下划线分割，第2个元素为sid 第3个为cid
 */
+ (void)parsePatterString:(NSString *)pattern block:(void(^)(NSString * _Nullable sid, NSString * _Nullable cid))block;

/*
 * 解析小程序id
 */
+ (nullable NSString *)parseMiniAppIdWithUclink:(NSString *)uclink;

/*
 * sid：search_id
 * cid：ad_id
 * url：打开APP时，获取不到packname时，传给汇川接口
 */
- (void)reportStreamFlowWithSlotId:(NSString *)slotId appId:(nullable NSString *)appId sid:(nullable NSString *)sid cid:(nullable NSString *)cid url:(nullable NSString *)url;

+ (void)statAppCallDic:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
