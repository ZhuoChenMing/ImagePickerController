//
//  PMDataManager.m
//  ImagePickerController
//
//  Created by 酌晨茗 on 16/1/4.
//  Copyright © 2016年 酌晨茗. All rights reserved.
//

#import "PMDataManager.h"
//AssetsLibrary框架用于访问所有相片
#import <AssetsLibrary/AssetsLibrary.h>
#import "PMAlbumViewController.h"

#import "PMAlbumInfoModel.h"
#import "PMPhotoInfoModel.h"

@interface PMDataManager ()

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@property (nonatomic, strong) ALAssetsLibrary *assetLibrary;
#pragma clang diagnostic pop

@end

@implementation PMDataManager

+ (instancetype)manager {
    static PMDataManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        _systemVersion = [UIDevice currentDevice].systemVersion.floatValue;
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            _notchScreen = NO;
        } else {
            if (@available(iOS 11.0, *)) {
                UIWindow *window = [[UIApplication sharedApplication].windows firstObject];
                _notchBottom = window.safeAreaInsets.bottom;
                _notchScreen = _notchBottom > 0;
            }
        }
    }
    return self;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (ALAssetsLibrary *)assetLibrary {
    if (_assetLibrary == nil) {
        _assetLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetLibrary;
}

#pragma mark -  授权
- (BOOL)authorizationStatusAuthorized {
    if (_systemVersion < 8) {
        if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized) {
            return YES;
        }
    } else {
        if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
            return YES;
        }
    }
    return NO;
}

- (void)getAuthorization:(void(^)(BOOL authorized))callback {
    if (_systemVersion < 8) {
        if (callback) {
            if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized) {
                callback(YES);
            } else {
                callback(NO);
            }
        }
    } else {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (callback) {
                    if (status == PHAuthorizationStatusAuthorized) {
                        callback(YES);
                    } else {
                        callback(NO);
                    }
                }
            });
        }];
    }
}

#pragma mark - 获得相册/相册数组
- (void)getCameraRollAlbum:(void (^)(PMAlbumInfoModel *))completion {
    __block PMAlbumInfoModel *model;
    if (_systemVersion < 8) {
        [self.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if ([group numberOfAssets] < 1) return;
            NSString *name = [group valueForProperty:ALAssetsGroupPropertyName];
            if ([name isEqualToString:@"Camera Roll"] || [name isEqualToString:@"相机胶卷"]) {
                model = [self modelWithResult:group name:name];
                if (completion) {
                    completion(model);
                }
                *stop = YES;
            }
        } failureBlock:nil];
    } else {
        PHFetchOptions *option = [[PHFetchOptions alloc] init];
        if (!_canPickVideo) {
            option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
        }
        option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        
        PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
        for (PHAssetCollection *collection in smartAlbums) {
            if ([collection.localizedTitle isEqualToString:@"Camera Roll"] || [collection.localizedTitle isEqualToString:@"相机胶卷"]) {
                PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
                model = [self modelWithResult:fetchResult name:collection.localizedTitle];
                if (completion) completion(model);
                break;
            }
        }
    }
}

- (void)getAlbums:(void (^)(NSArray<PMAlbumInfoModel *> *))completion {
    NSMutableArray *albumArray = [NSMutableArray array];
    
    if (_systemVersion < 8) {
        [self.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (group == nil) {
                if (completion && albumArray.count > 0) completion(albumArray);
            }
            if ([group numberOfAssets] < 1) {
                return;
            }
            NSString *name = [group valueForProperty:ALAssetsGroupPropertyName];
            if ([name isEqualToString:@"Camera Roll"] || [name isEqualToString:@"相机胶卷"]) {
                [albumArray insertObject:[self modelWithResult:group name:name] atIndex:0];
            } else if ([name isEqualToString:@"My Photo Stream"] || [name isEqualToString:@"我的照片流"]) {
                [albumArray insertObject:[self modelWithResult:group name:name] atIndex:1];
            } else {
                [albumArray addObject:[self modelWithResult:group name:name]];
            }
        } failureBlock:nil];
    } else {
        PHFetchOptions *option = [[PHFetchOptions alloc] init];
        if (!_canPickVideo) {
            option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
        }
        option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        
        PHAssetCollectionSubtype smartAlbumSubtype = PHAssetCollectionSubtypeSmartAlbumUserLibrary | PHAssetCollectionSubtypeSmartAlbumRecentlyAdded | PHAssetCollectionSubtypeSmartAlbumVideos;
        if (_systemVersion >= 9) {
            smartAlbumSubtype = PHAssetCollectionSubtypeSmartAlbumUserLibrary | PHAssetCollectionSubtypeSmartAlbumRecentlyAdded | PHAssetCollectionSubtypeSmartAlbumScreenshots | PHAssetCollectionSubtypeSmartAlbumSelfPortraits | PHAssetCollectionSubtypeSmartAlbumVideos;
        }
        PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:smartAlbumSubtype options:nil];
        for (PHAssetCollection *collection in smartAlbums) {
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
            if (fetchResult.count < 1) {
                continue;
            }
            if ([collection.localizedTitle containsString:@"Deleted"] || [collection.localizedTitle isEqualToString:@"最近删除"]) {
                continue;
            }
            if ([collection.localizedTitle isEqualToString:@"Camera Roll"] || [collection.localizedTitle isEqualToString:@"相机胶卷"]) {
                [albumArray insertObject:[self modelWithResult:fetchResult name:collection.localizedTitle] atIndex:0];
            } else {
                [albumArray addObject:[self modelWithResult:fetchResult name:collection.localizedTitle]];
            }
        }
        
        PHFetchResult *albums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular | PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
        for (PHAssetCollection *collection in albums) {
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
            if (fetchResult.count < 1) {
                continue;
            }
            if ([collection.localizedTitle isEqualToString:@"My Photo Stream"] || [collection.localizedTitle isEqualToString:@"我的照片流"]) {
                [albumArray insertObject:[self modelWithResult:fetchResult name:collection.localizedTitle] atIndex:1];
            } else {
                [albumArray addObject:[self modelWithResult:fetchResult name:collection.localizedTitle]];
            }
        }
        if (completion && albumArray.count > 0) completion(albumArray);
    }
}

#pragma mark - 获得照片数组
- (void)getAssetsFromFetchResult:(id)result completion:(void (^)(NSArray<PMPhotoInfoModel *> *))completion {
    CGFloat systemVersion = _systemVersion;
    BOOL canPickVideo = _canPickVideo;
    NSMutableArray *photoArray = [NSMutableArray array];
    if ([result isKindOfClass:[PHFetchResult class]]) {
        PHFetchResult *fetchResult = (PHFetchResult *)result;
        [fetchResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            PHAsset *asset = (PHAsset *)obj;
            PMPhotoType type = PMPhotoTypePhoto;
            if (asset.mediaType == PHAssetMediaTypeVideo) {
                type = PMPhotoTypeVideo;
            } else if (asset.mediaType == PHAssetMediaTypeAudio) {
                type = PMPhotoTypeAudio;
            } else if (asset.mediaType == PHAssetMediaTypeImage) {
                if (systemVersion >= 9.1) {
                    // if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) type = AlbumModelMediaTypeLivePhoto;
                } else {
                    
                }
            }
            if (!canPickVideo && type == PMPhotoTypeVideo) {
                return;
            }
            NSString *timeLength = type == PMPhotoTypeVideo ? [NSString stringWithFormat:@"%0.0f", asset.duration] : @"";
            timeLength = [self getNewTimeFromDurationSecond:timeLength.integerValue];
            [photoArray addObject:[PMPhotoInfoModel modelWithAsset:asset type:type timeLength:timeLength]];
        }];
        if (completion) {
            completion(photoArray);
        }
    } else if ([result isKindOfClass:[ALAssetsGroup class]]) {
        ALAssetsGroup *gruop = (ALAssetsGroup *)result;
        if (!_canPickVideo) {
            [gruop setAssetsFilter:[ALAssetsFilter allPhotos]];
        }
        [gruop enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result == nil) {
                if (completion) {
                    completion(photoArray);
                }
            }
            PMPhotoType type = PMPhotoTypePhoto;
            if (!canPickVideo){
                [photoArray addObject:[PMPhotoInfoModel modelWithAsset:result type:type]];
                return;
            }
            /// Allow picking video
            if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
                type = PMPhotoTypeVideo;
                NSTimeInterval duration = [[result valueForProperty:ALAssetPropertyDuration] integerValue];
                NSString *timeLength = [NSString stringWithFormat:@"%0.0f",duration];
                timeLength = [self getNewTimeFromDurationSecond:timeLength.integerValue];
                [photoArray addObject:[PMPhotoInfoModel modelWithAsset:result type:type timeLength:timeLength]];
            } else {
                [photoArray addObject:[PMPhotoInfoModel modelWithAsset:result type:type]];
            }
        }];
    }
}

#pragma mark - 获得下标为index的单个照片
- (void)getAssetFromFetchResult:(id)result atIndex:(NSInteger)index completion:(void (^)(PMPhotoInfoModel *))completion {
    if ([result isKindOfClass:[PHFetchResult class]]) {
        PHFetchResult *fetchResult = (PHFetchResult *)result;
        PHAsset *asset = fetchResult[index];
        
        PMPhotoType type = PMPhotoTypePhoto;
        if (asset.mediaType == PHAssetMediaTypeVideo) {
            type = PMPhotoTypeVideo;
        } else if (asset.mediaType == PHAssetMediaTypeAudio) {
            type = PMPhotoTypeAudio;
        } else if (asset.mediaType == PHAssetMediaTypeImage) {
            if (_systemVersion >= 9.1) {
                // if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) type = AlbumModelMediaTypeLivePhoto;
            } else {
                
            }
        }
        NSString *timeLength = type == PMPhotoTypeVideo ? [NSString stringWithFormat:@"%0.0f", asset.duration] : @"";
        timeLength = [self getNewTimeFromDurationSecond:timeLength.integerValue];
        PMPhotoInfoModel *model = [PMPhotoInfoModel modelWithAsset:asset type:type timeLength:timeLength];
        if (completion) {
            completion(model);
        }
    } else if ([result isKindOfClass:[ALAssetsGroup class]]) {
        ALAssetsGroup *gruop = (ALAssetsGroup *)result;
        if (!_canPickVideo) {
            [gruop setAssetsFilter:[ALAssetsFilter allPhotos]];
        }
        BOOL canPickVideo = _canPickVideo;
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:index];
        [gruop enumerateAssetsAtIndexes:indexSet options:NSEnumerationConcurrent usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            PMPhotoInfoModel *model;
            PMPhotoType type = PMPhotoTypePhoto;
            if (!canPickVideo) {
                model = [PMPhotoInfoModel modelWithAsset:result type:type];
                if (completion) {
                    completion(model);
                }
                return;
            }
            /// Allow picking video
            if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
                type = PMPhotoTypeVideo;
                NSTimeInterval duration = [[result valueForProperty:ALAssetPropertyDuration] integerValue];
                NSString *timeLength = [NSString stringWithFormat:@"%0.0f",duration];
                timeLength = [self getNewTimeFromDurationSecond:timeLength.integerValue];
                model = [PMPhotoInfoModel modelWithAsset:result type:type timeLength:timeLength];
            } else {
                model = [PMPhotoInfoModel modelWithAsset:result type:type];
            }
            if (completion) {
                completion(model);
            }
        }];
    }
}

- (NSString *)getNewTimeFromDurationSecond:(NSInteger)duration {
    NSString *newTime;
    if (duration < 10) {
        newTime = [NSString stringWithFormat:@"0:0%zd",duration];
    } else if (duration < 60) {
        newTime = [NSString stringWithFormat:@"0:%zd",duration];
    } else {
        NSInteger min = duration / 60;
        NSInteger sec = duration - (min * 60);
        if (sec < 10) {
            newTime = [NSString stringWithFormat:@"%zd:0%zd", min, sec];
        } else {
            newTime = [NSString stringWithFormat:@"%zd:%zd", min, sec];
        }
    }
    return newTime;
}

#pragma mark - 获得照片
- (void)getPhotoWithAsset:(id)asset completion:(void (^)(UIImage *, NSDictionary *, BOOL isDegraded))completion {
    [self getPhotoWithAsset:asset photoWidth:[UIScreen mainScreen].bounds.size.width completion:completion];
}

- (void)getPhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *, NSDictionary *, BOOL isDegraded))completion {
    if (photoWidth > [UIScreen mainScreen].bounds.size.width) {
        photoWidth = [UIScreen mainScreen].bounds.size.width;
    }
    if ([asset isKindOfClass:[PHAsset class]]) {
        PHAsset *phAsset = (PHAsset *)asset;
        CGFloat aspectRatio = phAsset.pixelWidth / (CGFloat)phAsset.pixelHeight;
        CGFloat multiple = [UIScreen mainScreen].scale;
        CGFloat pixelWidth = photoWidth * multiple;
        CGFloat pixelHeight = pixelWidth / aspectRatio;
        
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(pixelWidth, pixelHeight) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
            if (downloadFinined && result) {
                if (completion) {
                    completion(result, info, [[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
                }
            }
            //从iCloud下载图片
            if ([info objectForKey:PHImageResultIsInCloudKey] && !result) {
                PHImageRequestOptions *option = [[PHImageRequestOptions alloc]init];
                option.networkAccessAllowed = YES;
                [[PHImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                    UIImage *resultImage = [UIImage imageWithData:imageData scale:0.1];
                    resultImage = [self scaleImage:resultImage toSize:CGSizeMake(pixelWidth, pixelHeight)];
                    
                    if (resultImage) {
                        if (completion) {
                            completion(resultImage, info, [[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
                        }
                    }
                }];
            }
        }];
    } else if ([asset isKindOfClass:[ALAsset class]]) {
        ALAsset *alAsset = (ALAsset *)asset;
        CGImageRef thumbnailImageRef = alAsset.aspectRatioThumbnail;
        UIImage *thumbnailImage = [UIImage imageWithCGImage:thumbnailImageRef scale:1.0 orientation:UIImageOrientationUp];
        if (completion) {
            completion(thumbnailImage, nil, YES);
        }
        
        if (photoWidth == [UIScreen mainScreen].bounds.size.width) {
            ALAssetRepresentation *assetRep = [alAsset defaultRepresentation];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                CGImageRef fullScrennImageRef = [assetRep fullScreenImage];
                UIImage *fullScrennImage = [UIImage imageWithCGImage:fullScrennImageRef scale:1.0 orientation:UIImageOrientationUp];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) {
                        completion(fullScrennImage, nil, NO);
                    }
                });
            });
            
            //            CGImageRef fullScrennImageRef = [assetRep fullScreenImage];
            //            UIImage *fullScrennImage = [UIImage imageWithCGImage:fullScrennImageRef scale:1.0 orientation:UIImageOrientationUp];
            //            if (completion) {
            //                completion(fullScrennImage, nil, NO);
            //            }
        }
    }
}

//获取原图
- (void)getOriginalPhotoWithAsset:(id)asset completion:(void (^)(UIImage *photo, NSDictionary *info))completion {
    if ([asset isKindOfClass:[PHAsset class]]) {
        PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
        option.networkAccessAllowed = YES;
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
            if (downloadFinined && result) {
                if (completion) {
                    completion(result, info);
                }
            }
        }];
    } else if ([asset isKindOfClass:[ALAsset class]]) {
        ALAsset *alAsset = (ALAsset *)asset;
        ALAssetRepresentation *assetRep = [alAsset defaultRepresentation];
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            CGImageRef originalImageRef = [assetRep fullResolutionImage];
            UIImage *originalImage = [UIImage imageWithCGImage:originalImageRef scale:1.0 orientation:UIImageOrientationUp];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(originalImage, nil);
                }
            });
        });
    }
}

#pragma mark - Get Video
- (void)getVideoWithAsset:(id)asset completion:(void (^)(AVPlayerItem * _Nullable, NSDictionary * _Nullable))completion {
    if ([asset isKindOfClass:[PHAsset class]]) {
        [[PHImageManager defaultManager] requestPlayerItemForVideo:asset options:nil resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
            if (completion) {
                completion(playerItem, info);
            }
        }];
    } else if ([asset isKindOfClass:[ALAsset class]]) {
        ALAsset *alAsset = (ALAsset *)asset;
        ALAssetRepresentation *defaultRepresentation = [alAsset defaultRepresentation];
        NSString *uti = [defaultRepresentation UTI];
        NSURL *videoURL = [[asset valueForProperty:ALAssetPropertyURLs] valueForKey:uti];
        AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:videoURL];
        if (completion && playerItem) {
            completion(playerItem, nil);
        }
    }
}

#pragma mark - 获取照片大小
- (void)getPhotosBytesWithArray:(NSArray *)photos completion:(void (^)(NSString *totalBytes))completion {
    __block NSInteger dataLength = 0;
    for (NSInteger i = 0; i < photos.count; i++) {
        PMPhotoInfoModel *model = photos[i];
        if ([model.asset isKindOfClass:[PHAsset class]]) {
            [[PHImageManager defaultManager] requestImageDataForAsset:model.asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                if (model.type != PMPhotoTypeVideo) {
                    dataLength += imageData.length;
                }
                if (i >= photos.count - 1) {
                    NSString *bytes = [self getBytesFromDataLength:dataLength];
                    if (completion) {
                        completion(bytes);
                    }
                }
            }];
        } else if ([model.asset isKindOfClass:[ALAsset class]]) {
            ALAssetRepresentation *representation = [model.asset defaultRepresentation];
            if (model.type != PMPhotoTypeVideo) dataLength += (NSInteger)representation.size;
            if (i >= photos.count - 1) {
                NSString *bytes = [self getBytesFromDataLength:dataLength];
                if (completion) {
                    completion(bytes);
                }
            }
        }
    }
}

- (void)getPhotoBytesWithModels:(NSArray <PMPhotoInfoModel *>*)models completion:(void (^)(NSString *totalBytes))completion {
    __block NSInteger dataLength = 0;
    [models enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PMPhotoInfoModel *model = models[idx];
        if ([model.asset isKindOfClass:[PHAsset class]]) {
            [[PHImageManager defaultManager] requestImageDataForAsset:model.asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                if (model.type != PMPhotoTypeVideo) {
                    dataLength += imageData.length;
                }
                if (idx >= models.count - 1) {
                    NSString *bytes = [self getBytesFromDataLength:dataLength];
                    if (completion) {
                        completion(bytes);
                    }
                }
            }];
        } else if ([model.asset isKindOfClass:[ALAsset class]]) {
            ALAssetRepresentation *representation = [model.asset defaultRepresentation];
            if (model.type != PMPhotoTypeVideo) {
                dataLength += (NSInteger)representation.size;
            }
            if (idx >= models.count - 1) {
                NSString *bytes = [self getBytesFromDataLength:dataLength];
                if (completion) {
                    completion(bytes);
                }
            }
        }
    }];
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

#pragma mark - 私有方法
- (PMAlbumInfoModel *)modelWithResult:(id)result name:(NSString *)name {
    PMAlbumInfoModel *model = [[PMAlbumInfoModel alloc] init];
    model.result = result;
    model.name = [self getAlbumName:name];
    if ([result isKindOfClass:[PHFetchResult class]]) {
        PHFetchResult *fetchResult = (PHFetchResult *)result;
        model.count = fetchResult.count;
        [[PMDataManager manager] getPhotoWithAsset:[model.result lastObject] photoWidth:80 completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            model.coverImage = photo;
        }];   
    } else if ([result isKindOfClass:[ALAssetsGroup class]]) {
        ALAssetsGroup *gruop = (ALAssetsGroup *)result;
        model.count = [gruop numberOfAssets];
        model.coverImage = [UIImage imageWithCGImage:gruop.posterImage];
    }
    return model;
}
#pragma clang diagnostic pop

- (NSString *)getAlbumName:(NSString *)name {
    if (_systemVersion < 8) {
        return name;
    } else {
        NSString *newName;
        if ([name containsString:@"Roll"]) {
            newName = @"相机胶卷";
        } else if ([name containsString:@"Stream"]) {
            newName = @"我的照片流";
        } else if ([name containsString:@"Added"]) {
            newName = @"最近添加";
        } else if ([name containsString:@"Selfies"]) {
            newName = @"自拍";
        } else if ([name containsString:@"shots"]) {
            newName = @"截屏";
        } else if ([name containsString:@"Videos"]) {
            newName = @"视频";
        } else {
            newName = name;
        }
        return newName;
    }
}

- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end

