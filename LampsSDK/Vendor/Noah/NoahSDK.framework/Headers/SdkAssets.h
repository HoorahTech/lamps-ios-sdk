//
//  SdkAssets.h
//  NoahSDK
//
//  Created by Reus on 2020/11/18.
//  Copyright © 2020 zhongyang.ywx. All rights reserved.
//

#import "NAAdStyle.h"
#import <UIKit/UIKit.h>

@class Image, NALiveInfo, NALiveCouponInfo, NAVoucherInfo;
@class AdnProduct;
@class AdnInfo;

NS_ASSUME_NONNULL_BEGIN

@interface SdkAssets : NSObject

-(instancetype)initWithProduct:(AdnProduct *)product;

-(NSString *) getTitle;
-(NSString *) getAdnPlacementId;
-(NSString *) getSource;
-(NSString *) getSlotKey;
-(NSString *) getSubTitle;
-(NSString *) getDescription;
-(NSString *) getCallToAction;
-(NSString *) getAssetId;
-(NSString *) getAdnName;
-(NSObject *) getCustomObj;
-(NSObject *) getCustomShowBlock;
-(NSObject *) getCustomClickBlock;
-(NSObject *) getCustomShowEndBlock;
-(NSString *) getSessionId;
-(NSString *) getSearchId;

-(int)getAdStyle;
-(int)getMediaType;
-(NAAdCreateType)getCreateType;
-(int)getAdnId;
-(int)getAdSourceType;

-(BOOL)isAppAd;
-(BOOL)isVideo;
-(long)getExpiredTime;
-(double)getPrice;
-(double)getRating;
-(nullable NALiveInfo *)getLiveInfo;
-(nullable NALiveCouponInfo *)getCouponInfo;
-(nullable NAVoucherInfo *)getVoucherInfo;
-(Image *)getIcon;
-(Image *)getAdChoicesIcon;
-(Image *)getCover;
-(NSArray<Image *> *)getCovers;
-(UIImage *)getAdLogo;
-(NSDictionary *)getAdContent;
-(AdnInfo *)getAdnInfo;
-(int)getVideoDuration;
-(NSArray*)getFilterAdArr;
//模版渲染
-(BOOL)isExpressAdType;
-(NSInteger)getSliderControlInterval;
-(BOOL)isNeedShieldAdnInfo;
-(NSInteger)getGiftShowInterval;
-(int)nfAdOffset;
-(int)nfAdPos;
-(NSString *)vfAdItemId;
-(int)vfAdItemMoveForwardNum;
-(NSString *)getBulletContent;
-(nullable NSDictionary *)getAppExtStatParams;
-(nullable NSDictionary *)getMediaExt;
-(int)getNativeRewardDuration;
-(int)getNativeRewardTaskAction;
@end

NS_ASSUME_NONNULL_END
