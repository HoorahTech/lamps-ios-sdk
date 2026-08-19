//
//  INAParseAdDetail.h
//  NoahSDK
//
//  Created by Reus on 2022/1/18.
//  Copyright © 2022 Alibaba Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol INoahAdDetailParser <NSObject>

-(NSDictionary *)parseWithJson:(NSString*)json adnId:(int)adnId slotId:(NSString*)slotId adId:(NSString*)adId;

@end

NS_ASSUME_NONNULL_END
