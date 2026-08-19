//
//  IAdTaskEventListener.h
//  NoahSDK
//
//  Created by 小瓜瓜 on 2021/6/29.
//  Copyright © 2021 zhongyang.ywx. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TaskEvent;

NS_ASSUME_NONNULL_BEGIN

@protocol IAdTaskEventListener <NSObject>

@optional
/**
 *  事件回调
 */
-(void)onEvent:(TaskEvent *_Nonnull) event;

@end



NS_ASSUME_NONNULL_END
