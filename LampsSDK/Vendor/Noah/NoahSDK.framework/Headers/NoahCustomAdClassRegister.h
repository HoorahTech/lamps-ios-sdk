//
//  NoahCustomAdClassRegister.h
//  NoahSDK
//
//  Created by zhongyang on 2021/12/27.
//  Copyright © 2021 Alibaba Inc. All rights reserved.
//

#if NA_EXTERNAL == 0

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NoahCustomSplashAdProtocol;
@protocol NoahCustomNativeAdProtocol;
@protocol NACustomDrawAdProtocol;


typedef id<NoahCustomSplashAdProtocol> _Nonnull(^CustomSpashAdCreaterBlock)(void);
typedef id<NoahCustomNativeAdProtocol> _Nonnull(^CustomNativeAdCreaterBlock)(void);
typedef id<NACustomDrawAdProtocol> _Nonnull(^NACustomDrawAdCreaterBlock)(void);



@interface NoahCustomAdClassRegister : NSObject

+(NoahCustomAdClassRegister *)sharedInstance;
// customSpashAdCreaterBlock 构造 NoahCustomSplashAdProtocol alloc 简单对象即可，进一步初始化在noah实现
// 开屏splash
-(void)registSplashAdWithAdnId:(NSString *)adnId
     customSpashAdCreaterBlock:(CustomSpashAdCreaterBlock)customSpashAdCreaterBlock;
-(CustomSpashAdCreaterBlock)getSpashAdCreaterBlockWithAdnId:(NSString *)adnId;
// 原生native
-(void)registNativeAdWithAdnId:(NSString *)adnId
     customNativeAdCreaterBlock:(CustomNativeAdCreaterBlock)customNativeAdCreaterBlock;
-(CustomNativeAdCreaterBlock)getNativeAdCreaterBlockWithAdnId:(NSString *)adnId;
// draw
-(void)registDrawAdWithAdnId:(NSString *)adnId
  naCustomDrawAdCreaterBlock:(NACustomDrawAdCreaterBlock)naCustomDrawAdCreaterBlock;
-(NACustomDrawAdCreaterBlock)getDrawAdCreaterBlockWithAdnId:(NSString *)adnId;


@end

NS_ASSUME_NONNULL_END

#endif
