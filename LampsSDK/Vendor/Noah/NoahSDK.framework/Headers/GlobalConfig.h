//
//  GlobalConfig.h
//  Pods
//
//  Created by zhangliuke on 2020/8/10.
//

#import <Foundation/Foundation.h>

@protocol IImgLoaderAdapter;
@protocol IEncryptHelper;
@protocol INativeRender;
@protocol IMediaViewCreator;
@protocol INAShareAdapter;
@protocol INoahAdDetailParser;

extern int const Global_INIT_IMG_LOADER          ;
extern int const Global_INIT_PLAYER_CREATOR      ;
extern int const Global_INIT_CLICK_HANDLER       ;
extern int const Global_INIT_NATIVE_RENDER       ;
extern int const Global_INIT_SHARE_ADAPTER       ;
extern int const Global_INIT_DETAIL_PARSER       ;
extern int const Global_INIT_APP_COMMON_PARAMS;
// 暂时未用到
extern int const Global_INIT_HC_ENCRYPT_HELPER   ;


@interface GlobalConfig : NSObject

@property NSMutableDictionary *mOptions;
//是否需要给汇川sdk注入DataSource。默认为YES。增加此字段的背景：UC中接入了汇川，而且给汇川sdk注入了DataSource，也接入了noah sdk，然后noah sdk中也注入汇川的DataSource，那么，会有问题，所以，增加此字段控制，在UC中，会将此字段设置为NO。
// 目前UC如果 不是noah开屏则需要设置NO
@property (nonatomic, assign) BOOL isNeedRegisterHuichuanSDKDataSource;

// 默认NO， 快手是否开启UI动态化
@property (nonatomic, assign) BOOL ksIsEnableTK;

-(id)init:(NSMutableDictionary*)p;

// UC上使用  广点通&穿山甲 解析
-(id<INoahAdDetailParser>)getAdDetailParser;
// 公共参数  目前有 province,city,pkg_sver,ch
-(NSDictionary<NSString*,NSString*>*)getAppCommonParams;
// 获取 ATokenSDKSourceID
-(NSString *)getATokenSDKSourceID;
// 获取 ATokenSDKToken
-(NSString *)getATokenSDKToken;
// 获取 是否屏蔽CValue初始化
-(BOOL)getNeedAbandonInitCValue;
// 暂时未用到
-(id<IEncryptHelper>)getHcEncryptHelper;
-(id<INativeRender>)getNativeRender;
-(id<IMediaViewCreator>)getPlayerCreator;
-(id<INAShareAdapter>)getShareAdapter;

#if NA_EXTERNAL == 0
-(NSString *)getClientBwCg;
-(NSString *)getClientBwCh;
-(NSString *)getClientActTime;
-(BOOL)dramaAdNeedExtInfo;
#endif

@end
