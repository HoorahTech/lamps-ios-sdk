//
//  SQRHCBannerView.h
//  ShuQiHCSDK
//
//  Created by zhongyang on 2021/5/18.
//  Copyright © 2021 ShuQi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SQRHCBannerView : UIView

// 广告退出时 动画停止
@property(nonatomic,assign) BOOL isEnd;
// 垂直扩展区域，用于外部控件排版
@property(nonatomic,assign) float heightExtend;

// 需外部传入
// 可选
// actionBlock        点击事件 可在外面添加事件
// 必选
// bottomLogoHight    媒体端传入  -1：全屏  其他：半屏(底部带有logo)
// extendCView        外部容器
-(void)showWithData:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
