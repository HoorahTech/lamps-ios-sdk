//
//  NACarouselCellModel.h
//  NoahSDK
//
//  Created by chenjunru on 2023/8/9.
//  Copyright © 2023 Alibaba Inc. All rights reserved.
//

#if NA_EXTERNAL == 0

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, NACarouselCellType) {
    NACarouselCellTypeText   = 1, // 提示框
    NACarouselCellTypeImage  = 2,
    NACarouselCellTypeVideo  = 3
};

@class NAVideoInfoModel;

@interface NACarouselCellModel : NSObject

// Cell类型
@property (nonatomic, assign) NACarouselCellType type;

// 图片类型
@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, strong) UIImage *placeholder;

// 文本类型
@property (nonatomic, copy) NSString *promptText;//默认：继续滑动进入详情
@property (nonatomic, strong) UIFont *promptFont;
@property (nonatomic, strong) UIColor *promptBackgroundColor;

// 视频类型
@property (nonatomic, strong) NAVideoInfoModel *videoInfo;

// 元素圆角(文本item不会使用此配置) 默认 0.f
@property (nonatomic, assign) CGFloat itemCornerRadius;

@end

NS_ASSUME_NONNULL_END

#endif
