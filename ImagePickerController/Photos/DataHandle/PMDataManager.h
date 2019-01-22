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
#import "PMPhotoType.h"

@class PMAlbumInfoModel, PMPhotoInfoModel;

@interface PMDataManager : NSObject

@property (nonatomic, strong) PHCachingImageManager *cachingImageManager;

+ (instancetype)manager;

//返回YES如果得到了授权
- (BOOL)authorizationStatusAuthorized;

/**
 获取相机拍摄的照片列表数组

 @param canPickVideo 是否可以选择视频
 @param completion 回调相册数组
 */
- (void)getCameraRollAlbum:(BOOL)canPickVideo completion:(void (^)(PMAlbumInfoModel *model))completion;

/**
 获取相册列表数组

 @param canPickVideo 是否可以选择视频
 @param completion 回调相册数组
 */
- (void)getAllAlbums:(BOOL)canPickVideo completion:(void (^)(NSArray<PMAlbumInfoModel *> *models))completion;

/**
 获取相册列表中的照片详情数组

 @param result < PHFetchResult<PHAsset> or ALAssetsGroup<ALAsset>
 @param canPickVideo 是否可以选择视频
 @param completion 回调照片详情数组
 */
- (void)getAssetsFromFetchResult:(id)result canPickVideo:(BOOL)canPickVideo completion:(void (^)(NSArray<PMPhotoInfoModel *> *models))completion;

- (void)getAssetFromFetchResult:(id)result atIndex:(NSInteger)index canPickVideo:(BOOL)canPickVideo completion:(void (^)(PMPhotoInfoModel *model))completion;

//获得照片
- (void)getPostImageWithAlbumModel:(PMAlbumInfoModel *)model completion:(void (^)(UIImage *postImage))completion;
- (void)getPhotoWithAsset:(id)asset completion:(void (^)(UIImage *photo, NSDictionary *info, BOOL isDegraded))completion;
- (void)getPhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo, NSDictionary *info, BOOL isDegraded))completion;
- (void)getOriginalPhotoWithAsset:(id)asset completion:(void (^)(UIImage *photo, NSDictionary *info))completion;

//获得视频
- (void)getVideoWithAsset:(id)asset completion:(void (^)(AVPlayerItem *playerItem, NSDictionary *info))completion;

/**
 获得一组照片的总大小

 @param photoArray 照片数组
 @param completion 回调计算的大小
 */
- (void)getPhotoBytesWithPhotoArray:(NSArray *)photoArray completion:(void (^)(NSString *totalBytes))completion;

@end
