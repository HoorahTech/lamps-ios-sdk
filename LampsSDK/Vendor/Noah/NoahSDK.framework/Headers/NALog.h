//
//  NALog.h
//  NoahSDK
//
//  Created by zzyong on 2021/11/9.
//  Copyright © 2021 Alibaba Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <os/log.h>

static inline os_log_t _Nonnull _NAOSLogOverrideLogger(void) {
    static os_log_t logger;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        logger = os_log_create("com.alibaba.noah.sdk", "NAOSLog");
    });
    return logger;
}

//iOS26, release包, NSLog输出的Log, 无法输出到控制台, 不方便测试（Debug时，NSLog依然可以正常使用）
//基于os_log, 封装NAOSLog宏, 在release包需要NSLog输出控制台的地方，使用此NAOSLog
#define NAOSLog(format, ...) \
    os_log(_NAOSLogOverrideLogger(), "%{public}s", \
           [[NSString stringWithFormat:(format), ##__VA_ARGS__] UTF8String])

/// 日志内容
#define NA_LOG_LOG         @"log"
/// 日志类型，默认 NALogTypeDebug
#define NA_LOG_TYPE        @"type"
/// 日志颜色，默认白色
#define NA_LOG_COLOR       @"color"
/// 是否可视化，默认 YES
#define NA_LOG_VISUAL      @"visual"

typedef NS_ENUM(NSUInteger, NALogType) {
    NALogTypeDebug   = 0, ///< Debug
    NALogTypeInfo    = 1, ///< Info
    NALogTypeWarn    = 2, ///< Warn
    NALogTypeError   = 3, ///< Error
    NALogTypeAd      = 4, ///< 广告链路日志，如非必要，请勿使用该 Type
};

NS_ASSUME_NONNULL_BEGIN

@interface NALog : NSObject

//MARK: NALog 使用示例
/*
 // 字符串
 [NALog log:^NSDictionary<NSString *,id> * _Nonnull{
     return @"log msg";
 }];
 
 // 任意对象。自动转换字符串
 [NALog log:^NSDictionary<NSString *,id> * _Nonnull{
     return @[@"a", @"b"];
 }];
 
 // 日志字典
 Dictionary Key 如下：
    - NA_LOG_LOG：日志内容
    - NA_LOG_COLOR：日志颜色，默认：UIColor.whiteColor
    - NA_LOG_TYPE：日志类型，默认：NALogTypeDebug
    - NA_LOG_VISUAL：是否可视化，默认：YES

 [NALog log:^NSDictionary<NSString *,id> * _Nonnull{
     NSString *log = [NSString stringWithFormat:@"日志开关关闭后不会被调用，日志开关默认是关闭的..."];
     return @{NA_LOG_LOG: log, NA_LOG_TYPE: @(NALogTypeDebug), NA_LOG_COLOR: UIColor.whiteColor, NA_LOG_VISUAL: @1};
 }];
 
 */

/// debug log，调试专用
+ (void)log:(id (^)(void))msg;

/// 媒体可以提前获取状态，避免执行多余代码
+ (BOOL)enableLog;

@end

@interface NALog ()

//MARK: 以下 log 会写文件，注意不要打印频繁输出日志类型 ！！！
+ (void)infoLog:(id (^)(void))msg;
+ (void)errorLog:(id (^)(void))msg;
+ (void)warnLog:(id (^)(void))msg;
+ (void)adLog:(id (^)(void))msg;

@end

NS_ASSUME_NONNULL_END
