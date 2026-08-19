//
//  MonitorInfoManager.h
//  NoahSDK
//
//  Created by Reus on 2021/7/6.
//  Copyright © 2021 zhongyang.ywx. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MonitorInfoModel, AdContext, AdnInfo, AdAdapter;

NS_ASSUME_NONNULL_BEGIN

extern NSString* const NA_MOCK_SCENE ;
extern NSString* const NA_MOCK_SESSION_ID;
extern NSString* const NA_MOCK_INFO_FLOW_SCENE;
extern NSString* const NA_MOCK_UCV_FULL_VIDEO;

@interface MonitorInfoManager : NSObject

+ (instancetype)sharedInstance;
- (void)onAdReceived:(AdContext *)context adnInfo:(AdnInfo *)info ad:(AdAdapter *)ad;
+ (nullable NSDictionary *)getHCAdData:(NSDictionary *)adDic;
+ (void)uploadHcAdData:(AdContext *)context adnInfo:(AdnInfo *)info adapters:(NSArray *)adapters extInfo:(NSDictionary *)info;
+ (void)uploadXSSData:(NSDictionary *)data extInfo:(NSDictionary *)extInfo;
+ (void)uploadExternalData:(NSDictionary *)data
                    slotId:(NSString *)slotId
                 sessionId:(NSString *)sessionId
                     adnId:(int)adnId
                   extInfo:(nullable NSDictionary *)extInfo;

+ (nullable NSString *)tryGetAdIdWithExternalData:(NSDictionary *)data adnId:(int)adnId;

@end

NS_ASSUME_NONNULL_END
