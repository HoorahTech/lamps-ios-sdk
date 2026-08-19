//
//  SQRHuiChuanAdFetcherSchemeManager.h
//  Pods
//
//  Created by ali on 2020/8/5.
//

#import <UIKit/UIKit.h>

#ifndef SQRHuiChuanAdFetcherSchemeManager_h
#define SQRHuiChuanAdFetcherSchemeManager_h

typedef NS_ENUM(NSInteger, SchemeResult){
    SchemeSuccess,
    SchemeFailSinceUninstall,
    SchemeFailSinceDeny,
    SchemeFailSinceUserDeny,
    SchemeFailSinceSystemFail,
    
    SchemeFailSinceInvalidScheme,
    SchemeFailSinceOtherOpening,
};

typedef NS_ENUM(NSInteger, HuiChuanUrlType){
    HuiChuanUrlDeepLink,
    HuiChuanUrlUniversalLink
};

/// 汇川点击之后的跳端行为定制    目前只有UC在用
@protocol SQRHuiChuanAdFetcherSchemeManager <NSObject>
- (void)openThirdDplink:(NSString *)dplink
                    ulk:(NSString *)ulk
               clickUrl:(NSString *)clickUrl
                 params:(NSDictionary *)params
                handler:(void(^)(SchemeResult result, HuiChuanUrlType urlType))completion;

// 关注接口
- (void)follow:(NSDictionary *)dic handler:(void(^)(BOOL result))completion;
// 获取直播窗口
- (UIView *)getZhiboView:(NSString *)url size:(CGSize)size;
// UC链接打开
- (void)ucOpenUrl:(NSString *)url;
// 直播接口打点
-(void)spmLiveRequest;
-(void)spmLiveResponse:(NSDictionary *)dic;
// 设置汇川开屏是否有视频样式 0 无；1 有
-(void)hcSetIsVideoShow:(NSString *)isVideoShow;

@optional

// 设置topview类型，=0，没有topview，=1 明投topview，=2 暗投topview
-(void)hcSetTopviewType:(NSString *)topviewType;

@end

#endif /* SQRHuiChuanAdFetcherSchemeManager_h */
