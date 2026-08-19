//
//  SQRHuiChuanHeaderModel.h
//  shuqireader
//
//  Created by ZhouPanpan on 2020/3/13.
//  Copyright © 2020 AliWenXue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQRHCAdFetcherEncoder.h"

#define kSQRHuiChuanSecretKeyLength 16

NS_ASSUME_NONNULL_BEGIN

@class SQRHuiChuanHeaderDeviceModel,SQRHuiChuanHeaderAPPInfoModel,SQRHuiChuanHeaderGPSInfoModel;
@class SQRHuiChuanHeaderPageInfoModel,SQRHuiChuanHeaderResInfoModel,SQRHuiChuanHeaderAdPosInfoModel,SQRHuiChuanHeaderScreenInfoModel,SQRHuiChuanHeaderExpInfoModel;
@protocol SQRHuiChuanAdFetcherDataSource;

/// 汇川 api 请求头封装 Model
@interface SQRHuiChuanHeaderModel : NSObject
// 调整UC里面以前注册appname的缺陷，只在UC里面设置即可
@property (nonatomic,copy,nullable)NSString *app_name;

@property (nonatomic,strong)SQRHuiChuanHeaderDeviceModel *ad_device_info;
@property (nonatomic,strong)SQRHuiChuanHeaderAPPInfoModel *ad_app_info;
@property (nonatomic,strong)SQRHuiChuanHeaderGPSInfoModel *ad_gps_info;
@property (nonatomic,strong)NSArray<SQRHuiChuanHeaderAdPosInfoModel *> *ad_pos_info;
@property (nonatomic,strong)SQRHuiChuanHeaderPageInfoModel *page_info;
@property (nonatomic,strong)SQRHuiChuanHeaderResInfoModel *res_info;
@property (nonatomic,strong)SQRHuiChuanHeaderScreenInfoModel * open_screen_request;
/// key: value
@property (nonatomic,strong)NSMutableArray *ext_info;
// 通过外部协议 【SQRHuiChuanAdFetcherDataSource 的 useWSG属性设置】
// 和  外部传入的 【SQRHCAdFetcherEncoder 类型的 encoder 对象】
// 判断是否要 用外部的加密方式，比如无线保镖加密
@property (nonatomic,assign)BOOL useWSG;
// 外部传入的头部加密方式，优先级低于 useWSG
@property (nonatomic,assign)int encodeStyle;
// 可不传。 超级汇川媒体中台协议版本>=2  目前固定传2
@property (nonatomic,strong)NSString *protocol_version;

@property (nonatomic,strong)NSString *noah_appName;
@property (nonatomic,strong)NSString *noah_slotKey;
@property (nonatomic,strong) NSArray<SQRHuiChuanHeaderExpInfoModel *> *exp_tags;

@property (nonatomic,strong,nullable)NSString *xijingAppName;

/// 请求头封装，如果 useWSG 为 YES 并且通过 register 注册了加密器，则使用无线保镖加密
- (nullable NSData *)httpBodyDataUseWSGIfNeeded;
/// 扩展的 http fields
+ (NSDictionary *)defaultHeaderFields;
/// 注册业务提供的加密方法，比如无线保镖加密器
+ (void)registerWSGEncoder:(id<SQRHCAdFetcherEncoder>)encoder;
+ (id<SQRHCAdFetcherEncoder>)encoder;

@end

/// 广告位信息数组（目前只支持一个，多个会有问题）
@interface SQRHuiChuanHeaderAdPosInfoModel : NSObject
/// 默认0，广告位类型 0 common id相关，必须有id 1 query 可以没有id，必须有query字段 对于common请求我们会根据用户的兴趣，行为和页面信息，定向投放广告
@property (nonatomic, copy) NSString *slot_type;
/// 广告位id
@property (nonatomic, copy) NSString *slot_id;
/// 支持的广告样式集合数组，默认使用广告平台当前设置的样式集合代替
@property (nonatomic, retain) NSArray *ad_style;
/// 数量，数量不做限制
@property (nonatomic, copy) NSString *req_cnt;
/// 自媒体ID
@property (nonatomic, copy) NSString *wid;
/// 广告位宽度（单位：像素
@property (nonatomic, copy) NSString *aw;
/// 广告位高度（单位：像素）
@property (nonatomic, copy) NSString *ah;
@property (nonatomic, copy) NSString *query;
/// 激励视频传1
@property (nonatomic, copy) NSString *ad_resource_id;

/// 废弃，不再使用
+ (NSArray *)flowADTypes;
/// 废弃，不再使用
+ (NSArray *)rewardADTypes;
@end

/// 开屏请求
@interface SQRHuiChuanHeaderScreenInfoModel : NSObject
/// 开屏类型
@property (nonatomic ,copy) NSString * type;
/// 本地广告 key ，未来会用
@property (nonatomic ,copy) NSArray <NSString *> * local_ad_keys;

@end

/// 页面信息
@interface SQRHuiChuanHeaderPageInfoModel : NSObject
/// 页面URL
@property (nonatomic, copy) NSString *page_url;
/// 页面标题
@property (nonatomic, copy) NSString *page_title;
/// 页面refer信息
@property (nonatomic, copy) NSString *page_refer;
/// 页面meta关键字
@property (nonatomic, copy) NSString *meta_kw;
@end

/// 页面资源信息
@interface SQRHuiChuanHeaderResInfoModel : NSObject
/// 资源来源 URL
@property (nonatomic, copy) NSString *src_url;
/// 资源URL
@property (nonatomic, copy) NSString *res_url;
/// 资源标题
@property (nonatomic, copy) NSString *res_title;
@end
/// 设备信息
@interface SQRHuiChuanHeaderDeviceModel : NSObject
///  设备ID，Android取imei，IOS按客户端现有逻辑获取（淘内推荐填写）
@property (nonatomic,copy)NSString *devid;
/// imei
@property (nonatomic, copy) NSString *imei;
/// 备选设备ID，IOS 有效 Ios版本<=6.0有效 ,用于ios设备的用户识别和兴趣投放（淘内推荐填写）
@property (nonatomic, copy) NSString *udid;
/// 备选设备ID，仅IOS 6+有效 ,用于ios设备的用户识别和兴趣投放
@property (nonatomic, copy) NSString *idfa;
/// 设备型号（需要归一化所有的设备型号）
@property (nonatomic, copy) NSString *device;
/// 操作系统，枚举选项， android/ios/wp（默认ios） 用于操作系统定向投放
@property (nonatomic, copy) NSString *os;
/// 操作系统版本（需要归一化所有的设备型号）
@property (nonatomic, copy) NSString *osv;
/// cpu型号
@property (nonatomic, copy) NSString *cpu;
/// mac 地址（小写归一化）
@property (nonatomic, copy) NSString *mac;
/// 屏幕宽度（物理分辨率）
@property (nonatomic, copy) NSString *sw;
/// 屏幕高度（物理分辨率）
@property (nonatomic, copy) NSString *sh;
/// 系统是否越狱 0 未确定 1 越狱 2 未越狱
@property (nonatomic, copy) NSString *is_jb;
///  网络类型 枚举值 Wi-Fi/2G/3G/4G/Unknown
@property (nonatomic, copy) NSString *access;
/// < 运营商 枚举值 Unknown/ChinaMobile/ChinaUnicom/ChinaTelecom/ChinaTietong
@property (nonatomic, copy) NSString *carrier;
/// cp信息，格式如：isp:电信;prov:广东;city:广州;na:中国;cc:CN;ac:(淘内)
@property (nonatomic, copy) NSString *cp;
/// 服务端转发必须填充该字段，客户端直连不需要填充，用于用户地域识别，广告地域投放和反作弊
@property (nonatomic, copy) NSString *client_ip;
/// 手机品牌
@property (nonatomic, copy) NSString *brand;
/// 新广告标识符协议
@property (nonatomic, copy) NSString *aaid;
@property (nonatomic, copy) NSString *cValue;

@property (nonatomic, copy) NSString *dit; //设备初始化时间
@property (nonatomic, copy) NSString *sut; //系统更新时间
@property (nonatomic, copy) NSString *sst; //系统启动时间
@property (nonatomic, copy) NSString *wx_sdk_version; //OpenSDK版本号
@property (nonatomic, copy) NSString *wx_version; //微信版本号

@end

/// APP 信息
@interface SQRHuiChuanHeaderAPPInfoModel : NSObject
/// 平台分类 枚举值 android/iphone/other
@property (nonatomic, copy) NSString *fr;
/// 安装序列号（外部）淘内
@property (nonatomic, copy) NSString *dn;
/// 安装序列号（内部）淘内
@property (nonatomic, copy) NSString *sn;
/// 阿里UTDID，淘内强烈建议填充
@property (nonatomic, copy) NSString *utdid;
/// 是否要返回https的内容 为1则支持https，为0则不支持https
@property (nonatomic, copy) NSString *is_ssl;
/// 取bundle id（小写归一化）（对于ios直接取appstore上的包名）
@property (nonatomic, copy) NSString *pkg_name;
/// 版本号
@property (nonatomic, copy) NSString *pkg_ver;
/// 应用名称（小写归一化）（对于ios直接取appstore上的app名称）
@property (nonatomic, copy) NSString *app_name;
///  User Agent，无法填充可以填空串
@property (nonatomic, copy) NSString *ua;
/// App发行国家
@property (nonatomic, copy) NSString *app_country;
/// App发行语言
@property (nonatomic, copy) NSString *lang;
/// App发行时区
@property (nonatomic, copy) NSString *timezone;
/// 是否支持指定落地页
@property (nonatomic, copy) NSString *support_wx_turl;
@end

/// GPS 信息
@interface SQRHuiChuanHeaderGPSInfoModel : NSObject
/// gps 信息的获取时间,时间戳,精确到秒
@property (nonatomic, copy) NSString *gps_time;
/// 经度
@property (nonatomic, copy) NSString *lng;
/// 纬度
@property (nonatomic, copy) NSString *lat;
/// 高德地理位置信息码 淘内推荐
@property (nonatomic, copy) NSString *amap_code;
@end

@interface SQRHuiChuanHeaderExpInfoModel : NSObject
//实验id
@property (nonatomic, assign) int exp_id;
//分桶id
@property (nonatomic, assign) int flow_id;
@end

NS_ASSUME_NONNULL_END
