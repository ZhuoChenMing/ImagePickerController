//
//  VideoPlayerController.m
//  ImagePickerController
//
//  Created by 酌晨茗 on 16/1/5.
//  Copyright © 2016年 酌晨茗. All rights reserved.
//

#import "VideoPlayerController.h"
#import <MediaPlayer/MediaPlayer.h>

#import "AlbumDataHandle.h"
#import "PhotoPickerModel.h"
#import "AlbumListController.h"
#import "PhotoPreviewController.h"

@interface VideoPlayerController () {
    AVPlayer *_player;
    UIButton *_playButton;
    UIImage *_cover;
    
    UIView *_toolBar;
    UIButton *_okButton;
    UIProgressView *_progress;
}
@end

@implementation VideoPlayerController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationItem.title = @"视频预览";
    [self configMoviePlayer];
}

- (void)configMoviePlayer {
    
    [[AlbumDataHandle manager] getPhotoWithAsset:_model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        _cover = photo;
    }];
    [[AlbumDataHandle manager] getVideoWithAsset:_model.asset completion:^(AVPlayerItem *playerItem, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _player = [AVPlayer playerWithPlayerItem:playerItem];
            AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
            playerLayer.frame = self.view.bounds;
            [self.view.layer addSublayer:playerLayer];
            [self addProgressObserver];
            [self configPlayButton];
            [self configBottomToolBar];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pausePlayerAndShowNaviBar) name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
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
    AlbumNavigationController *navigation = (AlbumNavigationController *)self.navigationController;
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
        if (iOS7Later) {
            [UIApplication sharedApplication].statusBarHidden = YES;
        }
    } else {
        [self pausePlayerAndShowNaviBar];
    }
}

- (void)okButtonClick {
    AlbumNavigationController *navigation = (AlbumNavigationController *)self.navigationController;
    if ([navigation.pickerDelegate respondsToSelector:@selector(albumNavigationController:didFinishPickingVideo:sourceAssets:)]) {
        [navigation.pickerDelegate albumNavigationController:navigation didFinishPickingVideo:_cover sourceAssets:_model.asset];
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
    if (iOS7Later) [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
