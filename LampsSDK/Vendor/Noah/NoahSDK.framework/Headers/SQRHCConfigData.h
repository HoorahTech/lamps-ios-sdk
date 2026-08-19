//
//  SQRHCConfigData.h
//  ShuQiHCSDK
//
//  Created by zhongyang on 2021/5/20.
//  Copyright © 2021 ShuQi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SQRHCConfigData : NSObject

// noah中请求需要拉取对应展位的appname，在noah SDK中传入
@property (nonatomic,copy,nullable)NSString *app_name;
// 调整UC里面以前注册appname的缺陷，只在UC里面设置即可
@property (nonatomic,copy,nullable)NSString *splash_app_name;


+(SQRHCConfigData *)sharedInstance;
// 提前预加载
-(void)getConfigDataArray:(NSArray *)testIdArray;
// 获取本地配置
-(NSDictionary *)getLocalConfigData;

@end

NS_ASSUME_NONNULL_END
