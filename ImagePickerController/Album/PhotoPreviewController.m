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
#import "AlbumAllMedia.h"

@interface PhotoPreviewController ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, assign) BOOL isHideNaviBar;

@property (nonatomic, strong) UIButton *selectButton;

@property (nonatomic, strong) UIView *toolBarView;
@property (nonatomic, strong) UIButton *okButton;
@property (nonatomic, strong) UIImageView *numberImageView;
@property (nonatomic, strong) UILabel *numberLable;
@property (nonatomic, strong) UIButton *originalPhotoButton;
@property (nonatomic, strong) UILabel *originalPhotoLable;

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation PhotoPreviewController

- (NSMutableArray *)selectedPhotoArray {
    if (_selectedPhotoArray == nil) {
        _selectedPhotoArray = [[NSMutableArray alloc] init];
    }
    return _selectedPhotoArray;
}

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

- (void)configBottomToolBar {
    _toolBarView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 44, CGRectGetWidth(self.view.frame), 44)];
    CGFloat rgb = 34 / 255.0;
    _toolBarView.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:1.0];
    _toolBarView.alpha = 0.7;
    
    AlbumNavigationController *navigation = (AlbumNavigationController *)self.navigationController;
    if (navigation.allowPickingOriginalPhoto) {
        _originalPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _originalPhotoButton.frame = CGRectMake(5, 0, 120, 44);
        _originalPhotoButton.imageEdgeInsets = UIEdgeInsetsMake(0, -8, 0, 0);
        _originalPhotoButton.contentEdgeInsets = UIEdgeInsetsMake(0, -50, 0, 0);
        _originalPhotoButton.backgroundColor = [UIColor clearColor];
        [_originalPhotoButton addTarget:self action:@selector(originalPhotoButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _originalPhotoButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [_originalPhotoButton setTitle:@"原图" forState:UIControlStateNormal];
        [_originalPhotoButton setTitle:@"原图" forState:UIControlStateSelected];
        [_originalPhotoButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_originalPhotoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [_originalPhotoButton setImage:[UIImage imageNamed:@"preview_original_def"] forState:UIControlStateNormal];
        [_originalPhotoButton setImage:[UIImage imageNamed:@"photo_original_sel"] forState:UIControlStateSelected];
        
        _originalPhotoLable = [[UILabel alloc] init];
        _originalPhotoLable.frame = CGRectMake(60, 0, 70, 44);
        _originalPhotoLable.textAlignment = NSTextAlignmentLeft;
        _originalPhotoLable.font = [UIFont systemFontOfSize:13];
        _originalPhotoLable.textColor = [UIColor whiteColor];
        _originalPhotoLable.backgroundColor = [UIColor clearColor];
        if (_isSelectOriginalPhoto) [self showPhotoBytes];
    }
    
    _okButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _okButton.frame = CGRectMake(CGRectGetWidth(self.view.frame) - 44 - 12, 0, 44, 44);
    _okButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_okButton addTarget:self action:@selector(okButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_okButton setTitle:@"确定" forState:UIControlStateNormal];
    [_okButton setTitleColor:navigation.oKButtonTitleColorNormal forState:UIControlStateNormal];
    
    _numberImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo_number_icon"]];
    _numberImageView.backgroundColor = [UIColor clearColor];
    _numberImageView.frame = CGRectMake(CGRectGetWidth(self.view.frame) - 56 - 24, 9, 26, 26);
    _numberImageView.hidden = _selectedPhotoArray.count <= 0;
    
    _numberLable = [[UILabel alloc] init];
    _numberLable.frame = _numberImageView.frame;
    _numberLable.font = [UIFont systemFontOfSize:16];
    _numberLable.textColor = [UIColor whiteColor];
    _numberLable.textAlignment = NSTextAlignmentCenter;
    _numberLable.text = [NSString stringWithFormat:@"%zd",_selectedPhotoArray.count];
    _numberLable.hidden = _selectedPhotoArray.count <= 0;
    _numberLable.backgroundColor = [UIColor clearColor];

    [_originalPhotoButton addSubview:_originalPhotoLable];
    [_toolBarView addSubview:_okButton];
    [_toolBarView addSubview:_originalPhotoButton];
    [_toolBarView addSubview:_numberImageView];
    [_toolBarView addSubview:_numberLable];
    [self.view addSubview:_toolBarView];
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

#pragma mark - Click Event
- (void)select:(UIButton *)selectButton {
    PhotoPickerModel *model = _photoArray[_currentIndex];
    if (!selectButton.isSelected) {
        // 1. select:check if over the maxImagesCount / 选择照片,检查是否超过了最大个数的限制
        AlbumNavigationController *navigation = (AlbumNavigationController *)self.navigationController;
        if (self.selectedPhotoArray.count >= navigation.maxImagesCount) {
            [navigation showAlertWithTitle:[NSString stringWithFormat:@"你最多只能选择%zd张照片",navigation.maxImagesCount]];
            return;
        // 2. if not over the maxImagesCount / 如果没有超过最大个数限制
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
    [self showOscillatoryAnimationWithLayer:_numberImageView.layer type:1];
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
    _originalPhotoButton.selected = !_originalPhotoButton.isSelected;
    _isSelectOriginalPhoto = _originalPhotoButton.isSelected;
    _originalPhotoLable.hidden = !_originalPhotoButton.isSelected;
    if (_isSelectOriginalPhoto) {
        [self showPhotoBytes];
        if (!_selectButton.isSelected) [self select:_selectButton];
    }
}

#pragma mark - UIScrollViewDelegate
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
    
//    cell.singleTapGestureBlock = ^() {
//        weakSelf.isHideNaviBar = NO;
//        weakSelf.toolBarView.hidden = _isHideNaviBar;
//        [[UIApplication sharedApplication] setStatusBarHidden:_isHideNaviBar withAnimation:UIStatusBarAnimationSlide];
//        [weakSelf.navigationController setNavigationBarHidden:_isHideNaviBar animated:YES];
//    };
    
    cell.doubleTapGestureBlock = ^() {
        weakSelf.isHideNaviBar = !weakSelf.isHideNaviBar;
        weakSelf.toolBarView.hidden = weakSelf.isHideNaviBar;
        
        [[UIApplication sharedApplication] setStatusBarHidden:weakSelf.isHideNaviBar withAnimation:UIStatusBarAnimationSlide];
        
        [weakSelf.navigationController setNavigationBarHidden:weakSelf.isHideNaviBar animated:YES];
    };
    return cell;
}

#pragma mark - Private Method
- (void)refreshNaviBarAndBottomBarState {
    PhotoPickerModel *model = _photoArray[_currentIndex];
    _selectButton.selected = model.isSelected;
    _numberLable.text = [NSString stringWithFormat:@"%zd",_selectedPhotoArray.count];
    _numberImageView.hidden = (_selectedPhotoArray.count <= 0 || _isHideNaviBar);
    _numberLable.hidden = (_selectedPhotoArray.count <= 0 || _isHideNaviBar);
    
    _originalPhotoButton.selected = _isSelectOriginalPhoto;
    _originalPhotoLable.hidden = !_originalPhotoButton.isSelected;
    if (_isSelectOriginalPhoto) {
        [self showPhotoBytes];
    }
    
    // If is previewing video, hide original photo button
    // 如果正在预览的是视频，隐藏原图按钮
    if (_isHideNaviBar) {
        return;
    }
    if (model.type == AlbumModelMediaTypeVideo) {
        _originalPhotoButton.hidden = YES;
        _originalPhotoLable.hidden = YES;
    } else {
        _originalPhotoButton.hidden = NO;
        if (_isSelectOriginalPhoto)  _originalPhotoLable.hidden = NO;
    }
}

- (void)showPhotoBytes {
    [[AlbumAllMedia manager] getPhotosBytesWithArray:@[_photoArray[_currentIndex]] completion:^(NSString *totalBytes) {
        self.originalPhotoLable.text = [NSString stringWithFormat:@"(%@)",totalBytes];
    }];
}

@end
