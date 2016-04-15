//
//  PhotoPickerController.m
//  ImagePickerController
//
//  Created by 酌晨茗 on 15/12/24.
//  Copyright © 2015年 酌晨茗. All rights reserved.
//

#import "PhotoPickerController.h"
#import "PhotoPickerCell.h"
#import "PhotoPickerModel.h"

#import "AlbumListController.h"
#import "AlbumDataModel.h"

#import "PhotoPreviewController.h"
#import "AlbumDataHandle.h"
#import "VideoPlayerController.h"

@interface PhotoPickerController ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *photoArr;

@property (nonatomic, strong) PhotoToolBarView *toolBarView;

@property (nonatomic, assign) BOOL isSelectOriginalPhoto;
@property (nonatomic, assign) BOOL shouldScrollToBottom;

@property (nonatomic, strong) NSMutableArray *pickerModelArray;

@property CGRect previousPreheatRect;

@end

static CGSize AssetGridThumbnailSize;

@implementation PhotoPickerController

- (NSMutableArray *)pickerModelArray {
    if (_pickerModelArray == nil) {
        _pickerModelArray = [NSMutableArray array];
    }
    return _pickerModelArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = _model.name;
    _shouldScrollToBottom = YES;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    
    AlbumNavigationController *navigation = (AlbumNavigationController *)self.navigationController;
    [[AlbumDataHandle manager] getAssetsFromFetchResult:_model.result allowPickingVideo:navigation.allowPickingVideo completion:^(NSArray<PhotoPickerModel *> *models) {
        _photoArr = [NSMutableArray arrayWithArray:models];
        [self configCollectionView];
        [self configBottomToolBar];
    }];
    [self resetCachedAssets];
}

- (void)configCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat margin = 4;
    CGFloat itemWH = (CGRectGetWidth(self.view.frame) - 2 * margin - 4) / 4 - margin;
    layout.itemSize = CGSizeMake(itemWH, itemWH);
    layout.minimumInteritemSpacing = margin;
    layout.minimumLineSpacing = margin;
    CGFloat top = margin + 44;
    if (iOS7Later) top += 20;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(margin, top, CGRectGetWidth(self.view.frame) - 2 * margin, CGRectGetHeight(self.view.frame)- 50 - top) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.alwaysBounceHorizontal = NO;
    if (iOS7Later) _collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 2);
    _collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, -2);
    _collectionView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), ((_model.count + 3) / 4) * CGRectGetWidth(self.view.frame));
    
    [_collectionView registerNib:[UINib nibWithNibName:@"PhotoPickerCell" bundle:nil] forCellWithReuseIdentifier:@"PhotoPickerCell"];
    
    [self.view addSubview:_collectionView];
}

- (void)configBottomToolBar {
    AlbumNavigationController *navigation = (AlbumNavigationController *)self.navigationController;
    self.toolBarView = [[PhotoToolBarView alloc] initWithNavigation:navigation selectedPhotoArray:self.pickerModelArray photoArray:self.pickerModelArray isHavePreviewPhotoButton:YES];
    
    [self.toolBarView.previewButton addTarget:self action:@selector(previewButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.toolBarView.originalPhotoButton addTarget:self action:@selector(originalPhotoButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.toolBarView.okButton addTarget:self action:@selector(okButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_toolBarView];
}

#pragma mark - 视图将要出现 消失
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_shouldScrollToBottom && _photoArr.count > 0) {
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:(_photoArr.count - 1) inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
        _shouldScrollToBottom = NO;
    }
    // Determine the size of the thumbnails to request from the PHCachingImageManager
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize cellSize = ((UICollectionViewFlowLayout *)_collectionView.collectionViewLayout).itemSize;
    AssetGridThumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (iOS8Later) {
        // [self updateCachedAssets];
    }
}

#pragma mark - 点击事件
- (void)cancel {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    AlbumNavigationController *navigation = (AlbumNavigationController *)self.navigationController;
    if ([navigation.pickerDelegate respondsToSelector:@selector(albumNavigationControllerDidCancel:)]) {
        [navigation.pickerDelegate albumNavigationControllerDidCancel:navigation];
    }
    if (navigation.albumNavigationControllerDidCancelHandle) {
        navigation.albumNavigationControllerDidCancelHandle();
    }
}

- (void)previewButtonClick {
    PhotoPreviewController *photoPreviewVc = [[PhotoPreviewController alloc] init];
    photoPreviewVc.photoArray = [NSArray arrayWithArray:self.pickerModelArray];
    [self pushPhotoPrevireViewController:photoPreviewVc];
}

- (void)originalPhotoButtonClick {
     _toolBarView.originalPhotoButton.selected = !_toolBarView.originalPhotoButton.isSelected;
     _isSelectOriginalPhoto = _toolBarView.originalPhotoButton.isSelected;
     _toolBarView.originalPhotoLable.hidden = !_toolBarView.originalPhotoButton.isSelected;
    
    if (_isSelectOriginalPhoto) {
        [self getSelectedPhotoBytes];
    }
}

- (void)okButtonClick {
    AlbumNavigationController *navigation = (AlbumNavigationController *)self.navigationController;
    [navigation showProgressHUD];

    __block NSMutableArray *photos = [NSMutableArray array];
    __block  NSMutableArray *assets = [NSMutableArray array];
    __block  NSMutableArray *infoArr = [NSMutableArray array];
    __block NSMutableArray *indexArray = [NSMutableArray array];
    __block NSInteger loopCount = 0;
    
    for (NSInteger i = 0; i < self.pickerModelArray.count; i++) {
        PhotoPickerModel *model = self.pickerModelArray[i];
        [[AlbumDataHandle manager] getPhotoWithAsset:model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            if (isDegraded) {
                return;
            }
            if (photo) {
                if (_isSelectOriginalPhoto) {
                    [photos addObject:photo];
                    [assets addObject:model.asset];
                } else {
                    NSData *decData = UIImageJPEGRepresentation(photo, 0.5);
                    UIImage *thumbImage = [UIImage imageWithData:decData];
                    [photos addObject:thumbImage];
                    [assets removeAllObjects];
                }
            }
            
            if (info) {
                [infoArr addObject:info];
            }
            [indexArray addObject:[NSString stringWithFormat:@"%ld", i]];
            loopCount++;
            if (loopCount == self.pickerModelArray.count) {
                for (int m = 0; m < indexArray.count - 1; m++) {
                    for (int n = m + 1; n < indexArray.count; n++) {
                        if (indexArray[m] > indexArray[n]) {
                            UIImage *temImage = photos[n];
                            photos[n] = photos[m];
                            photos[m] = temImage;
                            
                            NSString *str = indexArray[n];
                            indexArray[n] = indexArray[m];
                            indexArray[m] = str;
                            
                        }
                    }
                }
                if ([navigation.pickerDelegate respondsToSelector:@selector(albumNavigationController:didFinishPickingPhotos:sourceAssets:)]) {
                    [navigation.pickerDelegate albumNavigationController:navigation didFinishPickingPhotos:photos sourceAssets:assets];
                    [photos removeAllObjects];
                }
                if ([navigation.pickerDelegate respondsToSelector:@selector(albumNavigationController:didFinishPickingPhotos:sourceAssets:infos:)]) {
                    [navigation.pickerDelegate albumNavigationController:navigation didFinishPickingPhotos:photos sourceAssets:assets infos:infoArr];
                }
                if (navigation.didFinishPickingPhotosHandle) {
                    navigation.didFinishPickingPhotosHandle(photos, assets);
                }
                if (navigation.didFinishPickingPhotosWithInfosHandle) {
                    navigation.didFinishPickingPhotosWithInfosHandle(photos, assets, infoArr);
                }
                [navigation hideProgressHUD];
            }
        }];
    }
}

#pragma mark - UICollectionViewDataSource && Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _photoArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoPickerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoPickerCell" forIndexPath:indexPath];
    PhotoPickerModel *model = _photoArr[indexPath.row];
    cell.model = model;
    
    __weak typeof(cell) weakCell = cell;
    __weak typeof(self) weakSelf = self;
    __weak typeof(_toolBarView.numberLable.layer) weakLayer = _toolBarView.numberLable.layer;
    cell.didSelectPhotoBlock = ^(BOOL isSelected) {
        // 1. cancel select / 取消选择
        if (isSelected) {
            weakCell.selectPhotoButton.selected = NO;
            model.isSelected = NO;
            [weakSelf.pickerModelArray removeObject:model];
            [weakSelf refreshBottomToolBarStatus];
        } else {
            // 2. select:check if over the maxImagesCount / 选择照片,检查是否超过了最大个数的限制
            AlbumNavigationController *navigation = (AlbumNavigationController *)weakSelf.navigationController;
            if (weakSelf.pickerModelArray.count < navigation.maxImagesCount) {
                weakCell.selectPhotoButton.selected = YES;
                model.isSelected = YES;
                [weakSelf.pickerModelArray addObject:model];
                [weakSelf refreshBottomToolBarStatus];
            } else {
                [navigation showAlertWithTitle:[NSString stringWithFormat:@"你最多只能选择%zd张照片",navigation.maxImagesCount]];
            }
        }
         [self showOscillatoryAnimationWithLayer:weakLayer big:NO];
    };
    return cell;
}

- (void)showOscillatoryAnimationWithLayer:(CALayer *)layer big:(BOOL)big {
    NSNumber *animationScale1 = big == 0 ? @(1.15) : @(0.5);
    NSNumber *animationScale2 = big == 0 ? @(0.92) : @(1.15);
    
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoPickerModel *model = _photoArr[indexPath.row];
    if (model.type == AlbumModelMediaTypeVideo) {
        if (self.pickerModelArray.count > 0) {
            AlbumNavigationController *navigation = (AlbumNavigationController *)self.navigationController;
            [navigation showAlertWithTitle:@"选择照片时不能选择视频"];
        } else {
            VideoPlayerController *videoPlayerVc = [[VideoPlayerController alloc] init];
            videoPlayerVc.model = model;
            [self.navigationController pushViewController:videoPlayerVc animated:YES];
        }
    } else {
        PhotoPreviewController *photoPreviewVc = [[PhotoPreviewController alloc] init];
        photoPreviewVc.photoArray = _photoArr;
        photoPreviewVc.currentIndex = indexPath.row;
        [self pushPhotoPrevireViewController:photoPreviewVc];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (iOS8Later) {
        // [self updateCachedAssets];
    }
}

#pragma mark - Private Method
- (void)refreshBottomToolBarStatus {
    _toolBarView.previewButton.enabled = self.pickerModelArray.count > 0;
    _toolBarView.okButton.enabled = self.pickerModelArray.count > 0;
    
    _toolBarView.numberLable.hidden = self.pickerModelArray.count <= 0;
    _toolBarView.numberLable.text = [NSString stringWithFormat:@"%zd", self.pickerModelArray.count];
    
    _toolBarView.originalPhotoButton.enabled = self.pickerModelArray.count > 0;
    _toolBarView.originalPhotoButton.selected = (_isSelectOriginalPhoto && _toolBarView.originalPhotoButton.enabled);
    _toolBarView.originalPhotoLable.hidden = (!_toolBarView.originalPhotoButton.isSelected);
    if (_isSelectOriginalPhoto) {
        [self getSelectedPhotoBytes];
    }
}

- (void)pushPhotoPrevireViewController:(PhotoPreviewController *)photoPreviewVc {
    photoPreviewVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;
    photoPreviewVc.selectedPhotoArray = self.pickerModelArray;
    
    photoPreviewVc.returnNewSelectedPhotoArrBlock = ^(NSMutableArray *newSelectedPhotoArr, BOOL isSelectOriginalPhoto) {
        self.pickerModelArray = newSelectedPhotoArr;
        self.isSelectOriginalPhoto = isSelectOriginalPhoto;
        [self.collectionView reloadData];
        [self refreshBottomToolBarStatus];
    };
    photoPreviewVc.okButtonClickBlock = ^(NSMutableArray *newSelectedPhotoArr, BOOL isSelectOriginalPhoto){
        if (newSelectedPhotoArr.count != 0) {
            self.pickerModelArray = newSelectedPhotoArr;
            self.isSelectOriginalPhoto = isSelectOriginalPhoto;
            [self okButtonClick];
        }
    };
    [self.navigationController pushViewController:photoPreviewVc animated:YES];
}

- (void)getSelectedPhotoBytes {
    [[AlbumDataHandle manager] getPhotoBytesWithPhotoArray:self.pickerModelArray completion:^(NSString *totalBytes) {
        _toolBarView.originalPhotoLable.text = [NSString stringWithFormat:@"(%@)",totalBytes];
    }];
}

#pragma mark - Asset Caching
- (void)resetCachedAssets {
    [[AlbumDataHandle manager].cachingImageManager stopCachingImagesForAllAssets];
    self.previousPreheatRect = CGRectZero;
}

- (void)updateCachedAssets {
    BOOL isViewVisible = [self isViewLoaded] && [[self view] window] != nil;
    if (!isViewVisible) {
        return;
    }
    
    // The preheat window is twice the height of the visible rect.
    CGRect preheatRect = _collectionView.bounds;
    preheatRect = CGRectInset(preheatRect, 0.0f, -0.5f * CGRectGetHeight(preheatRect));
    
    /*
     Check if the collection view is showing an area that is significantly
     different to the last preheated area.
     */
    CGFloat delta = ABS(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
    if (delta > CGRectGetHeight(_collectionView.bounds) / 3.0f) {
        
        // Compute the assets to start caching and to stop caching.
        NSMutableArray *addedIndexPaths = [NSMutableArray array];
        NSMutableArray *removedIndexPaths = [NSMutableArray array];
        
        [self computeDifferenceBetweenRect:self.previousPreheatRect andRect:preheatRect removedHandler:^(CGRect removedRect) {
            NSArray *indexPaths = [self aapl_indexPathsForElementsInRect:removedRect];
            [removedIndexPaths addObjectsFromArray:indexPaths];
        } addedHandler:^(CGRect addedRect) {
            NSArray *indexPaths = [self aapl_indexPathsForElementsInRect:addedRect];
            [addedIndexPaths addObjectsFromArray:indexPaths];
        }];
        
        NSArray *assetsToStartCaching = [self assetsAtIndexPaths:addedIndexPaths];
        NSArray *assetsToStopCaching = [self assetsAtIndexPaths:removedIndexPaths];
        
        // Update the assets the PHCachingImageManager is caching.
        [[AlbumDataHandle manager].cachingImageManager startCachingImagesForAssets:assetsToStartCaching targetSize:AssetGridThumbnailSize contentMode:PHImageContentModeAspectFill options:nil];
        [[AlbumDataHandle manager].cachingImageManager stopCachingImagesForAssets:assetsToStopCaching targetSize:AssetGridThumbnailSize contentMode:PHImageContentModeAspectFill options:nil];
        
        // Store the preheat rect to compare against in the future.
        self.previousPreheatRect = preheatRect;
    }
}

- (void)computeDifferenceBetweenRect:(CGRect)oldRect andRect:(CGRect)newRect removedHandler:(void (^)(CGRect removedRect))removedHandler addedHandler:(void (^)(CGRect addedRect))addedHandler {
    if (CGRectIntersectsRect(newRect, oldRect)) {
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        
        if (newMaxY > oldMaxY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }
        
        if (oldMinY > newMinY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }
        
        if (newMaxY < oldMaxY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }
        
        if (oldMinY < newMinY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
    } else {
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}

- (NSArray *)assetsAtIndexPaths:(NSArray *)indexPaths {
    if (indexPaths.count == 0) { return nil; }
    
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for (NSIndexPath *indexPath in indexPaths) {
        PhotoPickerModel *model = _photoArr[indexPath.item];
        [assets addObject:model.asset];
    }
    
    return assets;
}

- (NSArray *)aapl_indexPathsForElementsInRect:(CGRect)rect {
    NSArray *allLayoutAttributes = [_collectionView.collectionViewLayout layoutAttributesForElementsInRect:rect];
    if (allLayoutAttributes.count == 0) { return nil; }
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:allLayoutAttributes.count];
    for (UICollectionViewLayoutAttributes *layoutAttributes in allLayoutAttributes) {
        NSIndexPath *indexPath = layoutAttributes.indexPath;
        [indexPaths addObject:indexPath];
    }
    return indexPaths;
}

@end
