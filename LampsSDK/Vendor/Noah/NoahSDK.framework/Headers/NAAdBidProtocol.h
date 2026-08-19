//
//  NAAdBidProtocol.h
//  NoahSDK
//
//  Created by hwh on 2023/6/9.
//  Copyright © 2023 Alibaba Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, NAAdBidLossReason)
{
    NAAdBidLossLowPrice          = 1, //价格竞败
    NAAdBidLossFloorPrice        = 2, //底价过滤
    NAAdBidLossTimeout           = 3, //广告超时返回
    NAAdBidLossFrequencyControl  = 4, //广告频控
    NAAdBidLossOther             = 5, //其他原因
};

@protocol NAAdBidProtocol <NSObject>

@optional

/// 竞价胜出调用
/* 如果是⼆价结算，传⼊媒体竞价的⼆价，如果是⼀价结算传⼊参与竞价的汇川SDK⼴告的价格，单位：分/千次展示。
媒体竞价⼆价的定义为：当汇川SDK⼴告竞价胜出
时，竞价队列中次⾼价ADN的出价 + 1分，例如次⾼ADN出价100分，⼆价就是101分。
媒体是采⽤⼀价结算还是⼆价结算由商务合同决定 */
- (void)sendWinNotification:(double)price;

/// 竞价失败调用
/// - Parameters:
///   - price: 媒体竞价的最高价, 单位：分/ecpm
///   - reason: 竞价失败的原因，详见 NAAdBidLossReason
- (void)sendLossNotification:(double)price reason:(NAAdBidLossReason)reason;

@end

NS_ASSUME_NONNULL_END
