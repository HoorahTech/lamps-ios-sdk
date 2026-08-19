//
//  MeidaView.h
//  NoahSDK
//
//  Created by Reus on 2020/12/3.
//  Copyright © 2020 zhongyang.ywx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NoahSDK/BaseMediaView.h>

@class NativeAd;
@class BaseMediaView;

NS_ASSUME_NONNULL_BEGIN

@interface MediaView : BaseMediaView

-(void)setNativeAd:(NativeAd *)ad;  

@end

NS_ASSUME_NONNULL_END
