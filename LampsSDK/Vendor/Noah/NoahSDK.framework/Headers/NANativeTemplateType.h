//
//  NANativeTemplateType.h
//  NoahSDK
//
//  Created by zzyong on 2022/1/6.
//  Copyright © 2022 Alibaba Inc. All rights reserved.
//

#ifndef NANativeTemplateType_h
#define NANativeTemplateType_h

typedef NS_ENUM(NSInteger, NANativeTemplateType) {
    NANativeTemplateTIBT         = 1,  ///< 上图下文
    NANativeTemplateLIRT         = 3,  ///< 左图右文
    NANativeTemplateVertical     = 5,  ///< 竖版
    NANativeTemplate3ImgBanner   = 6,  ///< 三图Banner
    NANativeTemplateTIBTLive     = 9,  ///< 上图下文直播样式
    NANativeTemplateTVOne        = 11, ///< 电视机样式1
    NANativeTemplateTVTwo        = 12, ///< 电视机样式2
    NANativeTemplateBannerLive   = 14, ///< banner直播
    NANativeTemplateFifteen      = 15, ///< 15号样式
    NANativeTemplateDoubleBanner = 16, ///< 双banner样式
    NANativeTemplateThreeMerger  = 17, ///< 插页3拼样式
};

#endif /* NANativeTemplateType_h */
