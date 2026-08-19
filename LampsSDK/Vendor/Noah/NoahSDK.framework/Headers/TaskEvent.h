//
//  TaskEvent.h
//  NoahSDK
//
//  Created by 小瓜瓜 on 2021/6/29.
//  Copyright © 2021 zhongyang.ywx. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AdnInfo;
@class AdAdapter;
@class SdkAdDetail;

NS_ASSUME_NONNULL_BEGIN

// TaskEventType 事件类型  0暂时没用到
typedef enum {
    // 媒体侧调用请求广告 0
    TaskEventTypeGetAd                        = 1,
    // 发起广告请求
    TaskEventTypeFetchAd                      = 2,
    // 价格请求 0
    TaskEventTypeAdPriceSend                  = 3,
    // 价格返回 0
    TaskEventTypeAdPriceReceive               = 4,
    // 获取价格出错 0
    TaskEventTypeAdPriceError                 = 5,
    // 获取价格超时 0
    TaskEventTypeAdPriceTimeout               = 6,
    // 请求三方adn
    TaskEventTypeAdSend                       = 7,
    // 三方adn返回
    TaskEventTypeAdReceive                    = 8,
    // 三方adn出错
    TaskEventTypeAdError                      = 9,
    // 请求广告超时
    TaskEventTypeAdTimeout                    = 10,
    // 竞价完毕，开始加载物料 0
    TaskEventTypeLoadAd                       = 11,
    // 竞价超时 0
    TaskEventTypeLoadTimeout                  = 12,
    // 策略总体超时 0
    TaskEventTypeFetchTimeout                 = 13,
    // 三方adn竞价bid
    TaskEventTypeAdnBid                       = 14,
    // 汇川联动接口,目前就UC有
    TaskEventTypeHcInsertToList               = 15,
    // 汇川暗投联动接口,目前就UC有
    TaskEventTypeHcInsertAdInfoToNewFlows     = 16
} TaskEventType;


// taskExtraInfo
// 必返回字段 --------------------------------------
// 策略key   NSString
static NSString *const EK_slotKey = @"slotKey";
// task任务Id   NSString
static NSString *const EK_taskId = @"taskId";
// 触发时间 时间戳   long
static NSString *const EK_time = @"time";
// 加载类型 串行1 并行2   int
static NSString *const EK_levelType = @"levelType";
// 请求时间 毫秒  int
static NSString *const EK_responseTime = @"responseTime";
// 非必返回字段 --------------------------------------
// adn标识  int
static NSString *const EK_adnId = @"adnId";
// adn名称  NSString
static NSString *const EK_adnName = @"adnName";
// placmentId   NSString
static NSString *const EK_placmentId = @"placmentId";
// adn竞价类型 AdnBidType   int
static NSString *const EK_adnBidType = @"adnBidType";
// 1表示同时请求物料和价格；0表示先拿价格后拿物料   NSString
static NSString *const EK_adWithPrice = @"adWithPrice";
// adn出的价格   NSString
static NSString *const EK_adPrice = @"sdk_ad_price";
// adn 错误码   NSString
static NSString *const EK_adnErrorCode = @"adnErrorCode";
// adn 错误信息   NSString
static NSString *const EK_adnErrorMessage = @"adnErrorMessage";
// adn 竞价结果 @"succ" 比价胜出  @"fail" 比价失败   NSString
static NSString *const EK_bidResult = @"bid_result";
// adn 竞价价格   NSString
static NSString *const EK_bidPrice = @"bid_price";
// adn 竞价底价   NSString
static NSString *const EK_ffPrice = @"floor_price_filter";
// 是否超时  0没有超时 1超时   NSString
static NSString *const EK_isTimeout = @"is_timeout";




@interface TaskEvent : NSObject {
}

// 事件类型
@property(assign, nonatomic) TaskEventType eventType;
// 广告返回的某些数据
@property(nonatomic,strong) SdkAdDetail *adDetail;
// 额外透出的字段
@property(strong, nonatomic) NSMutableDictionary *taskExtraInfo;

@end

NS_ASSUME_NONNULL_END
