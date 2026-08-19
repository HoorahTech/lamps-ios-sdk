//
//  Image.h
//  NoahSDK
//
//  Created by Reus on 2020/11/3.
//  Copyright © 2020 zhongyang.ywx. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Image : NSObject

- (instancetype)init:(NSString *)url width:(CGFloat)width height:(CGFloat)height;

/// 图片链接
- (NSString *)getUrl;

/// 图片宽
- (CGFloat)getWidth;

/// 图片高
- (CGFloat)getHeight;

@end

NS_ASSUME_NONNULL_END
