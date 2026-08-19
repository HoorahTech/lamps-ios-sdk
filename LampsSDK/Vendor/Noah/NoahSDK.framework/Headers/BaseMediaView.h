//
//  BaseMediaView.h
//  NoahSDK
//
//  Created by Reus on 2020/12/3.
//  Copyright © 2020 zhongyang.ywx. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NativeAdapter;

NS_ASSUME_NONNULL_BEGIN

@interface BaseMediaView : UIView

-(void)setNativeAd:(NativeAdapter *)ad;

@end

NS_ASSUME_NONNULL_END
