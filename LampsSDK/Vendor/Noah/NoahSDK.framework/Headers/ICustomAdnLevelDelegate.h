//
//  INoahCustomAdnCreator.h
//  NoahSDK
//
//  Created by Reus on 2022/1/19.
//  Copyright © 2022 Alibaba Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ICustomAdnLevelDelegate <NSObject>

-(BOOL) needCreate:(BOOL)isMarketAdvance;

@end

NS_ASSUME_NONNULL_END
