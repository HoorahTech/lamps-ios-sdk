//
//  NANativeImageView.h
//  NoahSDK
//
//  Created by zzyong on 2021/12/20.
//  Copyright © 2021 Alibaba Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NANativeImageView : UIView

/// 图片拉伸模式
@property (nonatomic, assign) UIViewContentMode imgContentMode;

/// 是否需要高斯模糊背景
@property (nonatomic, assign) BOOL isNeedBlurEffectBg;

- (void)setImageWithURLString:(nullable NSString *)urlString
             placeholderImage:(nullable UIImage *)placeholder;

@end

NS_ASSUME_NONNULL_END
