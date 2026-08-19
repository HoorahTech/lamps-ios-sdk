//
//  NAInternalHeaders.h
//  NoahSDK
//
//  Created by 蛮牛 on 2025/5/27.
//  Copyright © 2025 Alibaba Inc. All rights reserved.
//

#if NA_EXTERNAL == 0

#import <NoahSDK/NoahSdk+Private.h>
#import <NoahSDK/NoahSdkConfig+Private.h>
#import <NoahSDK/RequestInfo+Private.h>
#import <NoahSDK/NABaseAd+Private.h>
#import <NoahSDK/RewardedVideoAd+Private.h>
#import <NoahSDK/BaseNativeAd+Private.h>
#import <NoahSDK/NativeAd+Private.h>
#import <NoahSDK/SplashAd+Private.h>

// 全局配置
#import <NoahSDK/GlobalConfig.h>

// 广告对象
#import <NoahSDK/NASplashWindow.h>
#import <NoahSDK/NADrawAd.h>
#import <NoahSDK/NALiveInfo.h>
#import <NoahSDK/NALiveCouponInfo.h>
#import <NoahSDK/NALiveCouponBannerView.h>
#import <NoahSDK/NAAdEvent.h>
#import <NoahSDK/SdkAdDetail.h>
#import <NoahSDK/NAAdnIdDefines.h>

// 广告代理
#import <NoahSDK/NADrawAdListener.h>

// 广告视图组件
#import <NoahSDK/BaseNativeAdView.h>
#import <NoahSDK/BaseMediaView.h>
#import <NoahSDK/NativeAdView.h>
#import <NoahSDK/MediaView.h>
#import <NoahSDK/SdkAssets.h>
#import <NoahSDK/NACarouselView.h>
#import <NoahSDK/NAScrollLabel.h>
#import <NoahSDK/NACarouselModel.h>
#import <NoahSDK/NACarouselCellModel.h>
#import <NoahSDK/NAVideoInfoModel.h>

// 广告媒体端参数代理
#import <NoahSDK/TaskEvent.h>
#import <NoahSDK/IAdTaskEventListener.h>
#import <NoahSDK/IAdPreloadListener.h>
#import <NoahSDK/ICustomAdnLevelDelegate.h>

// Base
#import <NoahSDK/NAThreadUtil.h>
#import <NoahSDK/NALog.h>
#import <NoahSDK/NAMockSettingController.h>
#import <NoahSDK/MonitorInfoManager.h>
#import <NoahSDK/NoahConfig.h>

// 协议
#import <NoahSDK/INAShareAdapter.h>
#import <NoahSDK/NAAppInfoDataSource.h>
#import <NoahSDK/INoahAdDetailParser.h>

// custom adn
#import <NoahSDK/NoahCustomAdClassRegister.h>
#import <NoahSDK/NoahCustomSplashAdProtocol.h>
#import <NoahSDK/NoahCustomSplashAdDelegate.h>
#import <NoahSDK/NoahCustomParamsKey.h>
// custom adn native
#import <NoahSDK/NoahCustomNativeAdProtocol.h>
#import <NoahSDK/NoahCustomNativeAdDelegate.h>
// custom adn draw
#import <NoahSDK/NACustomDrawAdProtocol.h>
#import <NoahSDK/NACustomDrawAdDelegate.h>

// 不喜欢配置
#import <NoahSDK/NADisslikeConfig.h>

// 汇川广告主
#import <NoahSDK/NAAdReplaceCacheManager.h>

// 异步查奖
#import <NoahSDK/NAQueryRewardCodeDefine.h>

// 三方SDK竞价信息回传
#import <NoahSDK/NABidUploadManager.h>

#import <NoahSDK/NANative3ImageView.h>
#import <NoahSDK/NANativeImageView.h>

#import <NoahSDK/NARepeatAdRenderManager.h>

#import <NoahSDK/NATaobaoRtaManager.h>
#import <NoahSDK/NAGroupBudgetAdapter.h>


// HC
#import <NoahSDK/SQRHuiChuanResponseModel.h>
#import <NoahSDK/SQRHuiChuanAdView.h>
#import <NoahSDK/SQRHuiChuanAdFetcher.h>
#import <NoahSDK/HCAdStreamFlowReporter.h>
#import <NoahSDK/SQRHuiChuanAdFetcherDataSource.h>
#import <NoahSDK/SQRHCAdFetcherEncoder.h>
#import <NoahSDK/SQRHuiChuanHeaderModel.h>
#import <NoahSDK/SQRHuiChuanAdFetcherSchemeManager.h>
#import <NoahSDK/HCNoahDataProtocol.h>
#import <NoahSDK/HCRewardAdFetcherProtocol.h>
#import <NoahSDK/SQRHCConfigData.h>
#import <NoahSDK/SQRHCSplashADView.h>
#import <NoahSDK/SQRHuiChuanScrollUnlockView.h>
#import <NoahSDK/HCShakeView.h>
#import <NoahSDK/SQRHCBannerView.h>
#import <NoahSDK/HCShakeDefineHeader.h>
#import <NoahSDK/SQRHCVideoPlayer.h>
#import <NoahSDK/SQRHuiChuanSplashAd.h>
#import <NoahSDK/SQRHuiChuanRewardVideoAd.h>

#endif
