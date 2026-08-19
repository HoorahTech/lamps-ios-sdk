//
//  NAAdEvent.h
//  NoahSDK
//
//  Created by chenlei on 2025/4/30.
//  Copyright © 2025 Alibaba Inc. All rights reserved.
//

#ifndef NAAdEvent_h
#define NAAdEvent_h

/// 广告事件
typedef NS_ENUM(NSUInteger, AD_EVENT) {
    AD_EVENT_VIDEO_STARTED       = 1,
    AD_EVENT_VIDEO_PROGRESS      = 2, ///< 视频播放进度，不进行WA统计，太频繁了，激励视频有单独 Key 统计进度
    AD_EVENT_REWARDED            = 3, ///< 激励视频广告获得奖励
    AD_EVENT_VIDEO_END           = 4, ///< 视频播放结束
    AD_EVENT_APK_DOWNLOAD_START  = 5,
    AD_EVENT_APK_DOWNLOAD_FAILED = 6,
    AD_EVENT_APK_DOWNLOAD_FINISH = 7,
    AD_EVENT_VIDEO_PAUSE         = 8,
    AD_EVENT_VIDEO_RESUME        = 9,
    AD_EVENT_SKIP                = 10, ///< 广告跳过
    AD_EVENT_TIMEOVER            = 11, ///< 广告倒计时结束，用于开屏
    AD_EVENT_WILL_CLOSED         = 12, ///< 广告即将关闭
    AD_EVENT_TOPVIEW_CLICK       = 13,
    AD_EVENT_TOPVIEW_CLOSE       = 14,
    AD_EVENT_TOPVIEW_TIMEOVER    = 15,
    AD_EVENT_DETAIL_VC_CLOSE     = 16, ///< 广告落地页关闭，用于开屏
    AD_EVENT_DRAWAD              = 17, ///< 沉浸流广告
    AD_EVENT_VIDEO_FAILED        = 18, ///< 视频播放失败
    AD_EVENT_FINISH_FEED_REWARD  = 60, ///< 原生激励广告完成浏览奖励
    AD_EVENT_CLICK_FEED_REWARD   = 61, ///< 原生激励广告点击浏览激励
    AD_EVENT_HC_QUERY_REWARD     = 90, ///< 下单激励广告查询上报
    AD_EVENT_HC_QUERY_SUCCESS    = 91, ///< 下单激励广告查询成功
    AD_EVENT_HC_QUERY_FAIL       = 92, ///< 下单激励广告查询失败
    AD_EVENT_TANX_REWARD_REQ     = 101, ///< TANX激励广告请求
    // 行为激励回调事件（点淘适配）
    AD_EVENT_ENTER_LANDING_PAGE             = 103, ///< 进入 H5 落地页
    AD_EVENT_RETURN_FROM_LANDING_PAGE       = 104, ///< 从 H5 落地页返回
    AD_EVENT_JUMP_TO_EXTERNAL_APP           = 105, ///< 外部跳转（跳转到其他 App）
    AD_EVENT_RETURN_FROM_EXTERNAL_APP       = 106, ///< 从外部跳转返回
    AD_EVENT_ENTER_APP_STORE                = 107, ///< 进入 AppStore 半屏详情
    AD_EVENT_LEAVE_APP_STORE_PAGE           = 108, ///< 从 AppStore 半屏详情返回
    AD_EVENT_H5_LOAD_RESULT                = 109, ///< H5加载结果
    AD_EVENT_GAME_TRIAL_DURATION           = 110, ///< 游戏试玩时长
    AD_EVENT_RESOURCE_DEGRADE              = 111, ///< 资源缺失降级
};

#endif /* NAAdEvent_h */
