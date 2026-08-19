//
//  NACarouselView.h
//  NoahSDK
//
//  Created by chenjunru on 2023/8/9.
//  Copyright © 2023 Alibaba Inc. All rights reserved.
//

#if NA_EXTERNAL == 0

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class NACarouselModel;

@protocol NACarouselViewDelegate <NSObject>

@optional

/// 松手后回调
/// - Parameters:
///   - offset: 滑动View的contentOffset
///   - leftDistance: 左边超出或即将超出的距离，即distance >= 0 如果没有超出返回 -1
///   - rightDistance: 右边超出或即将超出的距离，即distance >= 0 如果没有超出返回 -1
///   - scrollView: carouselView中的滑动View，暴露出来提供更自由度的操作和获取更多属性信息
- (void)carouselViewDidEndDraggingLocation:(CGPoint)offset
                          leftOverDistance:(CGFloat)leftDistance
                         rightOverDistance:(CGFloat)rightDistance
                                scrollView:(UIScrollView *)scrollView;

/// 滑动过程中超出左边极限距离后回调，只有在超出距离时回调
/// - Parameters:
///   - offset: 滑动View的contentOffset
///   - leftDistance: - leftDistance: 左边超出或即将超出的距离，即distance >= 0
///   - scrollView: carouselView中的滑动View，暴露出来提供更自由度的操作和获取更多属性信息
- (void)carouselViewDidScrollLocation:(CGPoint)offset
                     leftOverDistance:(CGFloat)leftDistance
                           scrollView:(UIScrollView *)scrollView;

/// 滑动过程中超过右边极限距离后回调，只有在超出距离时回调
/// - Parameters:
///   - offset: 滑动View的contentOffset
///   - rightDistance: 右边超出或即将超出的距离，即distance >= 0
///   - scrollView: carouselView中的滑动View，暴露出来提供更自由度的操作和获取更多属性信息
- (void)carouselViewDidScrollLocation:(CGPoint)offset
                    rightOverDistance:(CGFloat)rightDistance
                           scrollView:(UIScrollView *)scrollView;

@end

@interface NACarouselView : UIView

@property (nonatomic, weak) id <NACarouselViewDelegate> delegate;
@property (nonatomic, strong) NACarouselModel *model;

/// 暂停播放
- (void)videoPause;

/// 继续播放(不用考虑当前视频状态，内部会自主判断是起播还是续播)
- (void)videoResume;

@end

NS_ASSUME_NONNULL_END

#endif
