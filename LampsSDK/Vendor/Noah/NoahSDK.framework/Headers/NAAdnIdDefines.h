//
//  NAAdnIdDefines.h
//  NoahSDK
//
//  Created by zzyong on 2023/5/31.
//  Copyright © 2023 Alibaba Inc. All rights reserved.
//

#ifndef NAAdnIdDefines_h
#define NAAdnIdDefines_h

typedef NS_ENUM(NSUInteger, AdnIdType) {
    ADN_ID_VUNGLE     = 10000,
    ADN_ID_STARAPP    = 10001,
    ADN_ID_IRONSOURCE = 10002,
    ADN_ID_ADCOLONY   = 10003,
    ADN_ID_APPLOVIN   = 10004,
    ADN_ID_TAPJOY     = 10005,
    ADN_ID_ADMOB      = 10006,
    ADN_ID_FACEBOOK   = 10007,
    ADN_ID_UCADS      = 10008,
    ADN_ID_UCADS_HIGH = 10009,
    ADN_ID_UNITY      = 10010,
    ADN_ID_HUICHUAN        = 1,
    ADN_ID_PANGOLIN        = 2,
    ADN_ID_TENCENT         = 3,
    ADN_ID_HONGSHUN        = 4,
    ADN_ID_PAIJIN          = 5,
    ADN_ID_KAIJIA          = 6,
    ADN_ID_BAIDU           = 7,
    ADN_ID_KUAISHOU        = 8,
    ADN_ID_ALIMAMA         = 9,
    ADN_ID_JINGDONG        = 11, ///< 京东
    ADN_ID_UC_ALIMAMA_BU   = 12, ///< UC 妈妈 custom类型
    ADN_ID_UC_ALIMAMA_MT   = 13, ///< UC 妈妈 custom类型 Market （现已接入汇川系统）
    ADN_ID_UC_HC_BU        = 14, ///< UC 汇川 custom类型 品牌
    ADN_ID_UC_HC_MT        = 15, ///< UC 汇川 custom类型 兜底
    ADN_ID_UC_NA_INFO      = 16, ///< UC 信息流广告 & UC 视频流广告
    ADN_ID_KLEVIN          = 17, ///< 游可赢
    ADN_ID_TANX            = 18, ///< 阿里妈妈
    ADN_ID_CUSTOM_WOLONG   = 19, ///< 卧龙广告，custom类型，目前用于UC搜索托管页Noah广告，之后夸克搜索托管页也有可能接入
    ADN_ID_XUNFEI          = 22, ///< 讯飞
    ADN_ID_QUMENG          = 27, ///< 趣盟
    ADN_ID_DUOMENG         = 28, ///< 多盟
    ADN_ID_WOLONG          = 29, ///< 卧龙
    ADN_ID_STREAM          = 30, ///< 流式激励
    ADN_ID_MEISHU          = 31, ///< 美数
    ADN_ID_FANWEI          = 32, ///< 泛为
    ADN_ID_YOUKU           = 33, ///< 优酷
    ADN_ID_UBIX            = 34, ///< 即刻聚合(UbiX)
    ADN_ID_WANGMAI         = 35, ///< 旺脉
};

#endif /* NAAdnIdDefines_h */
