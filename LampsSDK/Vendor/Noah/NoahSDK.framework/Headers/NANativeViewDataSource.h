//
//  NANativeViewDataSource.h
//  NoahSDK
//
//  Created by zzyong on 2022/1/5.
//  Copyright © 2022 Alibaba Inc. All rights reserved.
//

#import <NoahSDK/NANativeTemplateType.h>
#import <NoahSDK/NANativeCustomViewProtocol.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NANativeViewProtocol;

@protocol NANativeViewDataSource <NSObject>

@optional

///  广告自定义 View，目前仅支持：NANativeCustomViewType
/// 【注意】默认都是贴边（0, 0) 可通过NANativeCustomViewProtocol的setupCustomViewPadding设置边距
- (nullable NSArray<UIView<NANativeCustomViewProtocol> *> *)nativeAdCustomViews;

/// 原生广告尺寸，返回 CGSizeZero 则会使用模版默认尺寸
/// 仅 NANativeTemplateLIRT 和 NANativeTemplate3ImgBanner 可以自定义高度，其他类型高度自适应的，会自动忽略 height ！！！
/// @param type 模版类型
- (CGSize)nativeAdSizeForTemplateType:(NANativeTemplateType)type;

/// 原生广告最大高度限制， 目前仅支持：NANativeTemplateTIBT 、 NANativeTemplateTVOne 、NANativeTemplateVertical、NANativeTemplateTVTwo、NANativeTemplateFifteen、NANativeTemplateTIBTLive
- (CGFloat)nativeAdMaxHeightLimit;

/// 模版广告封面（宽 / 高）比例自定义，返回 0 则使用模版默认比例
/// 仅适用于 NANativeTemplateTIBT 、NANativeTemplateVertical 、 NANativeTemplateTVOne、NANativeTemplateTVTwo、NANativeTemplateFifteen、NANativeTemplateTIBTLive
- (CGFloat)nativeAdCoverScaleForTemplateType:(NANativeTemplateType)type;

@end

NS_ASSUME_NONNULL_END
