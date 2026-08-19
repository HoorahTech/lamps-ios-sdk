//
//  NAAppInfoDataSource.h
//  NoahSDK
//
//  Created by zzyong on 2022/3/23.
//  Copyright © 2022 Alibaba Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NAAppInfoDataSource <NSObject>

@optional

/// 用户id
- (nullable NSString *)getUserId;

// App 日期版本号
- (nullable NSString *)dateVersion;

// App 版本号
- (nullable NSString *)appVersion;

// sn
- (nullable NSString *)sn;

// uc_abtest_tag
- (nullable NSString *)ucAbtestTag;

// uc_abtest_tag_fillter
- (nullable NSArray *)ucAbtestTagFillter;

//扩展点击查询媒体开关状态
- (BOOL)appSupportTurnPage:(int)adnId;

// 地理位置信息
- (nullable NSDictionary *)locationInfo;

/// 设备运动数据。注意：该方法由日志子线程调用，外部实现时注意线程安全问题！
- (nullable NSDictionary *)deviceMotionInfo;

@end

NS_ASSUME_NONNULL_END
