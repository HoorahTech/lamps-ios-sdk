//
//  NANativeCustomViewProtocol.h
//  NoahSDK
//
//  Created by zzyong on 2022/1/6.
//  Copyright © 2022 Alibaba Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, NANativeCustomViewType) {
    NANativeCustomViewCoverTopRight    = 0, ///< 封面右上
    NANativeCustomViewCoverTopLeft     = 1, ///< 封面左上
    NANativeCustomViewCoverBottomLeft  = 2, ///< 封面左下
    NANativeCustomViewCoverBottomRight = 3, ///< 封面右下
    NANativeCustomViewAdTopRight       = 4, ///< 容器右上
    NANativeCustomViewAdTopLeft        = 5, ///< 容器左上
    NANativeCustomViewAdBottomLeft     = 6, ///< 容器左下
    NANativeCustomViewAdBottomRight    = 7, ///< 容器右下
};

typedef NS_ENUM(NSInteger, NANativePaddingPositionType) {
    NANativePaddingPositionTopRight    = 0, ///< 相对右上距离
    NANativePaddingPositionTopLeft     = 1, ///< 相对左上距离
    NANativePaddingPositionBottomLeft  = 2, ///< 相对左下距离
    NANativePaddingPositionBottomRight = 3, ///< 相对右下距离
};

@protocol NANativeCustomViewProtocol <NSObject>

- (NANativeCustomViewType)nativeCustomViewType;

@optional

/// 广告自定义 View内边距
- (CGSize)setupCustomViewPadding:(NANativePaddingPositionType)type;

@end

NS_ASSUME_NONNULL_END
