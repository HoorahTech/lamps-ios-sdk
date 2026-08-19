//
//  AdError.h
//  NoahSDK
//
//  Created by zhongyang on 2020/10/27.
//  Copyright © 2020 zhongyang.ywx. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define NA_SDK_INIT_ERROR @"init error"

extern int const ERROR_CODE_SDK_NOT_INIT;
extern int const ERROR_CODE_AD_IS_SUCCESS;
extern int const ERROR_CODE_NETWORK_ERROR;
extern int const ERROR_CODE_NO_FILL;
extern int const ERROR_CODE_INTERNAL_ERROR;
extern int const ERROR_CODE_SERVER_ERROR;
extern int const ERROR_CODE_REMOTE_CLOSED;
extern int const ERROR_CODE_AD_LOADING;
extern int const ERROR_CODE_NOT_INIT;
extern int const ERROR_CODE_NOT_SUPPORT_7X;
extern int const ERROR_CODE_UNKNOWN;
extern int const ERROR_CODE_IMG_DOWNLOAD_ERROR;
extern int const ERROR_CODE_VAST_PARSE_ERROR;
extern int const ERROR_CODE_SESSION_LOADING;
extern int const ERROR_CODE_LOAD_NUM;
extern int const ERROR_CODE_EXPIRED;
extern int const ERROR_CODE_CONFIG_ERROR;
extern int const ERROR_CODE_BIDDING_ERROR;
extern int const ERROR_CODE_REQUEST_FREQUENT;
extern int const ERROR_CODE_CACHE_POOL_FULL;
extern int const ERROR_CODE_CREATE_ADN_FAIL;
extern int const ERROR_CODE_VERIFY_ERROR;
extern int const ERROR_CODE_FREQUENT;
extern int const ERROR_CODE_TEMPLATE_NO_MATCH;
extern int const ERROR_CODE_AD_FORBIDDEN;
extern int const ERROR_CODE_NO_AD;
extern int const ERROR_CODE_BELOW_FLOOR_PRICE;
extern int const ERROR_CODE_AD_LOW_VALUE;
extern int const ERROR_CODE_AD_REQUEST_LEVEL;

/**
* SDK内部过程错误
*/
extern int const ERROR_SUB_CODE_UNKNOWN                   ;
extern int const ERROR_SUB_CODE_DOWNGRADE_FAIL            ;
extern int const ERROR_SUB_CODE_NO_INIT                   ;
extern int const ERROR_SUB_CODE_NO_NETWORK                ;
extern int const ERROR_SUB_CODE_REPEAT_REQUEST            ;
extern int const ERROR_SUB_CODE_EMPTY_MEDIATION           ;
extern int const ERROR_SUB_CODE_EMPTY_SLOT                ;
extern int const ERROR_SUB_CODE_IMAGE_ERROR               ;
extern int const ERROR_SUB_CODE_TIMEOUT                   ;
extern int const ERROR_SUB_CODE_AD_IS_NULL                ;
extern int const ERROR_SUB_CODE_ADAPTER_IS_NULL           ;
extern int const ERROR_SUB_CODE_ASSERT_IS_NULL            ;
extern int const ERROR_SUB_CODE_SESSION_IS_NULL           ;
extern int const ERROR_SUB_CODE_AD_CLOSED                 ;
extern int const ERROR_SUB_CODE_AD_TYPE_UNKNOWN           ;
extern int const ERROR_SUB_CODE_FETCH_AD_MEDIATION_EMPTY  ;
extern int const ERROR_SUB_CODE_FETCH_AD_AD_TYPE_INVALIDE ;
extern int const ERROR_SUB_CODE_FETCH_AD_AD_TYPE_NOT_MATCH;
extern int const ERROR_SUB_CODE_FETCH_AD_NODE_EMPTY       ;
extern int const ERROR_SUB_CODE_FETCH_AD_NO_NEXT_AD_NODE  ;
extern int const ERROR_SUB_CODE_BIDDING_NODE_TIMEOUT      ;
extern int const ERROR_SUB_CODE_FREQUENCY_SHOW_COUNT;
extern int const ERROR_SUB_CODE_FREQUENCY_SEND_COUNT ;
extern int const ERROR_SUB_CODE_FREQUENCY_SHOW_INTERVAL ;
extern int const ERROR_SUB_CODE_FREQUENCY_REQ_FAIL;
extern int const ERROR_SUB_CODE_FREQUENCY_BLOCK_POLICY;
extern int const ERROR_SUB_CODE_REQUEST_LEVEL;

/**
* 填充广告失败原因
*/
extern int const ERROR_SUB_CODE_IS_NEW_USER               ;
extern int const ERROR_SUB_CODE_NO_COMMERCIAL             ;
extern int const ERROR_SUB_CODE_MEDIATION_IS_NULL         ;
extern int const ERROR_SUB_CODE_NO_NORMAL_CACHE           ;
extern int const ERROR_SUB_CODE_NORMAL_IMG_FAIL           ;
extern int const ERROR_SUB_CODE_GETAD_FROM_SERVER         ;
extern int const ERROR_SUB_CODE_SHOW_COUNT_LIMITED        ;
extern int const ERROR_SUB_CODE_SHOW_TIME_LIMITED         ;
extern int const ERROR_SUB_CODE_SCENE_LIMITED             ;
extern int const ERROR_SUB_CODE_HAS_OTHER_FILLED          ;


/**
* Mediation错误
*/
extern int const ERROR_SUB_CODE_MEDIATION_RESPONE_NULL    ;
extern int const ERROR_SUB_CODE_MEDIATION_JSON_PARSE_FAIL ;
extern int const ERROR_SUB_CODE_MEDIATION_JSON_NULL       ;
extern int const ERROR_SUB_CODE_MEDIATION_EMPTY_PLACEMENT ;
extern int const ERROR_SUB_CODE_MEDIATION_NETWORK_ERROR   ;
extern int const ERROR_SUB_CODE_MEDIATION_EMPTY           ;
extern int const ERROR_SUB_CODE_MEDIATION_UNION_EMPTY     ;
extern int const ERROR_SUB_CODE_MEDIATION_GLOBAL_EMPTY    ;
extern int const ERROR_SUB_CODE_MEDIATION_DATA_EMPTY      ;


/**
* Vast解析错误
*/
extern int const ERROR_SUB_CODE_DELIVERY_PARAM_INVALIDATE                        ;
extern int const ERROR_SUB_CODE_WRAPPER_REDIRECT_URL_INVALIDATE                  ;
extern int const ERROR_SUB_CODE_WRAPPER_REDIRECT_OVER_LIMIT                      ;
extern int const ERROR_SUB_CODE_WRAPPER_NO_MATCH_MEDIA_OTHRER                    ;
extern int const ERROR_SUB_CODE_WRAPPER_NO_MATCH_MEDIA_NODE_EMPTY                ;
extern int const ERROR_SUB_CODE_WRAPPER_NO_MATCH_MEDIA_MIMETYPE_NOSUPPORT        ;
extern int const ERROR_SUB_CODE_WRAPPER_NO_MATCH_MEDIA_URL_EMPTY                 ;
extern int const ERROR_SUB_CODE_WRAPPER_NO_MATCH_MEDIA_WIDTH_HEIGHT_GAP_NOTMATCH ;
extern int const ERROR_SUB_CODE_WRAPPER_NO_MATCH_MEDIA_BITRATE_NOMATCH           ;
extern int const ERROR_SUB_CODE_WRAPPER_RESPONSE_PROCESS_ERROR                   ;
extern int const ERROR_SUB_CODE_WRAPPER_REQUEST_FAILED                           ;
extern int const ERROR_SUB_CODE_WRAPPER_NOT_WRAPPER_NODE                         ;
extern int const ERROR_SUB_CODE_WRAPPER_NOT_AD_NODE                              ;
extern int const ERROR_SUB_CODE_VAST_XML_PARAM_EXCEPTION                         ;
extern int const ERROR_SUB_CODE_VAST_PARAM_UNKNOWN                               ;


extern NSString * const STATE_RESULT_NULL;
extern NSString * const STATE_TIME_FAIL;
extern NSString * const STATE_IMG_FAIL;
extern NSString * const STATE_IMG_MISS;
extern NSString * const STATE_CACHE_NULL;

#define AD_ERROR(errorCode, errorMsg) [[AdError alloc] initErrorCode:errorCode msg:errorMsg]
#define ERROR_BELOW_FLOOR_PRICE [[AdError alloc] initErrorCode:ERROR_CODE_BELOW_FLOOR_PRICE msg:@"below floor price"]

@interface AdError : NSObject

-(instancetype)init;
-(instancetype)initErrorCode:(int)errorCode;
-(instancetype)initErrorCode:(int)errorCode msg:(NSString *)msg;
-(instancetype)initErrorCode:(int)errorCode errorSubCode:(int)errorSubCode;
-(instancetype)initErrorCode:(int)errorCode errorSubCode:(int)errorSubCode msg:(NSString *)msg;
-(AdError *)appendMessage:(NSString *)s;
-(void)setErrorSubCode:(int)subCode;
-(int)getErrorCode;
-(int)getErrorSubCode;
-(NSString *)getErrorMessage;
-(NSString *)toString;

+(AdError *)NETWORK_ERROR;
+(AdError *)NO_FILL;
+(AdError *)VEARIFY_ERROR;
+(AdError *)INTERNAL_ERROR;
+(AdError *)NUM_LIMIT;
+(AdError *)TASK_REPEAT;
+(AdError *)REMOTE_CLOSED;
+(AdError *)SERVER_ERROR;
+(AdError *)UN_INIT;
+(AdError *)UNKNOWN;
+(AdError *)NOT_SUPPORT_7X;
+(AdError *)IMAGE_CHECK_ERROR;
+(AdError *)SUCCESS;
+(AdError *)FILTER_ERROR;
+(AdError *)CACHE_ERROR;
+(AdError *)EXPIRED;
+(AdError *)CONFIG_ERROR;
+(AdError *)TIMEOUT;
+(AdError *)SDK_NOT_INIT;
+(AdError *)ADN_FREQUENT_SHOW_COUNT;
+(AdError *)ADN_FREQUENT_SEND_COUNT;
+(AdError *)ADN_FREQUENT_SHOW_INTERVAL;
+(AdError *)ADN_FREQUENT_REQ_FAIL;
+(AdError *)BIDDING_ERROR;
+(AdError *)FREQUENT_ERROR;
+(AdError *)CACHE_POOL_FULL;
+(AdError *)BIDDING_NODE_TIMEOUT;
+(AdError *)CREATE_ADN_FAIL;
+(AdError *)TEMPLATE_NO_MATCH;
+(AdError *)AD_FORBIDDEN;
+(AdError *)NO_AD;
+(AdError *)REQUEST_LEVEL_ERROR;

@end

NS_ASSUME_NONNULL_END
