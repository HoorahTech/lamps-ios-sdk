//
//  NACarouselModel.h
//  NoahSDK
//
//  Created by chenjunru on 2023/8/9.
//  Copyright © 2023 Alibaba Inc. All rights reserved.
//

#if NA_EXTERNAL == 0

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NACarouselCellModel;

@interface NACarouselModel : NSObject

@property (nonatomic, strong) NSArray<NACarouselCellModel *> *itemModelList;

// 是否开启视频缓存（默认：YES）
@property (nonatomic, assign) BOOL videoCacheEnable;

// 是否开启左边阻尼效果 默认NO
@property (nonatomic, assign) BOOL openLeftDampingEffect;

// 是否关闭视屏播放 默认NO
@property (nonatomic, assign) BOOL closeVideoPlay;

// 元素圆角(文本item不会使用此配置) 默认 3.0
@property (nonatomic, assign) CGFloat itemCornerRadius;

// 元素之间间距大小 默认 3.0
@property (nonatomic, assign) CGFloat itemSpacing;

// 第一个元素与滑动框的间距大小 默认0.0
@property (nonatomic, assign) CGFloat prefixSpacing;

// 是否产生频道联动 默认NO
@property (nonatomic, assign) BOOL openChannelLinkage;
// 左边触发频道联动最大距离 默认0.0
@property (nonatomic, assign) CGFloat leftMaxNonLinkageDistance;
// 右边触发频道联动最大距离 默认0.0
@property (nonatomic, assign) CGFloat rightMaxNonLinkageDistance;

// 图片或者视频 cell的宽高比 （宽 / 高），默认：390.f / 586.f
@property (nonatomic, assign) CGFloat imageItemAspectRatio;

// 文本 cell的宽高比 （宽 / 高），默认：180.f / 586.f
@property (nonatomic, assign) CGFloat textItemAspectRatio;

@end

NS_ASSUME_NONNULL_END

#endif
