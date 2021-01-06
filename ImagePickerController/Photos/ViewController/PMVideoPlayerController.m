//
//  PMVideoPlayerController.m
//  ImagePickerController
//
//  Created by 酌晨茗 on 16/1/5.
//  Copyright © 2016年 酌晨茗. All rights reserved.
//

#import "PMVideoPlayerController.h"
#import <MediaPlayer/MediaPlayer.h>

#import "PMDataManager.h"
#import "PMPhotoInfoModel.h"
#import "PMAlbumViewController.h"
#import "PMPhotoController.h"

@interface PMVideoPlayerController ()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIImage *cover;
    
@property (nonatomic, strong) UIView *toolBar;
@property (nonatomic, strong) UIButton *okButton;
@property (nonatomic, strong) UIProgressView *progress;

@end

@implementation PMVideoPlayerController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationItem.title = @"视频预览";
    [self configMoviePlayer];
}

- (void)configMoviePlayer {
    __weak typeof(self) weakSelf = self;
    [[PMDataManager manager] getPhotoWithAsset:_model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        weakSelf.cover = photo;
    }];
    [[PMDataManager manager] getVideoWithAsset:_model.asset completion:^(AVPlayerItem *playerItem, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.player = [AVPlayer playerWithPlayerItem:playerItem];
            AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:weakSelf.player];
            playerLayer.frame = weakSelf.view.bounds;
            [weakSelf.view.layer addSublayer:playerLayer];
            [weakSelf addProgressObserver];
            [weakSelf configPlayButton];
            [weakSelf configBottomToolBar];
            [[NSNotificationCenter defaultCenter] addObserver:weakSelf selector:@selector(pausePlayerAndShowNaviBar) name:AVPlayerItemDidPlayToEndTimeNotification object:weakSelf.player.currentItem];
        });
    }];
}

/// Show progress，do it next time / 给播放器添加进度更新,下次加上
-(void)addProgressObserver {
    AVPlayerItem *playerItem = _player.currentItem;
    UIProgressView *progress = _progress;
    [_player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        float current = CMTimeGetSeconds(time);
        float total = CMTimeGetSeconds([playerItem duration]);
        if (current) {
            [progress setProgress:(current / total) animated:YES];
        }
    }];
}

- (void)configPlayButton {
    _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _playButton.frame = CGRectMake(0, 64, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 64 - 44);
    [_playButton setImage:[UIImage imageNamed:@"MMVideoPreviewPlay"] forState:UIControlStateNormal];
    [_playButton setImage:[UIImage imageNamed:@"MMVideoPreviewPlayHL"] forState:UIControlStateHighlighted];
    [_playButton addTarget:self action:@selector(playButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_playButton];
}

- (void)configBottomToolBar {
    _toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 44, CGRectGetWidth(self.view.frame), 44)];
    CGFloat rgb = 34 / 255.0;
    _toolBar.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:1.0];
    _toolBar.alpha = 0.7;
    
    _okButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _okButton.frame = CGRectMake(CGRectGetWidth(self.view.frame) - 44 - 12, 0, 44, 44);
    _okButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_okButton addTarget:self action:@selector(okButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_okButton setTitle:@"确定" forState:UIControlStateNormal];
    PMNavigationController *navigation = (PMNavigationController *)self.navigationController;
    [_okButton setTitleColor:navigation.oKButtonTitleColorNormal forState:UIControlStateNormal];
    
    [_toolBar addSubview:_okButton];
    [self.view addSubview:_toolBar];
}

#pragma mark - 点击事件
- (void)playButtonClick {
    CMTime currentTime = _player.currentItem.currentTime;
    CMTime durationTime = _player.currentItem.duration;
    if (_player.rate == 0.0f) {
        if (currentTime.value == durationTime.value) {
            [_player.currentItem seekToTime:CMTimeMake(0, 1)];
        }
        [_player play];
        [self.navigationController setNavigationBarHidden:YES];
        _toolBar.hidden = YES;
        [_playButton setImage:nil forState:UIControlStateNormal];
        if ([PMDataManager manager].systemVersion >= 7) {
            [UIApplication sharedApplication].statusBarHidden = YES;
        }
    } else {
        [self pausePlayerAndShowNaviBar];
    }
}

- (void)okButtonClick {
    PMNavigationController *navigation = (PMNavigationController *)self.navigationController;
    if ([navigation.pickerDelegate respondsToSelector:@selector(navigationController:didFinishPickingVideo:sourceAssets:)]) {
        [navigation.pickerDelegate navigationController:navigation didFinishPickingVideo:_cover sourceAssets:_model.asset];
    }
    if (navigation.didFinishPickingVideoHandle) {
        navigation.didFinishPickingVideoHandle(_cover,_model.asset);
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Notification Method
- (void)pausePlayerAndShowNaviBar {
    [_player pause];
    _toolBar.hidden = NO;
    [self.navigationController setNavigationBarHidden:NO];
    [_playButton setImage:[UIImage imageNamed:@"MMVideoPreviewPlay"] forState:UIControlStateNormal];
    if ([PMDataManager manager].systemVersion >= 7) {
        [UIApplication sharedApplication].statusBarHidden = NO;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
