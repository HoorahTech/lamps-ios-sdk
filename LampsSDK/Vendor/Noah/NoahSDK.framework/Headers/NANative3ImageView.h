//
//  NANative3ImageView.h
//  NoahSDK
//
//  Created by zzyong on 2021/12/20.
//  Copyright © 2021 Alibaba Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, NA3ImgLayoutType) {
    NA3ImgLayoutNormal = 0, ///< 横向
    NA3ImgLayoutStack  = 1, ///< 品字堆叠
};

NS_ASSUME_NONNULL_BEGIN

@interface NANative3ImageView : UIView

@property (nonatomic, assign) NA3ImgLayoutType imgLayoutType;

/// 图片拉伸模式
@property (nonatomic, assign) UIViewContentMode imgContentMode;

/// 图片背景颜色
@property (nonatomic, strong) UIColor *imageBgColor;

/// 图片圆角
@property (nonatomic, assign) CGFloat imgCornerRadius;

/// 图片横向间距，默认 0
@property (nonatomic, assign) CGFloat itemSpacing;

/// 是否需要高斯模糊背景
@property (nonatomic, assign) BOOL isNeedBlurEffectBg;

/// 设置图片
- (void)setImagesWithURLStringList:(nullable NSArray<NSString *> *)urlStringList
                      placeholderImage:(nullable UIImage *)placeholder;

@end

NS_ASSUME_NONNULL_END
