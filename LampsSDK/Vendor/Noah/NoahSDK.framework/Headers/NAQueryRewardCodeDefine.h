//
//  NAQueryRewardCodeDefine.h
//  NoahSDK
//
//  Created by wengcanzi on 2024/4/13.
//  Copyright © 2024 Alibaba Inc. All rights reserved.
//

#ifndef NAQueryRewardCodeDefine_h
#define NAQueryRewardCodeDefine_h

typedef NS_ENUM(int, NARewardQueryCode) {
    NARewardQueryTimeout       = -2, //查询超时
    NARewardQueryInternalError = -1, //网络错误
    NARewardQueryHasReward     = 0,  //查到奖励
    NARewardQueryNoReward      = 1,  //无奖励
    NARewardQueryNoAdn         = 3,  //没有需要查奖的adn
};

#endif /* NAQueryRewardHeader_h */
