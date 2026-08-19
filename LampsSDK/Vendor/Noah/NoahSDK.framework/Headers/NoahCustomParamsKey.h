//
//  NoahCustomParamsKey.h
//  NoahSDK
//
//  Created by Reus on 2022/1/20.
//  Copyright © 2022 Alibaba Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSInteger, NAVideoAutoPlayPolicy) {
    NAVideoAutoPlayWIFI = 0, // WIFI 才下自动播放
    NAVideoAutoPlayNOWIFI = 1, // 非WIFI 才下自动播放
    NAVideoAutoPlayAlways = 2, // 总是自动播放，无论网络条件
    NAVideoAutoPlayNever = 3, // 从不自动播放，无论网络条件
};

typedef NS_ENUM(NSInteger, NANFClientMixAdType) {
    NANFClientMixAdTypeNormal               = 1, // 普通广告
    NANFClientMixAdTypeAdd                  = 2, // 追加的广告
    NANFClientMixAdTypeNewRefreshFirst      = 3, // 下拉刷新的第一个广告
    NANFClientMixAdTypeEmptyAd              = 4, // 汇川没有填充的广告
};

typedef NS_ENUM(int16_t, NANativeAdClickArea) {
    NANativeAdClickAreaNormal           = 0,  ///< 通用
    NANativeAdClickAreaCoupon           = 301,///< 优惠券大图
    NANativeAdClickAreaCouponSmall      = 302,///< 优惠券小图
    NANativeAdClickAreaCouponBanner     = 303,///< 优惠券banner
    NANativeAdClickAreaChatBulletTop    = 306,///< 顶部弹幕View
    NANativeAdClickAreaChatBulletBottom = 307,///< 底部弹幕View
    NANativeAdClickAreaQcProductInfo    = 308,///< 千川商品信息View
    NANativeAdClickAreaDramaBottom      = 309,///< 底部短剧bar
    NANativeAdClickAreaDramaTop         = 310,///< 顶部短剧bar

};

// RequestInfo持有的Noah native custom 的key
// 外部媒体数据是否参与了竞价。外部参与了竞价，最后外部才能使用noah广告数据
static NSString* const NoahCS_HaveBid            = @"NoahCS_HaveBid";
// noah内部等待外部媒体获取广告数据时间
static NSString* const NoahCS_LoadWaitTime       = @"NoahCS_LoadWaitTime";
// 外部媒体等待noah的load是否超时
static NSString* const NoahCS_LoadIsTimeout      = @"NoahCS_LoadIsTimeout";
// 外部媒等待noah执行完load的block
static NSString* const NoahCS_LoadedBlock        = @"NoahCS_LoadedBlock";
// 外部媒体返回给noah的数据block
static NSString* const NoahCS_CsRspBlock         = @"NoahCS_CsRspBlock";
// 外部媒体返回给noah的数据
static NSString* const NoahCS_CsRspData          = @"NoahCS_CsRspData";
// 外部媒体返回给noah为空数据
static NSString* const NoahCS_CsRspNil           = @"NoahCS_CsRspNil";
// noah返回给外部媒体的回调block
static NSString* const NoahCS_NoahDataBlock      = @"NoahCS_NoahDataBlock";
// noah返回给外部媒体是否超时
static NSString* const NoahCS_NoahDataIsTimeout  = @"NoahCS_NoahDataIsTimeout";
// 外部媒体返回给noah的广告主信息
static NSString* const NoahCS_AdnAds             = @"NoahCS_AdnAds";
// 外部媒体返回给noah的汇川提价类型
static NSString* const NoahCS_HcRaiseUpType      = @"NoahCS_HcRaiseUpType";
// 汇川广告位置信息列表
static NSString* const NoahCS_HcAdPosInfoList    = @"NoahCS_HcAdPosInfoList";
// 外部媒体广告数据  包括 spm， ad,  ucInfoObj
// spm 目前有的字段 huichuan_ad_id  recoid  exp_tags  uc_abtest_tag  ad_search_id  hc_slot_id  channel_id
// ad 目前有的字段 dspBidPrice  dspPriority  dspBidFloor
static NSString* const NoahCS_adDic               = @"NoahCS_adDic";
static NSString* const NoahCS_dicTitle            = @"title";
static NSString* const NoahCS_dicSpm              = @"spm";
static NSString* const NoahCS_dicAd               = @"ad";
static NSString* const NoahCS_dicucInfoObj        = @"ucInfoObj";
static NSString* const NoahCS_addspBidPrice       = @"dspBidPrice";
static NSString* const NoahCS_addspPriority       = @"dspPriority";
static NSString* const NoahCS_addspBidFloor       = @"dspBidFloor";
static NSString* const NoahCS_adadnBidFloor       = @"adn_bid_floor";
static NSString* const NoahCS_spmhuichuan_ad_id   = @"huichuan_ad_id";
static NSString* const NoahCS_spmrecoid           = @"recoid";
static NSString* const NoahCS_spmexp_tags         = @"exp_tags";
static NSString* const NoahCS_spmexp_tags_exp     = @"exp";
static NSString* const NoahCS_spmexp_tags_exp_id  = @"exp_id";
static NSString* const NoahCS_spmexp_tags_flow_id = @"flow_id";
static NSString* const NoahCS_spmuc_abtest_tag    = @"uc_abtest_tag";
static NSString* const NoahCS_spmad_search_id     = @"ad_search_id";
static NSString* const NoahCS_spmhc_slot_id       = @"hc_slot_id";
static NSString* const NoahCS_spmchannel_id       = @"channel_id";
static NSString* const NoahCS_spmchannel_name     = @"channel_name";
static NSString* const NoahCS_spmhuichuan_wnurl   = @"huichuan_wnurl";
static NSString* const NoahCS_spmhc_raise_up_type     = @"hc_raise_up_type";
static NSString* const NoahCS_spmShowUrlHasSdkPrice   = @"showUrlHasSdkPrice";
static NSString* const NoahCS_spmClickUrlHasSdkPrice  = @"clickUrlHasSdkPrice";
static NSString* const NoahCS_adContent           = @"ad_content";
static NSString* const NoahCS_hcCharge            = @"hc_charge";
static NSString* const NoahCS_spmHcStyleType      = @"hc_style_type";
static NSString* const NoahCS_adSourceType        = @"ad_source_type";
static NSString* const NoahCS_spmHcAdPosValue     = @"hc_ad_pos_value";
static NSString* const NoahCS_adPosInfo           = @"ad_pos_info";

static NSString* const NoahCS_posInfoAdType         = @"pos_info_ad_type";
static NSString* const NoahCS_posInfoRefreshDay     = @"pos_info_refresh_day";
static NSString* const NoahCS_posInfoAdInterval     = @"pos_info_ad_interval";
static NSString* const NoahCS_posInfoContentPos     = @"pos_info_content_pos";
static NSString* const NoahCS_posInfoAdPosValue     = @"pos_info_ad_pos_value";
static NSString* const NoahCS_posInfoBehindInte     = @"pos_info_behind_interval";
static NSString* const NoahCS_posInfoXssListInfo    = @"pos_info_xss_list_info";
static NSString* const NoahCS_posInfoNeedGetOffset  = @"pos_info_need_get_offset";
static NSString* const NoahCS_posInfoItemId         = @"pos_info_item_id";

// 外部媒体noah返回的字段 信息流 & 沉浸流
static NSString* const Noah_title                = @"noah_title";
static NSString* const Noah_adnName              = @"noah_adnName";
static NSString* const Noah_adnId                = @"noah_adnId";
static NSString* const Noah_view                 = @"noah_view";
static NSString* const Noah_rigsView             = @"Noah_rigsView";
static NSString* const Noah_ucObj                = @"noah_ucObj";
static NSString* const Noah_ad                   = @"noah_ad";
static NSString* const Noah_csShowBlock          = @"noah_csShowBlock";
static NSString* const Noah_csClickBlock         = @"noah_csClickBlock";
static NSString* const Noah_csShowEndBlock       = @"noah_csShowEndBlock";
static NSString* const Noah_showStyle            = @"noah_showStyle";
static NSString* const Noah_btnTitle             = @"noah_btnTitle";
static NSString* const Noah_bgImag               = @"noah_bgImag";
static NSString* const Noah_isVideo              = @"noah_isVideo";
// 沉浸流
static NSString* const Noah_mediaPlayBlock        = @"noah_mediaPlayBlock";
static NSString* const Noah_mediaPauseBlock       = @"noah_mediaPauseBlock";
static NSString* const Noah_mediaResumeBlock      = @"noah_mediaResumeBlock";
static NSString* const Noah_mediaAutoResumeBlock  = @"noah_mediaAutoResumeBlock";
static NSString* const Noah_mediaMuteBlock        = @"noah_mediaMuteBlock";

extern NSString *const  NOAH_SDK_KEY_MARKET_APPKEYS_WHITE_LIST;
extern NSString *const  NOAH_SDK_KEY_ADN_TIMEOUT;

NS_ASSUME_NONNULL_END
