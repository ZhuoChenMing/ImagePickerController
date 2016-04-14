//
//  PhotoPreviewController.m
//  ImagePickerController
//
//  Created by 酌晨茗 on 15/12/24.
//  Copyright © 2015年 酌晨茗. All rights reserved.
//

#import "PhotoPreviewController.h"
#import "PhotoPreviewCell.h"
#import "PhotoPickerModel.h"
#import "AlbumListController.h"
#import "AlbumDataHandle.h"

@implementation PhotoToolBarView

- (instancetype)initWithNavigation:(AlbumNavigationController *)navigation
                selectedPhotoArray:(NSArray *)selectedPhotoArray
                        photoArray:(NSArray *)photoArray
          isHavePreviewPhotoButton:(BOOL)isHave {
    self = [super init];
    if (self) {
        CGRect windowRect = [UIScreen mainScreen].bounds;
        CGFloat width = CGRectGetWidth(windowRect);
        CGFloat height = CGRectGetHeight(windowRect);
        
        self.frame = CGRectMake(0, height - 50, width, 50);
        CGFloat rgb = 253 / 255.0;
        self.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:1.0];
        
        UIView *divide = [[UIView alloc] init];
        CGFloat rgb2 = 222 / 255.0;
        divide.backgroundColor = [UIColor colorWithRed:rgb2 green:rgb2 blue:rgb2 alpha:1.0];
        divide.frame = CGRectMake(0, 0, width, 1);
        [self addSubview:divide];
        
        _okButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _okButton.frame = CGRectMake(width - 44 - 12, 3, 44, 44);
        _okButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_okButton setTitle:@"确定" forState:UIControlStateNormal];
        [_okButton setTitle:@"确定" forState:UIControlStateDisabled];
        [_okButton setTitleColor:navigation.oKButtonTitleColorNormal forState:UIControlStateNormal];
        [_okButton setTitleColor:navigation.oKButtonTitleColorDisabled forState:UIControlStateDisabled];
        _okButton.enabled = selectedPhotoArray.count > 0;
        [self addSubview:_okButton];
        
        _numberLable = [[UILabel alloc] init];
        _numberLable.frame = CGRectMake(width - 56 - 24, 12, 26, 26);
        _numberLable.layer.cornerRadius = 13.0;
        _numberLable.clipsToBounds = YES;
        _numberLable.font = [UIFont systemFontOfSize:16];
        _numberLable.textColor = [UIColor whiteColor];
        _numberLable.textAlignment = NSTextAlignmentCenter;
        _numberLable.text = [NSString stringWithFormat:@"%zd", selectedPhotoArray.count];
        _numberLable.hidden = selectedPhotoArray.count <= 0;
        _numberLable.backgroundColor = navigation.oKButtonTitleColorNormal;
        [self addSubview:_numberLable];
        
        if (navigation.allowPickingOriginalPhoto) {
            _originalPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _originalPhotoButton.imageEdgeInsets = UIEdgeInsetsMake(0, -8, 0, 0);
            _originalPhotoButton.contentEdgeInsets = UIEdgeInsetsMake(0, -45, 0, 0);
            _originalPhotoButton.titleLabel.font = [UIFont systemFontOfSize:16];
            [_originalPhotoButton setTitle:@"原图" forState:UIControlStateNormal];
            [_originalPhotoButton setTitle:@"原图" forState:UIControlStateSelected];
            [_originalPhotoButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [_originalPhotoButton setTitleColor:navigation.oKButtonTitleColorNormal forState:UIControlStateSelected];
            [_originalPhotoButton setImage:[UIImage imageNamed:@"photo_original_def"] forState:UIControlStateNormal];
            [_originalPhotoButton setImage:[UIImage imageNamed:@"photo_original_sel"] forState:UIControlStateSelected];

            _originalPhotoLable = [[UILabel alloc] init];
            _originalPhotoLable.frame = CGRectMake(70, 0, 60, 50);
            _originalPhotoLable.textAlignment = NSTextAlignmentLeft;
            _originalPhotoLable.font = [UIFont systemFontOfSize:16];
            _originalPhotoLable.textColor = navigation.oKButtonTitleColorNormal;
            if (isHave) {
                [[AlbumDataHandle manager] getPhotoBytesWithPhotoArray:photoArray completion:^(NSString *totalBytes) {
                    self.originalPhotoLable.text = [NSString stringWithFormat:@"(%@)",totalBytes];
                }];
            }
            [_originalPhotoButton addSubview:_originalPhotoLable];
            [self addSubview:_originalPhotoButton];
        }
        
        if (isHave) {
            _originalPhotoButton.frame = CGRectMake(60, 0, 130, 50);
            _originalPhotoButton.enabled = selectedPhotoArray.count > 0;

            _previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _previewButton.frame = CGRectMake(10, 3, 44, 44);
            _previewButton.titleLabel.font = [UIFont systemFontOfSize:16];
            [_previewButton setTitle:@"预览" forState:UIControlStateNormal];
            [_previewButton setTitle:@"预览" forState:UIControlStateDisabled];
            [_previewButton setTitleColor:navigation.oKButtonTitleColorNormal forState:UIControlStateNormal];
            [_previewButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
            _previewButton.enabled = NO;
            [self addSubview:_previewButton];
        } else {
            _originalPhotoButton.frame = CGRectMake(10, 0, 130, 50);
        }
    }
    return self;
}

@end

@interface PhotoPreviewController ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, assign) BOOL isHideNaviBar;

@property (nonatomic, strong) UIButton *selectButton;

@property (nonatomic, strong) PhotoToolBarView *toolBarView;

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation PhotoPreviewController

- (NSMutableArray *)selectedPhotoArray {
    if (_selectedPhotoArray == nil) {
        _selectedPhotoArray = [[NSMutableArray alloc] init];
    }
    return _selectedPhotoArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createCustomNavigationButton];
    [self initCollectionView];
    [self configBottomToolBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_currentIndex) {
        [self.collectionView setContentOffset:CGPointMake(CGRectGetWidth(self.view.frame) * _currentIndex, 0) animated:NO];
    }
    
    [self refreshNaviBarAndBottomBarState];
}

#pragma mark - 控件堆砌
- (void)createCustomNavigationButton {
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    [leftBarButton setImageInsets:UIEdgeInsetsMake(0, -8, 0, 0)];
    self.navigationItem.leftBarButtonItem = leftBarButton;

    _selectButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 42, 42)];
    [_selectButton setImage:[UIImage imageNamed:@"photo_def_photoPickerVc"] forState:UIControlStateNormal];
    [_selectButton setImage:[UIImage imageNamed:@"photo_sel_photoPickerVc"] forState:UIControlStateSelected];
    [_selectButton addTarget:self action:@selector(select:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:_selectButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;
}

- (void)initCollectionView {
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
    [self.view addSubview:_collectionView];
    
    [self.collectionView registerClass:[PhotoPreviewCell class] forCellWithReuseIdentifier:@"PhotoPreviewCell"];
}

- (void)configBottomToolBar {
    AlbumNavigationController *navigation = (AlbumNavigationController *)self.navigationController;
    self.toolBarView = [[PhotoToolBarView alloc] initWithNavigation:navigation selectedPhotoArray:_selectedPhotoArray photoArray:_photoArray isHavePreviewPhotoButton:NO];
    
    [self.toolBarView.originalPhotoButton addTarget:self action:@selector(originalPhotoButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.toolBarView.okButton addTarget:self action:@selector(okButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_toolBarView];
}

#pragma mark - 点击事件
- (void)select:(UIButton *)selectButton {
    PhotoPickerModel *model = _photoArray[_currentIndex];
    if (!selectButton.isSelected) {
        // 1. 选择照片,检查是否超过了最大个数的限制
        AlbumNavigationController *navigation = (AlbumNavigationController *)self.navigationController;
        if (self.selectedPhotoArray.count >= navigation.maxImagesCount) {
            [navigation showAlertWithTitle:[NSString stringWithFormat:@"你最多只能选择%zd张照片",navigation.maxImagesCount]];
            return;
        // 2. 如果没有超过最大个数限制
        } else {
            [self.selectedPhotoArray addObject:model];
            if (model.type == AlbumModelMediaTypeVideo) {
                AlbumNavigationController *navigation = (AlbumNavigationController *)self.navigationController;
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
    [self showOscillatoryAnimationWithLayer:_toolBarView.numberLable.layer type:1];
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

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
    if (self.returnNewSelectedPhotoArrBlock) {
        self.returnNewSelectedPhotoArrBlock(self.selectedPhotoArray,_isSelectOriginalPhoto);
    }
}

- (void)okButtonClick {
    if (self.okButtonClickBlock) {
        self.okButtonClickBlock(self.selectedPhotoArray, _isSelectOriginalPhoto);
    }
}

- (void)originalPhotoButtonClick {
    _toolBarView.originalPhotoButton.selected = !_toolBarView.originalPhotoButton.isSelected;
    _isSelectOriginalPhoto = _toolBarView.originalPhotoButton.isSelected;
    _toolBarView.originalPhotoLable.hidden = !_toolBarView.originalPhotoButton.isSelected;
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
    PhotoPreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoPreviewCell" forIndexPath:indexPath];
    cell.model = _photoArray[indexPath.row];

    __weak PhotoPreviewController *weakSelf = self;
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
            [self prefersStatusBarHidden];
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
    PhotoPickerModel *model = _photoArray[_currentIndex];
    _selectButton.selected = model.isSelected;
    _toolBarView.numberLable.text = [NSString stringWithFormat:@"%zd",_selectedPhotoArray.count];
    _toolBarView.numberLable.hidden = (_selectedPhotoArray.count <= 0 || _isHideNaviBar);
    
    _toolBarView.originalPhotoButton.selected = _isSelectOriginalPhoto;
    _toolBarView.originalPhotoLable.hidden = !_toolBarView.originalPhotoButton.isSelected;
    if (_isSelectOriginalPhoto) {
        [self showPhotoBytes];
    }
    
    _toolBarView.okButton.enabled = _selectedPhotoArray.count > 0;

    // 如果正在预览的是视频，隐藏原图按钮
    if (_isHideNaviBar) {
        return;
    }
    if (model.type == AlbumModelMediaTypeVideo) {
        _toolBarView.originalPhotoButton.hidden = YES;
        _toolBarView.originalPhotoLable.hidden = YES;
    } else {
        _toolBarView.originalPhotoButton.hidden = NO;
        if (_isSelectOriginalPhoto) {
            _toolBarView.originalPhotoLable.hidden = NO;
        }
    }
}

- (void)showPhotoBytes {
    [[AlbumDataHandle manager] getPhotoBytesWithPhotoArray:@[_photoArray[_currentIndex]] completion:^(NSString *totalBytes) {
        _toolBarView.originalPhotoLable.text = [NSString stringWithFormat:@"(%@)",totalBytes];
    }];
}

@end
