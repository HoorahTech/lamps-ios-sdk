//
//  NASDKNativeTemplateDefines.h
//  NoahSDK
//
//  Created by zzyong on 2022/1/10.
//  Copyright © 2022 Alibaba Inc. All rights reserved.
//

UIKIT_EXTERN NSString * const NA_Native_Render_Type;
UIKIT_EXTERN NSString * const NA_Native_Ad_Show_Template;
UIKIT_EXTERN NSString * const NA_Native_Template_Apply_Style_Ids;
UIKIT_EXTERN NSString * const NA_Native_Template_Id;
UIKIT_EXTERN NSString * const NA_Native_Template_Content;

/// 模版渲染类型
typedef NS_ENUM(NSInteger, NANativeRenderType) {
    NANativeRenderApp = 0, ///< 接入方 App 渲染
    NANativeRenderSDK = 1, ///< NoahSDK 模版渲染
};

