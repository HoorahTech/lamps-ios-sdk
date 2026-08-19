//
//  HCShakeDefineHeader.h
//  ShuQiHCSDK
//
//  Created by hwh on 2023/11/15.
//  Copyright © 2023 Alibaba Inc. All rights reserved.
//

#ifndef HCShakeDefineHeader_h
#define HCShakeDefineHeader_h

#import <Foundation/Foundation.h>

#define HC_SHAKE_BUILD_ENABLE //是否需要摇一摇（不需要时，则在编译前注释掉这一行即可; 需要时，则在编译前放开这一行即可）

typedef NS_ENUM(NSUInteger, HCShakeSwingType) {
    HCShakeSwingSingleSide   = 0,    ///< 单边角度满足
    HCShakeSwingBothSide     = 1,    ///< 双边角度满足
    HCShakeSwingSingleReturn = 2,    ///< 单边角度满足并回正
};

typedef NS_ENUM(int, HCShakeViewDestroyType) {
    HCShakeViewDestroyTypeUnknown  = -1,    ///< 未知类型
    HCShakeViewDestroyTypeNormal   = 0,    ///< 常规类型
    HCShakeViewDestroyTypeOpt      = 1,    ///< 优化类型
};

#endif /* HCShakeDefineHeader_h */
