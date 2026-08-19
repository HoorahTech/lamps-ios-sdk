//
//  NANativeViewProtocol.h
//  NoahSDK
//
//  Created by zzyong on 2021/12/30.
//  Copyright © 2021 Alibaba Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NoahSDK/NANativeTemplateType.h>

NS_ASSUME_NONNULL_BEGIN

// 通过 viewWithTag: 获取对应子 View
typedef NS_ENUM(NSInteger, NANativeSubViewTag) {
    NANativeSubViewCover         = 1001, ///< 封面（单图、多图、视频）
    NANativeSubViewClose         = 1002, ///< 关闭按钮
    NANativeSubViewSource        = 1003, ///< 广告来源
    NANativeSubViewIcon          = 1004, ///< 图标，banner 广告无图标
    NANativeSubViewTitle         = 1005, ///< 标题
    NANativeSubViewDecription    = 1006, ///< 描述
    NANativeSubViewOpen          = 1007, ///< 跳转按钮
    NANativeSubViewSubDecription = 1008, ///< 子描述
};

/// UI 主题模式
typedef NS_ENUM(NSInteger, NAThemeMode) {
    NAThemeLight = 0, ///< 浅色
    NAThemeDark  = 1, ///< 深色
};

@protocol NANativeViewProtocol <NSObject>

/// 模版类型
@property (nonatomic, assign, readonly) NANativeTemplateType templateType;

/// 点击类型： 1 = 素材区， 2 = Title， 3 = Dest， 4 = CTA， 5 = ICON， 6 = AD卡片
@property (nonatomic, assign, readonly) NSInteger clickArea;

/// UI 主题模式
@property (nonatomic, assign) NAThemeMode themeMode;

/// 广告Id
@property (nonatomic, strong, readonly) NSString *adId;

/// 广告会话Id
@property (nonatomic, strong, readonly) NSString *sessionId;

/// 是否来自缓存
@property (nonatomic, assign, readonly) BOOL isFromCache;

/// 广告切换周期 书旗使用
@property (nonatomic, assign) float duration;

@end

NS_ASSUME_NONNULL_END
