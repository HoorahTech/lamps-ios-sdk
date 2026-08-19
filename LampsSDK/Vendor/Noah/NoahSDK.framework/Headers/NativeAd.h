//
//  NativeAd.h
//  NoahSDK
//
//  Created by Reus on 2020/12/2.
//  Copyright © 2020 zhongyang.ywx. All rights reserved.
//

#import "BaseNativeAd.h"
#import "NAAdAssets.h"
#import "NoahSdkNativeListener.h"

NS_ASSUME_NONNULL_BEGIN

@interface NativeAd : BaseNativeAd 

/// 广告物料
@property(nonatomic, strong, readonly) NAAdAssets *adAssets;

/// 广告落地页控制器，必须设置，否则点击无法响应！
@property(nonatomic, weak) UIViewController *adViewController;

/// 广告回调事件代理，默认会使用请求广告的方法中传入的listenner，如非必要不建议通过此属性重新设置
@property(nonatomic,weak)id<NoahSdkNativeListener> delegate;

/// 是否展示（媒体可传入，一般不使用）
@property (nonatomic, assign) BOOL isShowing;

/// 广告加载
/// - Parameters:
///   - reqInfo: 请求信息
///   - adDelegate: 广告事件回调代理
+ (void)loadAdWithReqInfo:(RequestInfo *)reqInfo adDelegate:(id<NoahSdkNativeListener>)adDelegate;

/// banner 优惠券
- (nullable UIView *)getBannerVoucherView;

@end

NS_ASSUME_NONNULL_END
