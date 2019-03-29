//
//  PMPhotoController.m
//  ImagePickerController
//
//  Created by 酌晨茗 on 15/12/24.
//  Copyright © 2015年 酌晨茗. All rights reserved.
//

#import "PMPhotoController.h"
#import "PMAlbumViewController.h"
//view
#import "PMPhotoToolBarView.h"
#import "PMPhotoPreviewCell.h"
//model
#import "PMPhotoInfoModel.h"
//数据处理
#import "PMDataManager.h"

@interface PMPhotoController ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, assign) BOOL isHideNaviBar;

@property (nonatomic, strong) UIButton *selectButton;

@property (nonatomic, strong) PMPhotoToolBarView *toolBarView;

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation PMPhotoController

- (NSMutableArray *)selectedPhotoArray {
    if (_selectedPhotoArray == nil) {
        _selectedPhotoArray = [[NSMutableArray alloc] init];
    }
    return _selectedPhotoArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //标题栏
    self.selectButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 42)];
    [self.selectButton setImage:[UIImage imageNamed:@"photo_def_photoPickerVc"] forState:UIControlStateNormal];
    [self.selectButton setImage:[UIImage imageNamed:@"photo_sel_photoPickerVc"] forState:UIControlStateSelected];
    [self.selectButton addTarget:self action:@selector(select:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:_selectButton];
    
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceItem.width = -15;
    self.navigationItem.rightBarButtonItems = @[spaceItem, rightBarButton];
    
    //照片预览网格
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;

    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor blackColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.scrollsToTop = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.contentOffset = CGPointMake(0, 0);
    self.collectionView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame) * _photoArray.count, CGRectGetHeight(self.view.frame));
    [self.collectionView registerClass:[PMPhotoPreviewCell class] forCellWithReuseIdentifier:@"PMPhotoPreviewCell"];
    [self.view addSubview:_collectionView];
    
    //底部工具栏
    PMNavigationController *navigation = (PMNavigationController *)self.navigationController;
    self.toolBarView = [[PMPhotoToolBarView alloc] initWithNavigation:navigation selectedPhotoArray:_selectedPhotoArray photoArray:_photoArray isHavePreviewPhotoButton:NO];
    
    [self.toolBarView.originalPhotoButton addTarget:self action:@selector(originalPhotoButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.toolBarView.okButton addTarget:self action:@selector(okButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_toolBarView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_currentIndex) {
        [self.collectionView setContentOffset:CGPointMake(CGRectGetWidth(self.view.frame) * _currentIndex, 0) animated:NO];
    }
    
    [self refreshNaviBarAndBottomBarState];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.returnNewSelectedPhotoArrBlock) { self.returnNewSelectedPhotoArrBlock(_selectedPhotoArray, _isSelectOriginalPhoto);
    }
}

#pragma mark - 点击事件
- (void)select:(UIButton *)selectButton {
    PMPhotoInfoModel *model = _photoArray[_currentIndex];
    if (!selectButton.isSelected) {
        // 1. 选择照片,检查是否超过了最大个数的限制
        PMNavigationController *navigation = (PMNavigationController *)self.navigationController;
        if (self.selectedPhotoArray.count >= navigation.maxImagesCount) {
            [navigation showAlertWithTitle:[NSString stringWithFormat:@"你最多只能选择%zd张照片",navigation.maxImagesCount]];
            return;
            // 2. 如果没有超过最大个数限制
        } else {
            [self.selectedPhotoArray addObject:model];
            if (model.type == PMPhotoTypeVideo) {
                PMNavigationController *navigation = (PMNavigationController *)self.navigationController;
                [navigation showAlertWithTitle:@"多选状态下选择视频，默认将视频当图片发送"];
            }
        }
    } else {
        [self.selectedPhotoArray removeObject:model];
    }
    model.isSelected = !selectButton.isSelected;
    [self refreshNaviBarAndBottomBarState];
    if (model.isSelected) {
        [self showOscillatoryAnimationWithLayer:selectButton.imageView.layer type:0];
    }
    [self showOscillatoryAnimationWithLayer:_toolBarView.numberLabel.layer type:1];
}

- (void)showOscillatoryAnimationWithLayer:(CALayer *)layer type:(BOOL)type {
    NSNumber *animationScale1 = type == 0 ? @(1.15) : @(0.5);
    NSNumber *animationScale2 = type == 0 ? @(0.92) : @(1.15);
    
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
        [layer setValue:animationScale1 forKeyPath:@"transform.scale"];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
            [layer setValue:animationScale2 forKeyPath:@"transform.scale"];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
                [layer setValue:@(1.0) forKeyPath:@"transform.scale"];
            } completion:nil];
        }];
    }];
}

- (void)okButtonClick {
    if (self.okButtonClickBlock) {
        self.okButtonClickBlock(self.selectedPhotoArray, _isSelectOriginalPhoto);
    }
}

- (void)originalPhotoButtonClick {
    _toolBarView.originalPhotoButton.selected = !_toolBarView.originalPhotoButton.isSelected;
    _isSelectOriginalPhoto = _toolBarView.originalPhotoButton.isSelected;
    _toolBarView.originalPhotoLabel.hidden = !_toolBarView.originalPhotoButton.isSelected;
    if (_isSelectOriginalPhoto) {
        [self showPhotoBytes];
        if (!_selectButton.isSelected) {
            [self select:_selectButton];
        }
    }
}

#pragma mark - UIScrollView代理
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint offSet = scrollView.contentOffset;
    _currentIndex = offSet.x / CGRectGetWidth(self.view.frame);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self refreshNaviBarAndBottomBarState];
}

#pragma mark - UICollectionViewDataSource && Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _photoArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PMPhotoPreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PMPhotoPreviewCell" forIndexPath:indexPath];
    cell.model = _photoArray[indexPath.row];
    
    __weak typeof(self) weakSelf = self;
    cell.singleTapGestureBlock = ^() {
        weakSelf.isHideNaviBar = !weakSelf.isHideNaviBar;
        
        if (weakSelf.isHideNaviBar) {
            [UIView animateWithDuration:0.3 animations:^{
                CGRect windowRect = [UIScreen mainScreen].bounds;
                weakSelf.toolBarView.frame = CGRectMake(0, CGRectGetHeight(windowRect), CGRectGetWidth(windowRect), 50);
            } completion:^(BOOL finished) {
                weakSelf.toolBarView.hidden = weakSelf.isHideNaviBar;
            }];
        } else {
            weakSelf.toolBarView.hidden = weakSelf.isHideNaviBar;
            [UIView animateWithDuration:0.3 animations:^{
                CGRect windowRect = [UIScreen mainScreen].bounds;
                weakSelf.toolBarView.frame = CGRectMake(0, CGRectGetHeight(windowRect) - 50, CGRectGetWidth(windowRect), 50);
            }];
        }
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        if (iOS9Later) {
            [weakSelf prefersStatusBarHidden];
        } else {
            [[UIApplication sharedApplication] setStatusBarHidden:weakSelf.isHideNaviBar withAnimation:UIStatusBarAnimationSlide];
        }
#pragma clang diagnostic pop
        [weakSelf.navigationController setNavigationBarHidden:weakSelf.isHideNaviBar animated:YES];
    };
    return cell;
}

#pragma mark - 刷新toolBarView
- (void)refreshNaviBarAndBottomBarState {
    PMPhotoInfoModel *model = _photoArray[_currentIndex];
    _selectButton.selected = model.isSelected;
    _toolBarView.numberLabel.text = [NSString stringWithFormat:@"%zd",_selectedPhotoArray.count];
    _toolBarView.numberLabel.hidden = (_selectedPhotoArray.count <= 0 || _isHideNaviBar);
    
    _toolBarView.originalPhotoButton.selected = _isSelectOriginalPhoto;
    _toolBarView.originalPhotoLabel.hidden = !_toolBarView.originalPhotoButton.isSelected;
    if (_isSelectOriginalPhoto) {
        [self showPhotoBytes];
    }
    
    _toolBarView.okButton.enabled = _selectedPhotoArray.count > 0;
    
    // 如果正在预览的是视频，隐藏原图按钮
    if (_isHideNaviBar) {
        return;
    }
    if (model.type == PMPhotoTypeVideo) {
        _toolBarView.originalPhotoButton.hidden = YES;
        _toolBarView.originalPhotoLabel.hidden = YES;
    } else {
        _toolBarView.originalPhotoButton.hidden = NO;
        if (_isSelectOriginalPhoto) {
            _toolBarView.originalPhotoLabel.hidden = NO;
        }
    }
}

- (void)showPhotoBytes {
    [[PMDataManager manager] getPhotoBytesWithPhotoArray:@[_photoArray[_currentIndex]] completion:^(NSString *totalBytes) {
        self.toolBarView.originalPhotoLabel.text = [NSString stringWithFormat:@"(%@)",totalBytes];
    }];
}

@end
