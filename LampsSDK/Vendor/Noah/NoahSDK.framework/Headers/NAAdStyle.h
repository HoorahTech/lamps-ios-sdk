//
//  NAAdStyle.h
//  NoahSDK
//
//  Created by zzyong on 2022/5/18.
//  Copyright © 2022 Alibaba Inc. All rights reserved.
//

#ifndef NAAdStyle_h
#define NAAdStyle_h

#import <Foundation/Foundation.h>

/// 广告类型
typedef NS_ENUM(NSInteger, NAAdCreateType) {
    CREATE_TYPE_UNKNOWN                 = -1, ///< 未知
    CREATE_TYPE_HOR_LARGE               = 1,  ///< 横向大图
    CREATE_TYPE_HOR_SMALL               = 2,  ///< 横向小图
    CREATE_TYPE_GROUP                   = 3,  ///< 组图
    CREATE_TYPE_HOR_VIDEO               = 4,  ///< 横向视频
    CREATE_TYPE_VER_VIDEO               = 5,  ///< 纵向视频
    CREATE_TYPE_REWARD                  = 6,  ///< 激励视频
    CREATE_TYPE_SPLASH                  = 7,  ///< 闪屏
    CREATE_TYPE_BANNER                  = 8,  ///< banner
    CREATE_TYPE_VER_LARGE               = 9,  ///< 纵向大图
    CREATE_TYPE_LIVE_STREAM             = 13, ///< 直播拉流广告
    CREATE_TYPE_LIVE                    = 14, ///< 直播广告
    CREATE_TYPE_SPLASH_HALF_IMAGE       = 15, ///< 开屏-半屏图片广告
    CREATE_TYPE_SPLASH_FULL_IMAGE       = 16, ///< 开屏-全屏图片广告
    CREATE_TYPE_SPLASH_HALF_VIDEO       = 17, ///< 开屏-半屏视频广告
    CREATE_TYPE_SPLASH_FULL_VIDEO       = 18, ///< 开屏-全屏视频广告
    CREATE_TYPE_LIVE_HOR                = 19, ///< 直播横屏样式广告
};

#endif /* NAAdStyle_h */
