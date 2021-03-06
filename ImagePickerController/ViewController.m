//
//  ViewController.m
//  PMAlbumViewController
//
//  Created by 酌晨茗 on 15/12/24.
//  Copyright © 2015年 酌晨茗. All rights reserved.
//

#import "ViewController.h"
#import "PMNavigationController.h"
#import "AddCollectionViewCell.h"

@interface ViewController ()<PMNavigationControllerDelegate, UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *selectedPhotos;

@property (nonatomic, strong) NSMutableArray *selectedAssets;

@property (nonatomic, assign) CGFloat itemWH;

@property (nonatomic, assign) CGFloat margin;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"清理" style:UIBarButtonItemStylePlain target:self action:@selector(cleanAllPhoto)];
    self.navigationItem.rightBarButtonItem = barButton;
    self.selectedPhotos = [NSMutableArray array];
    self.selectedAssets = [NSMutableArray array];
    self.margin = 10;
    self.itemWH = (CGRectGetWidth(self.view.frame) - 2 * _margin - 4) / 3 - _margin;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(_itemWH, _itemWH);
    layout.minimumInteritemSpacing = _margin;
    layout.minimumLineSpacing = _margin;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(_margin, 130, CGRectGetWidth(self.view.frame) - 2 * _margin, CGRectGetHeight(self.view.frame) - 20) collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.contentInset = UIEdgeInsetsMake(4, 0, 0, 2);
    self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, -2);
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[AddCollectionViewCell class] forCellWithReuseIdentifier:@"AddCollectionViewCell"];
    [self.view addSubview:_collectionView];
}

- (void)cleanAllPhoto {
    [self.selectedPhotos removeAllObjects];
    [self.collectionView reloadData];
}

#pragma mark - UICollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _selectedPhotos.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AddCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AddCollectionViewCell" forIndexPath:indexPath];
    if (indexPath.row == _selectedPhotos.count) {
        cell.imageView.image = [UIImage imageNamed:@"AlbumAddBtn"];
    } else {
        cell.imageView.image = _selectedPhotos[indexPath.row];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == _selectedPhotos.count) {
        [self pickPhotoButtonClick:nil];
    }
}

- (NSString *)getBytesFromDataLength:(NSInteger)dataLength {
    NSString *bytes;
    if (dataLength >= 0.1 * (1024 * 1024)) {
        bytes = [NSString stringWithFormat:@"%0.1fM", dataLength / 1024 / 1024.0];
    } else if (dataLength >= 1024) {
        bytes = [NSString stringWithFormat:@"%0.0fK", dataLength / 1024.0];
    } else {
        bytes = [NSString stringWithFormat:@"%zdB", dataLength];
    }
    return bytes;
}

#pragma mark Click Event
- (void)pickPhotoButtonClick:(UIButton *)sender {
    PMNavigationController *navigation = [[PMNavigationController alloc] initWithMaxImageCount:0 delegate:self];
    dispatch_queue_t queue = dispatch_queue_create("chuan", DISPATCH_QUEUE_SERIAL);
    // 你可以通过block或者代理，来得到用户选择的照片.
    __weak typeof(self) weakSelf = self;
    [navigation setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets) {
        dispatch_async(queue, ^{
            for (UIImage *image in photos) {
                //如果返回的图片还是太大 可以这样压缩
                NSData *data = UIImageJPEGRepresentation(image, 0.5);
                NSData *oriData = UIImageJPEGRepresentation(image, 1);
                NSLog(@"%@, %@", [weakSelf getBytesFromDataLength:data.length], [weakSelf getBytesFromDataLength:oriData.length]);
            }
        });
    }];
    
    // 在这里设置imagePickerVc的外观
    // imagePickerVc.navigationBar.barTintColor = [UIColor greenColor];
    // imagePickerVc.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
    // imagePickerVc.oKButtonTitleColorNormal = [UIColor greenColor];
    
    // 设置是否可以选择视频/原图
    // imagePickerVc.canPickVideo = NO;
    // imagePickerVc.canPickOriginalPhoto = NO;
    navigation.modalPresentationStyle = 0;
    [self presentViewController:navigation animated:YES completion:nil];
}

#pragma mark - 用户点击了取消
- (void)navigationControllerDidCancel:(PMNavigationController *)picker {
    // NSLog(@"cancel");
}

//用户选择好了图片，如果assets非空，则用户选择了原图。
- (void)navigationController:(PMNavigationController *)picker didFinishPickingPhotos:(NSArray *)photos sourceAssets:(NSArray *)assets {
    
    NSMutableArray *imageArray = [NSMutableArray array];
    for (int i = 0; i < photos.count; i++) {
        UIImage *temImage = photos[i];
        NSData *data = UIImageJPEGRepresentation(temImage, 0.1);
        [imageArray addObject:[UIImage imageWithData:data]];
    }
    
    [self.selectedPhotos addObjectsFromArray:imageArray];
    [self.collectionView reloadData];
    self.collectionView.contentSize = CGSizeMake(0, ((_selectedPhotos.count + 2) / 3 ) * (_margin + _itemWH));
}

//用户选择好了视频
- (void)navigationController:(PMNavigationController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(id)asset {
    [self.selectedPhotos addObjectsFromArray:@[coverImage]];
    [self.collectionView reloadData];
    self.collectionView.contentSize = CGSizeMake(0, ((_selectedPhotos.count + 2) / 3 ) * (_margin + _itemWH));
}

@end
