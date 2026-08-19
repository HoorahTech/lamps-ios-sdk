//
//  RewardedVideoAd.h
//  NoahSDK
//
//  Created by zhongyang on 2020/12/4.
//  Copyright © 2020 zhongyang.ywx. All rights reserved.
//

#import "NABaseAd.h"
#import "NoahSdkRewardedVideoListener.h"

NS_ASSUME_NONNULL_BEGIN

@interface RewardedVideoAd : NABaseAd

/// 广告回调事件代理，默认会使用请求广告的方法中传入的listenner，如非必要，不建议通过此属性重新设置
@property(nonatomic,weak) id<NoahSdkRewardedVideoListener> delegate;

///  广告加载
/// - Parameters:
///   - reqInfo: 请求信息
///   - adDelegate: 广告事件回调代理
+ (void)loadAdWithReqInfo:(RequestInfo *)reqInfo adDelegate:(id<NoahSdkRewardedVideoListener>)adDelegate;

/// 展示广告
- (void)showAdInViewController:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
