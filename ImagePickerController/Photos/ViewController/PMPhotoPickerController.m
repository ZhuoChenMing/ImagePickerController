//
//  PMPhotoPickerController.m
//  ImagePickerController
//
//  Created by 酌晨茗 on 15/12/24.
//  Copyright © 2015年 酌晨茗. All rights reserved.
//

#import "PMPhotoPickerController.h"
#import "PMPhotoPickerCell.h"
//view
#import "PMPhotoToolBarView.h"
#import "PMPhotoInfoModel.h"

#import "PMAlbumViewController.h"
#import "PMAlbumInfoModel.h"

#import "PMPhotoController.h"
#import "PMDataManager.h"
#import "PMVideoPlayerController.h"

@interface PMPhotoPickerController ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *photoArray;

@property (nonatomic, strong) PMPhotoToolBarView *toolBarView;

@property (nonatomic, assign) BOOL isSelectOriginalPhoto;
@property (nonatomic, assign) BOOL shouldScrollToBottom;

@property (nonatomic, strong) NSMutableArray *pickerModelArray;

@property (nonatomic, assign) CGRect previousPreheatRect;

@end

static CGSize kAssetGridThumbnailSize;

@implementation PMPhotoPickerController

- (NSMutableArray *)pickerModelArray {
    if (_pickerModelArray == nil) {
        _pickerModelArray = [NSMutableArray array];
    }
    return _pickerModelArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.title = _model.name;
    self.shouldScrollToBottom = YES;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat margin = 4;
    CGFloat itemWH = (CGRectGetWidth(self.view.frame) - 2 * margin - 4) / 4 - margin;
    layout.itemSize = CGSizeMake(itemWH, itemWH);
    layout.minimumInteritemSpacing = margin;
    layout.minimumLineSpacing = margin;
    CGFloat top = margin + 44;
    if (iOS7Later) {
        top += 20;
    }
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(margin, top, CGRectGetWidth(self.view.frame) - 2 * margin, CGRectGetHeight(self.view.frame)- 50 - top) collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.alwaysBounceHorizontal = NO;
    if (iOS7Later) {
        self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 2);
    }
    self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, -2);
    self.collectionView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), ((_model.count + 3) / 4) * CGRectGetWidth(self.view.frame));
    [self.collectionView registerNib:[UINib nibWithNibName:@"PMPhotoPickerCell" bundle:nil] forCellWithReuseIdentifier:@"PMPhotoPickerCell"];
    [self.view addSubview:_collectionView];
    
    //工具栏
    PMNavigationController *navigation = (PMNavigationController *)self.navigationController;
    self.toolBarView = [[PMPhotoToolBarView alloc] initWithNavigation:navigation selectedPhotoArray:self.pickerModelArray photoArray:self.pickerModelArray isHavePreviewPhotoButton:YES];
    
    [self.toolBarView.previewButton addTarget:self action:@selector(previewButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.toolBarView.originalPhotoButton addTarget:self action:@selector(originalPhotoButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.toolBarView.okButton addTarget:self action:@selector(okButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_toolBarView];
    
    [navigation showProgressHUD];
    [[PMDataManager manager] getAssetsFromFetchResult:_model.result canPickVideo:navigation.canPickVideo completion:^(NSArray<PMPhotoInfoModel *> *models) {
        self.photoArray = [NSMutableArray arrayWithArray:models];
        [self.collectionView reloadData];
        [navigation hideProgressHUD];
    }];
    [self resetCachedAssets];
}

#pragma mark - 视图将要出现 消失
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_shouldScrollToBottom && _photoArray.count > 0) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:(_photoArray.count - 1) inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
        self.shouldScrollToBottom = NO;
    }
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize cellSize = ((UICollectionViewFlowLayout *)_collectionView.collectionViewLayout).itemSize;
    kAssetGridThumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);
}

#pragma mark - 点击事件
- (void)cancel {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    PMNavigationController *navigation = (PMNavigationController *)self.navigationController;
    if ([navigation.pickerDelegate respondsToSelector:@selector(navigationControllerDidCancel:)]) {
        [navigation.pickerDelegate navigationControllerDidCancel:navigation];
    }
    if (navigation.didCancelHandle) {
        navigation.didCancelHandle();
    }
}

- (void)previewButtonClick {
    PMPhotoController *photoPreviewVc = [[PMPhotoController alloc] init];
    photoPreviewVc.photoArray = [NSArray arrayWithArray:self.pickerModelArray];
    [self pushPhotoPrevireViewController:photoPreviewVc];
}

- (void)originalPhotoButtonClick {
    self.toolBarView.originalPhotoButton.selected = !_toolBarView.originalPhotoButton.isSelected;
    self.isSelectOriginalPhoto = _toolBarView.originalPhotoButton.isSelected;
    self.toolBarView.originalPhotoLabel.hidden = !_toolBarView.originalPhotoButton.isSelected;
    
    if (_isSelectOriginalPhoto) {
        [self getSelectedPhotoBytes];
    }
}

- (void)okButtonClick {
    PMNavigationController *navigation = (PMNavigationController *)self.navigationController;
    [navigation showProgressHUD];
    
    NSMutableArray *photoArray = [NSMutableArray array];
    NSMutableArray *assetArray = [NSMutableArray array];
    NSMutableArray *infoArray = [NSMutableArray array];
    
    for (NSInteger i = 0; i < _pickerModelArray.count; i++) {
        PMPhotoInfoModel *model = _pickerModelArray[i];
        if (model.image) {
            [assetArray addObject:model.asset];
            
            if (self.isSelectOriginalPhoto) {
                [photoArray addObject:model.image];
            } else {
                NSData *decData = UIImageJPEGRepresentation(model.image, 0.5);
                UIImage *thumbImage = [UIImage imageWithData:decData];
                [photoArray addObject:thumbImage];
            }
            if (model.info) {
                [infoArray addObject:model.info];
            } else {
                [infoArray addObject:@{}];
            }
        }
    }
    if ([navigation.pickerDelegate respondsToSelector:@selector(navigationController:didFinishPickingPhotos:sourceAssets:)]) {
        [navigation.pickerDelegate navigationController:navigation didFinishPickingPhotos:photoArray sourceAssets:assetArray];
    }
    if ([navigation.pickerDelegate respondsToSelector:@selector(navigationController:didFinishPickingPhotos:sourceAssets:infos:)]) {
        [navigation.pickerDelegate navigationController:navigation didFinishPickingPhotos:photoArray sourceAssets:assetArray infos:infoArray];
    }
    if (navigation.didFinishPickingPhotosHandle) {
        navigation.didFinishPickingPhotosHandle(photoArray, assetArray);
    }
    if (navigation.didFinishPickingPhotosWithInfosHandle) {
        navigation.didFinishPickingPhotosWithInfosHandle(photoArray, assetArray, infoArray);
    }
    [navigation hideProgressHUD];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UICollection代理
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _photoArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PMPhotoPickerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PMPhotoPickerCell" forIndexPath:indexPath];
    PMPhotoInfoModel *model = _photoArray[indexPath.row];
    cell.model = model;
    
    __weak typeof(cell) weakCell = cell;
    __weak typeof(self) weakSelf = self;
    __weak typeof(_toolBarView.numberLabel.layer) weakLayer = _toolBarView.numberLabel.layer;
    cell.didSelectPhotoBlock = ^(BOOL isSelected) {
        //取消选择
        if (isSelected) {
            weakCell.selectPhotoButton.selected = NO;
            model.isSelected = NO;
            [weakSelf.pickerModelArray removeObject:model];
            [weakSelf refreshBottomToolBarStatus];
        } else {
            //选择照片,检查是否超过了最大个数的限制
            PMNavigationController *navigation = (PMNavigationController *)weakSelf.navigationController;
            if (weakSelf.pickerModelArray.count < navigation.maxImageCount) {
                weakCell.selectPhotoButton.selected = YES;
                model.isSelected = YES;
                
                //获取照片原图及照片信息
                [[PMDataManager manager] getPhotoWithAsset:model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                    if (isDegraded) {
                        return;
                    }
                    model.image = photo;
                    if (info) {
                        model.info = [NSDictionary dictionaryWithDictionary:info];
                    }
                }];
                
                [weakSelf.pickerModelArray addObject:model];
                [weakSelf refreshBottomToolBarStatus];
            } else {
                [navigation showAlertWithTitle:[NSString stringWithFormat:@"你最多只能选择%zd张照片", navigation.maxImageCount]];
            }
        }
        [weakSelf showOscillatoryAnimationWithLayer:weakLayer big:NO];
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
    PMPhotoInfoModel *model = _photoArray[indexPath.row];
    if (model.type == PMPhotoTypeVideo) {
        if (self.pickerModelArray.count > 0) {
            PMNavigationController *navigation = (PMNavigationController *)self.navigationController;
            [navigation showAlertWithTitle:@"选择照片时不能选择视频"];
        } else {
            PMVideoPlayerController *videoPlayerVc = [[PMVideoPlayerController alloc] init];
            videoPlayerVc.model = model;
            [self.navigationController pushViewController:videoPlayerVc animated:YES];
        }
    } else {
        PMPhotoController *photoPreviewVc = [[PMPhotoController alloc] init];
        photoPreviewVc.photoArray = _photoArray;
        photoPreviewVc.currentIndex = indexPath.row;
        [self pushPhotoPrevireViewController:photoPreviewVc];
    }
}

#pragma mark - Private Method
- (void)refreshBottomToolBarStatus {
    _toolBarView.previewButton.enabled = self.pickerModelArray.count > 0;
    _toolBarView.okButton.enabled = self.pickerModelArray.count > 0;
    
    _toolBarView.numberLabel.hidden = self.pickerModelArray.count <= 0;
    _toolBarView.numberLabel.text = [NSString stringWithFormat:@"%zd", self.pickerModelArray.count];
    
    _toolBarView.originalPhotoButton.enabled = self.pickerModelArray.count > 0;
    _toolBarView.originalPhotoButton.selected = (_isSelectOriginalPhoto && _toolBarView.originalPhotoButton.enabled);
    _toolBarView.originalPhotoLabel.hidden = (!_toolBarView.originalPhotoButton.isSelected);
    if (_isSelectOriginalPhoto) {
        [self getSelectedPhotoBytes];
    }
}

- (void)pushPhotoPrevireViewController:(PMPhotoController *)photoPreviewVc {
    photoPreviewVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;
    photoPreviewVc.selectedPhotoArray = self.pickerModelArray;
    
    __weak typeof(self) weakSelf = self;
    photoPreviewVc.returnNewSelectedPhotoArrBlock = ^(NSMutableArray *newSelectedPhotoArr, BOOL isSelectOriginalPhoto) {
        weakSelf.pickerModelArray = newSelectedPhotoArr;
        weakSelf.isSelectOriginalPhoto = isSelectOriginalPhoto;
        [weakSelf.collectionView reloadData];
        [weakSelf refreshBottomToolBarStatus];
    };
    photoPreviewVc.okButtonClickBlock = ^(NSMutableArray *newSelectedPhotoArr, BOOL isSelectOriginalPhoto) {
        if (newSelectedPhotoArr.count != 0) {
            weakSelf.pickerModelArray = newSelectedPhotoArr;
            weakSelf.isSelectOriginalPhoto = isSelectOriginalPhoto;
            [weakSelf okButtonClick];
        }
    };
    [self.navigationController pushViewController:photoPreviewVc animated:YES];
}

- (void)getSelectedPhotoBytes {
    [[PMDataManager manager] getPhotoBytesWithPhotoArray:self.pickerModelArray completion:^(NSString *totalBytes) {
        self.toolBarView.originalPhotoLabel.text = [NSString stringWithFormat:@"(%@)", totalBytes];
    }];
}

#pragma mark - Asset Caching
- (void)resetCachedAssets {
    [[PMDataManager manager].cachingImageManager stopCachingImagesForAllAssets];
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
        
        __weak typeof(self) weakSelf = self;
        [self computeDifferenceBetweenRect:self.previousPreheatRect andRect:preheatRect removedHandler:^(CGRect removedRect) {
            NSArray *indexPaths = [weakSelf aapl_indexPathsForElementsInRect:removedRect];
            [removedIndexPaths addObjectsFromArray:indexPaths];
        } addedHandler:^(CGRect addedRect) {
            NSArray *indexPaths = [weakSelf aapl_indexPathsForElementsInRect:addedRect];
            [addedIndexPaths addObjectsFromArray:indexPaths];
        }];
        
        NSArray *assetsToStartCaching = [self assetsAtIndexPaths:addedIndexPaths];
        NSArray *assetsToStopCaching = [self assetsAtIndexPaths:removedIndexPaths];
        
        // Update the assets the PHCachingImageManager is caching.
        [[PMDataManager manager].cachingImageManager startCachingImagesForAssets:assetsToStartCaching targetSize:kAssetGridThumbnailSize contentMode:PHImageContentModeAspectFill options:nil];
        [[PMDataManager manager].cachingImageManager stopCachingImagesForAssets:assetsToStopCaching targetSize:kAssetGridThumbnailSize contentMode:PHImageContentModeAspectFill options:nil];
        
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
        PMPhotoInfoModel *model = _photoArray[indexPath.item];
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
