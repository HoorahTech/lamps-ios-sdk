//
//  IAdPreloadListener.h
//  NoahSDK
//
//  Created by Reus on 2020/11/18.
//  Copyright © 2020 zhongyang.ywx. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AdError;

NS_ASSUME_NONNULL_BEGIN

@protocol IAdPreloadListener <NSObject>

/**
 * 预加载广告成功回调
 */
-(void)onAdPreLoaded;
/**
 * 预加载广告失败回调
 */
-(void)onAdPreError:(AdError *)error;

@end

NS_ASSUME_NONNULL_END
