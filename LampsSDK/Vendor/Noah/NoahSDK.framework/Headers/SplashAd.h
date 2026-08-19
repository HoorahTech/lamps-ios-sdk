//
//  SplashAd.h
//  NoahSDK
//
//  Created by Reus on 2020/11/18.
//  Copyright © 2020 zhongyang.ywx. All rights reserved.
//

#import "NABaseAd.h"
#import "RequestInfo.h"
#import "NoahSplashAdListener.h"

NS_ASSUME_NONNULL_BEGIN

@interface SplashAd: NABaseAd

/// 广告回调事件代理，默认会使用请求广告的方法中传入的listenner，如非必要，不建议通过此属性重新设置
@property(nonatomic, weak) id<NoahSplashAdListener> delegate;

/// 广告加载
/// - Parameters:
/// - reqInfo: 请求信息
/// - adDelegate: 广告事件回调代理
+ (void)loadAdWithReqInfo:(RequestInfo *)reqInfo adDelegate:(id<NoahSplashAdListener>)adDelegate;

/// 展示开屏广告
/// - Parameter viewController: 广告详情页控制器
- (void)showAdInViewController:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
