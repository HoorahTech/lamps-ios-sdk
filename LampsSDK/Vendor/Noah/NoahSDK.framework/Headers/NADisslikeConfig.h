//
//  NADisslikeConfig.h
//  NoahSDK
//
//  Created by zhongyang on 2022/9/8.
//  Copyright © 2022 Alibaba Inc. All rights reserved.
//

#if NA_EXTERNAL == 0

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, NADislikeRuleType) {
    NADislikeRuleTypeNone    = 0,    // 不记录屏蔽规则中
    NADislikeRuleTypeAdid,           // 屏蔽某广告
    NADislikeRuleTypeAdn,            // 屏蔽某ADN（屏蔽来源）
    NADislikeRuleTypeAll,            // 屏蔽所有
    NADislikeRuleTypeTag,            // 屏蔽标签（信息流汇川）
};

typedef NS_ENUM(NSInteger, NADislikeReportType) {
    NADislikeReportTypeNone = 0,
    NADislikeReportTypeBlock,     //广告屏蔽（屏蔽此条广告、屏蔽来源、屏蔽标签）
    NADislikeReportTypeComplain   //广告投诉（广告反馈质量）
};

typedef NS_ENUM(NSInteger, NADislikePolicy) {
    NADislikePolicyNone = 0,
    NADislikePolicyAdnId,        //不出该adnId广告
    NADislikePolicyIndustry,     //不出该adn下 对应行业广告
    NADislikePolicyAdvertiser,   //不出该adn下 对应广告主广告
    NADislikePolicyAdId,         //不出该adn下 对应adid广告
};

@interface NADisslikeConfig : NSObject
@property (nonatomic, strong) NSArray *ad_negative_config_rules;
@property (nonatomic, strong) NSArray *ad_block_config_rules;
@property (nonatomic, strong) NSArray *ad_block_config_adns;
@property (nonatomic, strong) NSArray *ad_indemnity;
@property (nonatomic, assign) int text_max_len;
@property (nonatomic, assign) BOOL haveData;

+ (NADisslikeConfig *)sharedInstance;
- (void)loadDislikeStaticConfig:(BOOL)enablePolicy;

- (void)disslikeSdkNegativeLogReport:(NSDictionary *)dic;
- (void)disslikeSdkNegativeLogBlock:(NSDictionary *)dic;
- (void)disslikeSdkNegativeLogBlockFetchad:(NSDictionary *)dic;
- (void)disslikeSdkNegativeLogBlockUsead:(NSDictionary *)dic;
- (void)disslikeSdkNegativeLogBlockHackfail:(NSDictionary *)dic;

//信息流汇川负反馈上报
- (void)dislikeHcAdReport:(NSDictionary *)adInfo;
//Noah三方负反馈上报
- (void)dislikeNoahAdReport:(NSDictionary *)adInfo;

//三方广告负反馈新策略
- (void)dislikeNoahAdBlock:(NSDictionary *)dic;

- (NSString * _Nullable)getAdIdTagWith:(NSString *)title bgUrl:(NSString *)bgUrl;
- (BOOL)isValidAdIdTagWith:(NSString *)title bgUrl:(NSString *)bgUrl;
- (BOOL)needBlockRlueAdid:(NSString *)title bgUrl:(NSString *)bgUrl;
- (void)saveBlockRlueAdid:(NSString *)title bgUrl:(NSString *)bgUrl;

- (void)saveBlockRlueAdnId:(NSString *)adnId;
- (nullable NSArray *)blockAdnIdAction:(NSMutableArray *)adns reqInfo:(NSObject *)reqInfo;

- (BOOL)needBlockRlueAll:(NSObject *)adTask;
- (void)saveBlockRlueAll;


- (nullable NSArray *)blockPolicyAdnIdAction:(NSMutableArray *)adns adTask:(NSObject *)adTask;
- (BOOL)needBlockAdapter:(NSObject *)adapter;
- (void)saveBlockPolicy:(NADislikePolicy)policy ruleId:(NSString *)ruleId adnId:(NSString *)adnId content:(NSString *)content time:(int64_t)time;
- (BOOL)enablePolicyWithAdTask:(NSObject *)adTask;

- (void)cleanAdid;
- (void)cleanAdn;
- (void)cleanAll;

@end

NS_ASSUME_NONNULL_END

#endif
