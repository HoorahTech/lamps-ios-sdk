//
//  NAThreadUtil.h
//  NoahSDK
//
//  Created by zzyong on 2021/11/11.
//  Copyright © 2021 Alibaba Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C"{
#endif

/// UI 主线程同步执行
/// ⚠️⚠️⚠️ 如果在 SDK 主线程中切换至UI主线程，请务必注意是否会因为媒体 App 的 UI 主线程繁忙而阻塞当前 SDK 主线程 ⚠️⚠️⚠️
/// 如非必要请使用 runOnMainAsync
void runOnMain(dispatch_block_t block);

/// UI 主线程异步执行
void runOnMainAsync(dispatch_block_t block);

/// UI 主线程执行。如果当前线程是主线程，则是直接主线程同步执行任务。如果当前线程是子线程，则是让主线程异步执行任务。
void runOnMainAsyncFromSubThread(dispatch_block_t block);

/// NoahSDK 主队列，类似主队列
/// 在子线程执行耗时广告相关业务逻辑完成后，请务必将对应回调任务派发至 SDK 主队列执行，以防止发生多线程问题
/// [注意]：耗时任务请勿使用该队列，建议使用 runOnConcurrent ！！！
void runOnSDKMain(dispatch_block_t block);

/// NoahSDK 同步主队列！
void runOnSDKMainSync(dispatch_block_t block);

/// NoahSDK 主队列延时任务
/// @param delay 延时间隔，单位：秒
/// @param block 任务
void runAfterOnSDKMain(double delay, dispatch_block_t block);

/// Wa日志串行队列
void runOnWa(dispatch_block_t block);
void runAfterOnWa(double delay, dispatch_block_t block);

/// 默认优先级并发队列
void runOnConcurrent(dispatch_block_t block);

/// 系统全局并发队列
void runOnGlobalQueue(dispatch_block_t block);

/// 图片高斯模糊专用队列
void runOnBlurImg(dispatch_block_t block);

/// Try catch call
void tryCall(dispatch_block_t block);

void tryCatchCall(dispatch_block_t block, dispatch_block_t catchBlock);

/// block 必须由 dispatch_block_create 创建
void cancleDelayCall(dispatch_block_t block);

#ifdef __cplusplus
}
#endif
