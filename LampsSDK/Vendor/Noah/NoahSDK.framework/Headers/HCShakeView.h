//
//  HCShakeView.h
//
//  Created by zhongyang on 2021/7/13.
//

#import "HCShakeDefineHeader.h"

#ifdef HC_SHAKE_BUILD_ENABLE

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HCShakeView : UIView

@property (nonatomic, assign) BOOL isRemoveGradientLayer;
@property (nonatomic, assign) BOOL removeShakeViewEnable;
@property (nonatomic, assign) BOOL isAccelerOrRotateCanShake;//加速度或角度满足条件就跳转
@property (nonatomic, assign) HCShakeSwingType shakeSwingType;  ///< 角度满足类型
@property (nonatomic, assign) HCShakeViewDestroyType shakeDestroyType;  ///< 摇一摇传感器销毁是否提前

// 此控件目前适用于 开屏，【5秒之后、可点点击、摇一摇响应成功】之后摇一摇动画停止
// frame 一般情况 width:屏幕宽度 height: 半屏180 全屏214
// clickBlock 点击回调block，非必须
// shakeOkBlock 摇一摇成功回调block
// extInfo 扩展参数 非必须 目前有： isOnlyClickShakeIcon(BOOL默认NO)
// shakeParam  15,35,3,0.3
// 第一位，加速度，不少于15m/s；(小于等于10，兜底13)
// 第二位，转动角度，不小于35°；（小于等于0，无兜底，不判断）
// 第三位，持续操作时间，不少于3s；（小于等于0，无兜底，不判断）
// 第四位，判断中断时间，加速度小于阀值时间段不超过0.3秒；（小于等于0，默认值0.4）
- (instancetype)initWithFrame:(CGRect)frame
                   shakeParam:(NSString *)shakeParam
            isShowRedPackRain:(BOOL)isShowRedPackRain
                   clickBlock:(nullable void(^)(void))clickBlock
                 shakeOkBlock:(void(^)(void))shakeOkBlock
                      extInfo:(nullable NSDictionary *)extInfo;

// 展示，开启加速度检测
-(void)addToView:(UIView *)parentView;
// 跳过广告时，最好主动调用关闭加速度检测
// 目前，初始化失败，检测成功，动画结束，dealloc 会调用
-(void)destory;
// 跳转时，获取三个方向加速度最大值的100倍取整
-(int)getAccelerMaxX;
-(int)getAccelerMaxY;
-(int)getAccelerMaxZ;

@end

NS_ASSUME_NONNULL_END

#endif
