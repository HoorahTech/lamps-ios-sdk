//
//  SQRHuiChuanResponseModel.h
//  shuqireader
//
//  Created by ZhouPanpan on 2020/3/13.
//  Copyright © 2020 AliWenXue. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 参考：
 https://yuque.antfin-inc.com/docs/share/e2669697-c15a-4e3e-97bd-d5e8636d50db#
 */

// can_shake字段类型定义
#define kHCInteractionDefault            @"0"       // 默认无交互控制
#define kHCInteractionShake              @"1"       // 摇一摇
#define kHCInteractionSlideVertical      @"2"       // 垂直上滑解锁
#define kHCInteractionSlideHorizontal    @"3"       // 水平左右滑动解锁
#define kHCInteractionSlideLp            @"4"       // 上滑落地页
#define kHCInteractionTwoBtn             @"5"       // 开屏多按钮,双按键
#define kHCInteractionThreeBtn           @"6"       // 开屏多按钮,三按键
#define kHCInteractionSlideVerticalBtn   @"7"       // 开屏上滑解锁+按钮
#define kHCInteractionRotationTurn       @"8"       // 转一转 (绕Y轴旋转)
#define kHCInteractionRotationTwist      @"9"       // 转一转 (绕Z轴旋转)
#define kHCInteractionRotationFall       @"10"      // 倒一倒 (绕X轴旋转）
#define kHCInteractionMultiDirectSlide   @"11"      // 四面八方（含Banner可点）
#define kHCInteractionMultiSlideAndShake @"12"      // 四面八方 + 摇一摇 + 含Banner可点
#define kHCInteractionMultiSlideAndTurn  @"13"      // 四面八方 + 转一转 + 含Banner可点
#define kHCInteractionMove               @"14"      // 动一动 (摇一摇增强版，满足加速度或者角度即可)

typedef NS_ENUM(NSUInteger, HCAdClickAction)
{
    HCAdClickActionOpenApp = 0,    //点击调端
    HCAdClickActionOpenPage = 1,   //点击打开落地页
    HCAdClickActionDownload = 2,   //点击下载应用
    HCAdClickActionWebIPage = 6,   //点击跳转Web中间页
    HCAdClickActionUndefine = 404, //未定义
};

typedef NS_ENUM(NSUInteger, HCTopViewType) //topview类型
{
    HCTopViewTypeNone = 0,  //没有topview
    HCTopViewTypeOpen = 1,  //明投
    HCTopViewTypeQuiet = 2, //暗投
};

typedef NS_ENUM(NSUInteger, HCForbiddenType) {
    HCForbiddenTypeNone = 0, //没有禁止
    HCForbiddenTypeAll = 1,  //禁止所有
};

typedef NS_ENUM(NSUInteger, HCAdSourceType) {
    HCAdSourceTypeHuichuan = 1,
    HCAdSourceTypeTanx     = 2,
    HCAdSourceTypeAfp      = 3,
    HCAdSourceTypeAfpTail  = 4,
    HCAdSourceTypeTanxSSP  = 5,
    HCAdSourceTypeAdm      = 6,
    HCAdSourceTypeCtrip    = 7,
    HCAdSourceTypeQunar    = 8,
    HCAdSourceTypeNewBrand = 9,
    HCAdSourceTypeOther    = 100,
};

/// 汇川响应数据
@class SQRHuiChuanResponseSlotModel,SQRHuiChuanResponseAdModel,SQRHuiChuanResponseExtInfoModel, SQRHuiChuanResponseInfoModel;
@interface SQRHuiChuanResponseModel : NSObject

/// 广告物料
@property (nonatomic, strong, nullable) NSDictionary *adData;
/// 错误状态码 正常返回0
@property (nonatomic, assign) NSInteger code;
/// 请求ID，唯一标识一次广告请求,由广告展现引擎生成下发
@property (nonatomic, copy) NSString *sid;
/// 错误原因，正常无此字段或为空，错误发生时有次字段
@property (nonatomic, copy) NSString *reason;
/// 请求级的下发字段
@property (nonatomic, strong) SQRHuiChuanResponseInfoModel *info;
/// 所有广告位的返回广告列表
@property (nonatomic, retain) NSArray <SQRHuiChuanResponseSlotModel *>* slot_ad;
/// 解析并获取slot数据
- (SQRHuiChuanResponseSlotModel *)firstSlotModel;
/// 规则引擎选中的第一条物料（覆盖 firstAdmodel 返回值）
@property (nonatomic, strong, nullable) SQRHuiChuanResponseAdModel *multiFirstAd;
/// 规则引擎选中的第二条物料（覆盖 secondAdmodel 返回值）
@property (nonatomic, strong, nullable) SQRHuiChuanResponseAdModel *multiSecondAd;
/// 解析并获取广告数据
- (SQRHuiChuanResponseAdModel *)firstAdmodel;
/// 解析并获取第二条广告数据（双广告模式）
- (SQRHuiChuanResponseAdModel *)secondAdmodel;
/// 获取所有广告物料（已按价格降序排序）
- (NSArray<SQRHuiChuanResponseAdModel *> *)allAdModels;

@end
@class SQRHuiChuanResponseAdModel;

@interface SQRHuiChuanResponseExtInfoModel : NSObject
/// 1:表示禁止广告，其他值或不存在均表示可以展示广告
@property (nonatomic, assign) HCForbiddenType ad_forbidden;
@end

@interface SQRHuiChuanResponseSlotModel : NSObject
/// 该广告所属广告位
@property (nonatomic, copy) NSString *slot_id;
/// 某个广告位下的返回广告列表，若无广告返回，该字段为不存在或空数组
@property (nonatomic, retain) NSArray <SQRHuiChuanResponseAdModel*> *ad;
/// 扩展字段
@property (nonatomic, strong) SQRHuiChuanResponseExtInfoModel *ad_ext_info;
/// 对广告列表按 dsp_bid_price 价格从高到低排序
- (void)sortAdsByPrice;
@end

@class SQRHuiChuanResponseActionModel,SQRHuiChuanResponseADContentModel;
@interface SQRHuiChuanResponseAdModel : NSObject
/// 广告点击行为
@property (nonatomic, retain) SQRHuiChuanResponseActionModel *ad_action;
///  广告内容填充所需字段，该字段子字段的内容有具体样式决定，不同样式的子字段样式不同
@property (nonatomic, retain) SQRHuiChuanResponseADContentModel *ad_content;
/// 广告id
@property (nonatomic, copy)NSString *ad_id;
/// 广告样式 id
@property (nonatomic, copy) NSString *style;
/// 失败反馈url（参见反馈协议展现处理)
@property (nonatomic, copy) NSString *furl;
/// 端-端跳转反馈url
@property (nonatomic, copy) NSString *scheme_feedback_url;

/// 广告主目标url数组（参见反馈协议点击处理）
@property (nonatomic, retain) NSArray *turl;
// 自定义turl第一个复制元素
@property (nonatomic, copy) NSString *turl_0_copy;
///  第三方展现反馈url数组（参见反馈协议展现处理）
@property (nonatomic, retain) NSArray *vurl;
/// curl 复制元素
@property (nonatomic, retain) NSArray *curl_copy;
/// 第三方点击反馈url数组（参见反馈协议点击处理）
@property (nonatomic, retain) NSArray *curl;
/// 用于客户端反馈某些事件打点（如app开始下载，app下载完成，app开始安装等等），如客户端不需要，忽略这个字段。
@property (nonatomic, copy) NSString *eurl;
/// 视频播放事件打点 https://yuque.antfin-inc.com/docs/share/04c06f1c-10d8-4cf2-88d2-5f6b53c61bb6
@property (nonatomic, copy) NSString *video_play_url;
/// 汇川展示打点数组（topview开屏专用，用于开屏和信息流，详情参见反馈协议展现处理）
@property (nonatomic, copy) NSArray *hc_vurl;
/// 第三方展示打点数组（topview开屏专用，只需要在开屏位置曝光时提交打点，详情参见反馈协议展现处理）
@property (nonatomic, copy) NSArray *t_vurl;
///
//@property (nonatomic, copy) NSString *ad_is_effect;
/// 广告来源
@property (nonatomic, copy) NSString *ad_source_type;
/*
    表示预加广告的类型
    默认值0： 表示不支持预加载。
    1： 高优的预加载广告
    2： 兜底的预加载广告
*/
#define HC_PRELOAD_TYPE_BRAND            @"1"   // 品牌高优
#define HC_PRELOAD_TYPE_DEFAULT          @"2"   // 兜底
@property (nonatomic, copy) NSString *preload_type;
// 允许展现的起始时间 单位秒  预推、预加载广告必填。
@property (nonatomic, copy) NSString *start_timestamp;
// 允许展现的结束时间 单位秒 预推、预加载广告必填。
@property (nonatomic, copy) NSString *end_timestamp;
// ad 的惟一 key  预推的广告必填  请求预推实时接口时需要使用。
@property (nonatomic, copy) NSString *ad_key;

//此广告是否已经展现过，非解析数据，而是端上判断
@property (nonatomic, assign)BOOL showed;

//此广告点击动作，非解析数据，而是端上判断
@property (nonatomic, assign) HCAdClickAction adClickAction;

//竞胜上报url
@property (nonatomic, copy) NSString *wnurl;

/// 展示开始时间
@property (nonatomic, assign) NSTimeInterval showBegin;
@property (nonatomic, strong) NSString *noahSlot;
@property (nonatomic, strong) NSString *noahPid;

@property (nonatomic, assign) BOOL testFlag;

//aes加密后的二价字符串，客户端数据，不是服务端下发
@property (nonatomic, copy) NSString *secondHighestPriceAesStr;

//行业信息
@property (nonatomic, copy) NSString *ind1;
@property (nonatomic, copy) NSString *ind2;
@property (nonatomic, copy) NSString *ind3;

//转化类型
@property (nonatomic, copy) NSArray *convert_type;

//sessionId，客户端数据，非服务端下发
@property (nonatomic, copy) NSString *naSessionId;
//noah slot key，客户端数据，非服务端下发
@property (nonatomic, copy) NSString *naSlotKey;
//当次点击的CHS值，临时属性，用于在上报链接中替换 __CHS__ 宏
@property (nonatomic, copy) NSString *chsValue;

- (BOOL)showUrlHasSdkPrice;
- (BOOL)clickUrlHasSdkPrice;

@end

@interface SQRHuiChuanResponseActionModel : NSObject
/// 广告点击行为:tab：新窗口打开   download：下载
@property (nonatomic, copy) NSString *action;
@end

/// 广告内容
/// 填充所需字段，该字段子字段的内容有具体样式决定，不同样式的子字段样式不同
@class SQRHuiChuanResponseADVedioModel;
@interface SQRHuiChuanResponseADContentModel : NSObject
/// Scheme 端-端跳转 url
@property (nonatomic, copy) NSString *scheme;
/// Scheme 端-端跳转 url(新地址，仅针对汇川DSP，https://aliyuque.antfin.com/zfksti/aswury/un2ec6app7c4ug9i)
@property (nonatomic, copy) NSString *scheme_url_ad;
/// Scheme 端-端跳转 universal link 方式
@property (nonatomic, copy) NSString *adm_fixed_ulk;

@property (nonatomic, copy) NSString *op_mark;

/// 展示结束上报url
@property (nonatomic, strong) NSString *end_vurl;

/// 精准横版视频
/// uc内渠浏览器播放地址加密的
@property (nonatomic,copy)NSString *ad_1_video;
/// 外部媒体请求视频播放地址未加密   LD为高清  FD为标情 JSON 串
@property (nonatomic,copy)NSString *ad_1_video_aliyun;
@property (nonatomic,copy,nullable)SQRHuiChuanResponseADVedioModel *video_aliyun;
/// 视频播放地址，没的到说明
@property (nonatomic,copy)NSString *ad_1_video_mc;
/// 播放时长 单位 秒
@property (nonatomic,copy)NSString *ad_1_video_duration;
/// 视频大小 单位 字节
@property (nonatomic,copy)NSString *ad_1_video_size;
/// 视频封面图地址
@property (nonatomic,copy)NSString *img_1;
/// 图片宽
@property (nonatomic,copy)NSString *img_1_h;
/// 图片高
@property (nonatomic,copy)NSString *img_1_w;
/// 图片类型  jpg, png
//@property (nonatomic,copy)NSString *img_1_t;
/// 来源
@property (nonatomic,copy)NSString *source;
/// 样式id
@property (nonatomic,copy)NSString *style;
/// 标题
@property (nonatomic,copy)NSString *title;
/// cta
@property (nonatomic,copy)NSString *button_words;

/// 描述
@property (nonatomic,copy)NSString *ad_description;
/// app名称
@property (nonatomic,copy)NSString *app_name;
/// 其它追加
@property (nonatomic,copy)NSString *img_2;
@property (nonatomic,copy)NSString *img_3;
///
@property (nonatomic,copy)NSString *app_key;
///
@property (nonatomic,copy)NSString *app_source;
///
@property (nonatomic,copy)NSString *app_type;
///
@property (nonatomic,copy)NSString *category_id;
/// @property (nonatomic,copy)NSString *category_name;
///
@property (nonatomic,copy)NSString *channel_id;
/// 创建时间
@property (nonatomic,copy)NSString *create_time;
/// 下载类型：apk，png等
@property (nonatomic,copy)NSString *download_type;
/// app logo图片
@property (nonatomic,copy)NSString *logo_url;
@property (nonatomic,copy)NSString *pp_ios_detail_url;
@property (nonatomic,copy)NSString *package_key;
@property (nonatomic,copy)NSString *package_name;
/// 发布时间
@property (nonatomic,copy)NSString *publish_time;
@property (nonatomic,copy)NSString *rating;
@property (nonatomic,copy)NSString *rating_count;
@property (nonatomic,copy)NSString *search_id;
@property (nonatomic,copy)NSString *tag_id;
@property (nonatomic,copy)NSString *tag_name;
@property (nonatomic,copy)NSString *origin_url;
@property (nonatomic,copy)NSString *site_id;
@property (nonatomic,copy)NSString *site_type;
@property (nonatomic,copy)NSString *site_url;
@property (nonatomic,copy)NSString *ad_new_origin_target_url;//new_origin_target_url
/// 展示时长
@property (nonatomic,copy)NSString *show_time;
/// 跳过文案
@property (nonatomic,copy)NSString *close_text;
/// 用于竞价的价格 单位：分
@property (nonatomic,copy)NSString *dsp_bid_price;
/// 服务端上的扣费价格
@property (nonatomic,copy)NSString *hc_charge;
///动态底价
@property (nonatomic,copy)NSString *adn_bid_floor;
///  汇川广告指定下发的优先级
@property (nonatomic,copy)NSString *dsp_priority;

//直播组件
//是否支持直播组件   1：支持    0：不支持，默认值
@property (nonatomic,copy)NSString *support_live;
//描述
@property (nonatomic,copy)NSString *live_room_desc;
//按钮文字
@property (nonatomic,copy)NSString *follow_btn_name;
//按钮副标题
@property (nonatomic,copy)NSString *follow_btn_desc;
//主播ID
@property (nonatomic,copy)NSString *anchor_id;
//直播视频地址
@property (nonatomic,copy)NSString *video_url;
//直播头像
@property (nonatomic,copy)NSString *v_logo_url;
//直播店铺名称
@property (nonatomic,copy)NSString *live_account_name;
//直播来源
@property (nonatomic,copy)NSString *live_source;
//观看数
@property (nonatomic,assign)NSInteger live_online_num;
//粉丝数
@property (nonatomic,assign)NSInteger live_fans_count;
//互动模块小图
@property (nonatomic,copy)NSString *live_poster_img;

#pragma mark - 联投样式
//标识是否为topview; 1: 表示 top view 0:表示非 top view
@property (nonatomic,copy)NSString *topview;
//横图,仅在联投横版大图样式下有
@property (nonatomic,copy)NSString *horizontal_img;
//播放时长 单位 秒
@property (nonatomic,copy)NSString *horizontal_video_duration;
//json 格式的字符串外部媒体请求高清视频播放地址未加密。json 格式的字符串，需要解析一下,LD为高清,FD为标情
@property (nonatomic,copy)NSString *horizontal_video_aliyun;
@property (nonatomic,copy,nullable)SQRHuiChuanResponseADVedioModel *horizontalVideoModel;
//视频大小
@property (nonatomic,copy)NSString *horizontal_video_size;
//是否暗投的topview，当此参数存在，并且=12时，则为暗投topview
@property (nonatomic,copy)NSString *strategy_type;

#pragma mark -
// 工信部点击区域整改字段
// 0：局部可点击  1:  全区域可点击   未填充表示 0
@property (nonatomic,copy)NSString *click_zone;
// 未填充，客户端使用默认值 "点击跳转详情页或第三方应用"
@property (nonatomic,copy)NSString *btn_attached_label;

// 视频样式底图
@property (nonatomic,copy)NSString *bimg_1;

//  =1 摇一摇样式，=2 上滑，=3 左右滑；  其他情况 正常出其他的广告, 详细见头部kHCInteraction相关定义
@property (nonatomic,copy)NSString *can_shake;

/// 开屏广告摇一摇灵敏度等级
@property (nonatomic, copy) NSString *splash_screen_sensitivity;

@property (nonatomic,copy)NSString *btn_label_1;
@property (nonatomic,copy)NSString *btn_label_2;
@property (nonatomic,copy)NSString *btn_label_3;

@property (nonatomic,copy)NSString *target_url_2;
@property (nonatomic,copy)NSString *target_url_3;

// 字符串数组，用起来需要转换下 用下面的 curl_1_array curl_2_array curl_3_array
@property (nonatomic,copy)NSString *curl_1;
@property (nonatomic,copy)NSString *curl_2;
@property (nonatomic,copy)NSString *curl_3;

/// 浮动图片地址，也用于红包雨图片地址
@property (nonatomic,copy)NSString *float_img;

/// 小程序兜底链接
//微信小程序app_id，使用时需判断字段非空
@property (nonatomic,copy)NSString *mini_app_id;
//微信小程序path
@property (nonatomic,copy)NSString *mini_app_path;
//微信指定落地页
@property (nonatomic,copy)NSString *wechat_ext_info;
/// 广告主替换 1:PM基础提价 2:bid提价 3:核心人群提价 4:Q+1提价
@property (nonatomic,assign) NSInteger hc_raise_up_type;
// 激励类型
@property (nonatomic,copy)NSString *incentive_type;
// 激励模版id
@property (nonatomic,copy)NSString *incentive_template_id;
// 激励任务类型（原生用）
@property (nonatomic,copy)NSString *incentive_task_type;
// 激励数据
@property (nonatomic,copy)NSString *incentive;
// 行业信息
@property (nonatomic,copy)NSString *industry1_description;
@property (nonatomic,copy)NSString *industry2_description;
@property (nonatomic,copy)NSString *industry1;
@property (nonatomic,copy)NSString *industry2;
//汇川广告账户
@property (nonatomic,copy)NSString *account_id;

///  汇川广告win_dsp_id
@property (nonatomic,copy)NSString *ad_dsp_id;

@property (nonatomic,copy)NSString *other_source_ad_id;

@property (nonatomic,copy)NSString *voucher_price;//红包金额
@property (nonatomic,copy)NSString *voucher_tips;//风险提示语
@property (nonatomic,copy)NSString *voucher_is_fix;//红包金额是否固定
@property (nonatomic,copy)NSString *voucher_is_all;//是否全平台通用
@property (nonatomic,copy)NSString *voucher_is_threshold;//是否有消费门槛

@property (nonatomic, copy) NSString *budget_type;
/// 弹窗样式类型: 0=红包/优惠券弹窗, 1=通用弹窗（物料下发，用于区分弹窗展示样式）
@property (nonatomic, copy) NSString *popup_style_type;

@property (nonatomic,copy)NSString *reward_convert_type;//汇川基础任务类型
@property (nonatomic,copy)NSString *reward_task_text;//汇川基础任务文案
@property (nonatomic,copy)NSString *reward_pause_time;//汇川任务时间
@property (nonatomic,copy)NSString *reward_deep_convert_type;//汇川进阶任务类型
@property (nonatomic,copy)NSString *reward_deep_task_text;//汇川进阶任务文案
@property (nonatomic,copy)NSString *reward_button_text;//操作按钮文案
@property (nonatomic,copy)NSString *return_prompt_text;//挽留弹窗文案
@property (nonatomic,copy)NSString *reward_moment_type;//控制浏览时长是否根据汇川逻辑统计
@property (nonatomic,copy)NSString *is_forced;//调起模版强弱模式是否使用汇川控制值

@property (nonatomic,copy)NSString *incentive_task_convert_type;//转化任务类型
@property (nonatomic,copy)NSString *incentive_task_sug_time;//建议跳转停留时长

@property (nonatomic,copy)NSString *sdk_cache_strategy;//缓存策略，"0":不走缓存，"1":走缓存，不下发(SDK内部初始化为-1):走客户端原有逻辑

#pragma mark - 多任务（双广告）字段
/// 多任务模式类型：1=开启2个任务且均需完成，0和其他=不开启
@property (nonatomic, copy) NSString *multi_task_type;
/// 多任务展示文案（支持 '' 加重和 {time} 占位符）
@property (nonatomic, copy) NSString *multi_reward_task_text;
/// 多任务按钮文案
@property (nonatomic, copy) NSString *multi_reward_button_text;
/// 多任务奖励发放时机类型：1=不要求连续可累计，2=要求连续
@property (nonatomic, copy) NSString *multi_reward_moment_type;
/// 多任务停留时长要求（秒）
@property (nonatomic, copy) NSString *multi_reward_pause_time;

#pragma mark - 游戏试玩（H5 激励视频）字段
/// 小游戏 H5 页面 URL（有值且 incentive_template_id=10002 时走 templateId=1005）
@property (nonatomic, copy) NSString *game_play_url;
/// 浏览时长（秒）——type=3 主计时、type=4 弱模式点击后计时
@property (nonatomic, copy) NSString *watch_time;
/// 初始页面/Banner 提示文案（支持 '' 加重与 {time} 占位符）
@property (nonatomic, copy) NSString *watch_text;
/// 跳转返回后提示文案（支持 '' 加重与 {time} 占位符）
@property (nonatomic, copy) NSString *return_text;
/// type=4 下发引导弹板的触发时机（秒）
@property (nonatomic, copy) NSString *trigger_time;
/// 倒计时启动方式：1=点击开始，0=自动开始
@property (nonatomic, copy) NSString *is_click_begin;
/// 是否展示倒计时提示：1=展示，0=隐藏
@property (nonatomic, copy) NSString *is_show_tips;
/// 是否展示挽留弹窗：1=展示，0=跳过
@property (nonatomic, copy) NSString *is_show_return;
/// 是否展示发奖弹窗：1=弹窗，0=仅文案
@property (nonatomic, copy) NSString *is_show_award;

// 订单营销类型, https://aliyuque.antfin.com/imp-brand/requirement/kloz1i25fizlkbmo?singleDoc#
#define HC_MARKET_RESOURCE_IN            @"1"   // 资源换入
#define HC_MARKET_INTERNAL_PROMOTION     @"3"   // 内部推广
#define HC_MARKET_DAYU_PROMOTION         @"7"   // 大鱼推广
#define HC_MARKET_EVENT_PROMOTION        @"8"   // 事件推广
@property (nonatomic, copy) NSString *deal_marketing_type;
// 客户ID
@property (nonatomic, copy) NSString *cid;

/// 汇川竞价保护比率
@property (nonatomic, copy) NSString *hc_bid_ratio;

-(BOOL)isVideoStyle;
-(NSString *)bgImageSplash;
-(NSString *)bgImageSplashWithSize:(CGSize)size;

// UC打点使用
-(NSString *)getSubtype;
//是否是topView广告
- (BOOL)isTopViewVideoStyle;
//是否是TopView
- (BOOL)isTopView;
//获取topview类型
- (HCTopViewType)getTopViewType;
//是否是横版视频
- (BOOL)isHorizontalVideo;
/// 是否需要隐藏广告标记
- (BOOL)needHideAdMark;

// 字符串转数组
-(NSArray *)curl_1_array;
-(NSArray *)curl_2_array;
-(NSArray *)curl_3_array;

@end


@interface SQRHuiChuanResponseADVedioModel : NSObject
 /// LD为高清
@property (nonatomic,copy)NSString *LD;
/// FD为标情
@property (nonatomic,copy)NSString *FD;
@end

@interface SQRHuiChuanResponseInfoModel : NSObject

/// 手淘回传的策略ID
@property (nonatomic, copy) NSString *shoutao_rta;

@end

NS_ASSUME_NONNULL_END
