//
//  NAVideoInfoModel.h
//  NoahSDK
//
//  Created by hwh on 2022/11/7.
//  Copyright © 2022 Alibaba Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NAVideoInfoModel : NSObject
@property (nonatomic, copy) NSString *videoUrl;
@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, assign) NSInteger videoDuration;//单位毫秒
@property (nonatomic, assign) NSInteger videoResolutionWidth;
@property (nonatomic, assign) NSInteger videoResolutionHeight;
- (BOOL)videoInfoIsValid;
@end

NS_ASSUME_NONNULL_END
