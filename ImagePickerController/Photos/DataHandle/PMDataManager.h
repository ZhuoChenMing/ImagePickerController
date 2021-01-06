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

/// 系统版本
@property (nonatomic, assign, readonly) CGFloat systemVersion;

/// 是否是刘海屏
@property (nonatomic, assign, readonly) BOOL notchScreen;
/// 刘海屏的下边距
@property (nonatomic, assign, readonly) CGFloat notchBottom;

/// 是否可以选择视频
@property (nonatomic, assign) BOOL canPickVideo;

+ (instancetype)manager;

/// 返回YES如果得到了授权
- (BOOL)authorizationStatusAuthorized;
/// 获取授权
- (void)getAuthorization:(void(^)(BOOL authorized))callback;

/// 只获取相机拍摄的照片列表
- (void)getCameraRollAlbum:(void (^)(PMAlbumInfoModel *model))completion;
/// 获取相册列表数组
- (void)getAlbums:(void (^)(NSArray<PMAlbumInfoModel *> *models))completion;

/**
 获取相册列表中的照片详情数组

 @param result < PHFetchResult<PHAsset> or ALAssetsGroup<ALAsset>
 @param completion 回调照片详情数组
 */
- (void)getAssetsFromFetchResult:(id)result completion:(void (^)(NSArray<PMPhotoInfoModel *> *models))completion;
- (void)getAssetFromFetchResult:(id)result atIndex:(NSInteger)index completion:(void (^)(PMPhotoInfoModel *model))completion;

/**
 根据数据源获取适配屏幕宽度的图片及图片信息

 @param asset 相册数据源
 @param completion 返回图片及图片信息
 */
- (void)getPhotoWithAsset:(id)asset completion:(void (^)(UIImage *photo, NSDictionary *info, BOOL isDegraded))completion;

/**
 根据数据源获取适配某一宽度获取图片及图片信息
 
 @param asset 相册数据源
 @param photoWidth 缩略图宽度
 @param completion 返回图片及图片信息
 */
- (void)getPhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo, NSDictionary *info, BOOL isDegraded))completion;

/**
 获取相册的原图及图片信息
 
 @param asset 相册数据源
 @param completion 返回原图及图片信息
 */
- (void)getOriginalPhotoWithAsset:(id)asset completion:(void (^)(UIImage *photo, NSDictionary *info))completion;

//获得视频
- (void)getVideoWithAsset:(id)asset completion:(void (^)(AVPlayerItem *playerItem, NSDictionary *info))completion;

/**
 获得一组照片的总大小

 @param models 模型数组
 @param completion 回调计算的大小
 */
- (void)getPhotoBytesWithModels:(NSArray <PMPhotoInfoModel *>*)models completion:(void (^)(NSString *totalBytes))completion;

@end
