//
//  HCRewardAdFetcherProtocol.h
//  ShuQiHCSDK
//
//  Created by chenlei on 2025/6/12.
//  Copyright © 2025 Alibaba Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SQRHuiChuanAdFetcherDelegate;
@class SQRHuiChuanHeaderExpInfoModel;

@protocol HCRewardAdFetcherProtocol <NSObject>

@property (nonatomic, weak) id<SQRHuiChuanAdFetcherDelegate> _Nullable delegate;

@property (nonatomic, copy) NSString * _Nonnull adcode;

@property (nonatomic, strong) NSString *noahSlot;

@property (nonatomic, assign) HCForbiddenType adForbidden;

@property (nonatomic, copy, nullable) NSString *mockUrl;

@property (nonatomic, copy, nullable) NSString *fetchUrl;

@property (nonatomic, copy, nullable) NSString *wnurl;

@property (nonatomic, assign) BOOL isWolong;

/// 执行请求
- (void)fetchAd;

/// 竞胜URL上报
/// - Parameters:
///   - winUrl: 竞胜上报url
///   - sessionId: 外部传入的sessionId
///   - price: 媒体竞价的二价(当智能营销SDK竞价胜出时，竞价队列中次高价ADN的出价 + 1分，例如次高ADN出价100分，二价就是101分), 单位：分/ecpm
+(void)reportAdWinUrl:(NSString *_Nonnull)winUrl sessionId:(NSString *_Nonnull)sessionId price:(int)price;

/// 设置adTest信息
- (void)setExpTags:(NSArray<SQRHuiChuanHeaderExpInfoModel *> *_Nullable)arr;

@end

NS_ASSUME_NONNULL_END
