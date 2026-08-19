//
//  NoahConfig.h
//  NoahSDK
//
//  Created by hwh on 2025/6/3.
//  Copyright © 2025 Alibaba Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoahConfig : NSObject

+ (int)xssListSortByRule:(NSString *)appKey
                 slotKey:(NSString *)slotKey
             xssListInfo:(NSDictionary *)xssListInfo
              refreshDay:(int)refreshDay
         contentPlayTime:(int)contentPlayTime
              adInterval:(int)adInterval
              contentPos:(int)contentPos
              adPosValue:(int)adPosValue;

@end

NS_ASSUME_NONNULL_END
