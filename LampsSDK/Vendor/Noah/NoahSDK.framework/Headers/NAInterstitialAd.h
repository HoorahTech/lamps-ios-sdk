//
//  NAInterstitialAd.h
//  NoahSDK
//
//  Created by chenlei on 2025/3/31.
//  Copyright © 2025 Alibaba Inc. All rights reserved.
//

#import "NABaseAd.h"
#import "NAInterstitialAdListener.h"

NS_ASSUME_NONNULL_BEGIN

@interface NAInterstitialAd : NABaseAd

/// 广告回调事件代理，默认会使用请求广告的方法中传入的listenner，如非必要，不建议通过此属性重新设置
@property (nonatomic,weak) id<NAInterstitialAdListener> delegate;

///  广告加载
/// - Parameters:
///   - reqInfo: 请求信息
///   - adDelegate: 广告事件回调代理
+ (void)loadAdWithReqInfo:(RequestInfo *)reqInfo adDelegate:(id<NAInterstitialAdListener>)adDelegate;

/// 展示广告
- (void)showAdInViewController:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
