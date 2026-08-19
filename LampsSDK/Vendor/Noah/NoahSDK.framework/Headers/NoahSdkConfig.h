//
//  NoahSdkConfig.h
//  Pods
//
//  Created by zhangliuke on 2020/8/7.
//

#import "SdkConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoahSdkConfig : SdkConfig

/// 应用 ID
@property(nonatomic, strong) NSString *appKey;

/// 是否异步初始化，默认：NO
@property(nonatomic, assign) BOOL isAsyncInit;

/// 在三方 App 播放音频时，是否允许 SDK 内部对 AVAudioSession 的 category 进行设置，默认 NO，YES 音频分类会被设置为 AVAudioSessionCategoryAmbient
@property(nonatomic, assign) BOOL audioSessionSettingEnable;

/// 是否禁止汇川广告获取位置信息，默认：NO
@property(nonatomic, assign) BOOL forbidHcGetLocationInfo;

/// 图片是否使用 webp 格式，模版广告图片加载依赖 SDWebImage，开启该功能时确保 SDWebImage 是否支持 webp ，否则会导致模版广告图片加载失败
@property(nonatomic, assign) BOOL webpEnable;

@end

NS_ASSUME_NONNULL_END

