//
//  SQRHCVideoPlayer.h
//  shuqireader
//
//  Created by Hsiang Chou on 2020/3/13.
//  Copyright © 2020 AliWenXue. All rights reserved.
//

#import <UIKit/UIKit.h>


@class SQRHCVideoModel, AVPlayer;
NS_ASSUME_NONNULL_BEGIN

@protocol SQRHCVideoPlayerDelegate <NSObject>
@optional
- (void)loadVideoCompleted;
- (void)loadVideoFailed:(NSError *_Nullable) error;
- (void)videoStartPlay;
- (void)videoPlayFailed;
- (void)videoPlayFinished;
- (void)videoPlayedWithTime:(NSTimeInterval) time;
- (void)videoPlayPaused;
- (void)videoClicked:(UITapGestureRecognizer *)gesture;
- (void)videoPlayPausedByBackGround;
- (void)videoContinuePlayByForeGround;
- (void)videoPlayedWithCurrentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime;
@end

typedef NS_ENUM(NSUInteger, SQRPlayerErrorCode){
    SQRPlayerErrorCodeNoError = 0,
    SQRPlayerErrorCodeNoKey = 100,                  ///< 渲染所必须的字段不完整
    SQRPlayerErrorCodeInvalidValue = 101,                 ///< 字段取值不合法
    SQRPlayerErrorCodeCannotAccessUrl = 102,              ///< 图片或目标url无法访问
    SQRPlayerErrorCodeOther = 105                          ///< 其他原因无法渲染
};

@interface SQRHCVideoPlayer : UIView
@property (nonatomic, strong) SQRHCVideoModel *videoModel;
@property (nonatomic, weak) id<SQRHCVideoPlayerDelegate> delegate;

@property (nonatomic, assign) BOOL isPlaying;

@property (nonatomic, strong, readonly) AVPlayer *player;

// 是否用于开屏
@property (nonatomic, assign) BOOL isSplash;

// 是否是TopView广告
@property (nonatomic, assign) BOOL isTopView;

@property (nonatomic, assign) BOOL disableVideoClick;

@property (nonatomic, assign) BOOL isRepeat;

@property (nonatomic, assign) BOOL isReplayFix;

@property (nonatomic, assign) BOOL isAppControlPlay;

/// 是否启用子线程加载视频资源，默认为 NO
@property (nonatomic, assign) BOOL enableLoadSubThread;
/// 当前播放进度 秒
- (NSTimeInterval)currentPlayTime;

- (instancetype)initWithFrame:(CGRect)frame;
//显示占位图 只显示占位图 不拉取资源
- (void)showDefaultImage;
//播放默认视频
- (void)playVideo;
//播放视频  默认视频为videoModel中的视频地址
- (void)playWithVideoUrl:(nullable NSString *)videoURL;
//静音管理
- (void)controlVolumn:(BOOL) muted;
- (BOOL)toggleMute;
//暂停播放
- (void)pausedVideo;
//刷新视频坐标
- (void)refreshVideoSize;
//移除视频
- (void)removePlayer;
//继续播放
- (void)continuePlayVideo;
//重新播放
- (void)rePlayVideo;

@end

NS_ASSUME_NONNULL_END
