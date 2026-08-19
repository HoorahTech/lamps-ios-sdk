//
//  NAAdAssets.h
//  NoahSDK
//
//  Created by zzyong on 2025/5/29.
//  Copyright © 2025 Alibaba Inc. All rights reserved.
//

#import "Image.h"
#import "NAAdStyle.h"

@class NAVoucherInfo;

typedef NS_ENUM(int, NAAdInteractionType) {
    NAAdInteractionPage     = 0, ///< 广告详情页类型
    NAAdInteractionDownload = 1, ///< 下载类型
};

NS_ASSUME_NONNULL_BEGIN

@interface NAAdAssets : NSObject

/// 广告标题
@property(nonatomic, strong) NSString *adTitle;

/// 广告描述
@property(nonatomic, strong) NSString *adDescription;

/// 广告来源
@property(nonatomic, strong) NSString *adSource;

/// 跳转按钮文案
@property(nonatomic, strong) NSString *adButtonText;

/// 广告图标
@property(nonatomic, strong) Image *adIcon;

/// 广告封面
@property(nonatomic, strong) NSArray<Image *> *adImgs;

/// 交互类型
@property(nonatomic, assign) NAAdInteractionType interactionType;

/// 是否视频广告
@property(nonatomic, assign) BOOL isVideo;

/// 广告样式
@property(nonatomic, assign) NAAdCreateType adStyle;

/// 广告 banner 优惠券信息
@property(nonatomic, strong, nullable) NAVoucherInfo *voucherInfo;

/// 广告扩展信息
@property(nonatomic, strong, nullable) NSDictionary *mediaExt;

@end

NS_ASSUME_NONNULL_END

