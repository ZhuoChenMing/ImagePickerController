//
//  AlbumDataHandle.h
//  ImagePickerController
//
//  Created by 酌晨茗 on 16/1/4.
//  Copyright © 2016年 酌晨茗. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

@class PhotosDataModel, PhotoPickerModel;

@interface PhotosDataHandle : NSObject

@property (nonatomic, strong) PHCachingImageManager *cachingImageManager;

+ (instancetype)manager;

//返回YES如果得到了授权
- (BOOL)authorizationStatusAuthorized;

//获得相册/相册数组
- (void)getCameraRollAlbum:(BOOL)allowPickingVideo completion:(void (^)(PhotosDataModel *model))completion;

- (void)getAllAlbums:(BOOL)allowPickingVideo completion:(void (^)(NSArray<PhotosDataModel *> *models))completion;

//获得Asset数组
- (void)getAssetsFromFetchResult:(id)result allowPickingVideo:(BOOL)allowPickingVideo completion:(void (^)(NSArray<PhotoPickerModel *> *models))completion;

- (void)getAssetFromFetchResult:(id)result atIndex:(NSInteger)index allowPickingVideo:(BOOL)allowPickingVideo completion:(void (^)(PhotoPickerModel *model))completion;

//获得照片
- (void)getPostImageWithAlbumModel:(PhotosDataModel *)model completion:(void (^)(UIImage *postImage))completion;
- (void)getPhotoWithAsset:(id)asset completion:(void (^)(UIImage *photo,NSDictionary *info, BOOL isDegraded))completion;
- (void)getPhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo, NSDictionary *info, BOOL isDegraded))completion;
- (void)getOriginalPhotoWithAsset:(id)asset completion:(void (^)(UIImage *photo,NSDictionary *info))completion;

//获得视频
- (void)getVideoWithAsset:(id)asset completion:(void (^)(AVPlayerItem * playerItem, NSDictionary * info))completion;

//获得一组照片的大小
- (void)getPhotoBytesWithPhotoArray:(NSArray *)photoArray completion:(void (^)(NSString *totalBytes))completion;

@end
