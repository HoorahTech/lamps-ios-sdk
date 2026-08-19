//
//  NATaobaoRtaManager.h
//  NoahSDK
//
//  Created by chenlei on 2024/6/13.
//  Copyright © 2024 Alibaba Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - NATaobaoRtaResult

/// RTA来源
typedef NS_ENUM(int, NARtaSource)
{
    NARtaSourceUnknown = 0,   // 未知
    NARtaSourceTaobao  = 1,   // 淘宝
    NARtaSourceOffline = 2,   // 离线
};

/// RTA Show Order
typedef NS_ENUM(int, NARtaOrder)
{
    NARtaOrderNone     = 0,   // 无
    NARtaOrderMono     = 1,   // 独占
    NARtaOrderHighPrio = 2,   // 高优
};

@interface NATaobaoRtaResult : NSObject

@property (nonatomic, strong) NSString *tag;

@property (nonatomic, assign) double price;

@property (nonatomic, assign) NARtaSource source;

@property (nonatomic, assign) BOOL isTarget;

@property (nonatomic, assign) NARtaOrder showOrder;

@end

#pragma mark - NATaobaoRtaManager

typedef NSArray<NSDictionary *> *_Nullable(^NARtaDataProviderBlock)(void);

/// 淘宝RTA管理类，https://aliyuque.antfin.com/pduitr/uf36s3/fk2i2d9sbcsncdiv
@interface NATaobaoRtaManager : NSObject

+ (instancetype)sharedInstance;

/// 更新淘宝RTA ID
- (void)updateTaobaoRtaIds:(NSString *)rtaIds;

/// 获取rta id信息
- (nullable NSDictionary *)tbRtaIdInfos;

/// 根据策略场景获取rta配置结果
- (NATaobaoRtaResult *)getRtaResultWithStrategyScene:(NSString *)scene;

/// 设置获取RTA映射表block
- (void)setRtaMapTableProvider:(NARtaDataProviderBlock)providerBlock;

/// 设置获取策略信息block
- (void)setRtaStrategyProvider:(NARtaDataProviderBlock)providerBlock;

/// 统计调用淘宝url
- (void)checkAppOpenUrl:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
