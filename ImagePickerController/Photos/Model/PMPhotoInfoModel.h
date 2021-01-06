//
//  AlbumModel.h
//  ImagePickerController
//
//  Created by 酌晨茗 on 15/12/24.
//  Copyright © 2015年 酌晨茗. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PMPhotoType.h"

@class PHAsset;

@interface PMPhotoInfoModel : NSObject

/// PHAsset或者ALAsset
@property (nonatomic, strong) id asset;

/// 是否选择了该照片
@property (nonatomic, assign) BOOL isSelected;

/// 照片或者视频的封面
@property (nonatomic, strong) UIImage *image;

/// 照片或者视频的信息字典
@property (nonatomic, strong) NSDictionary *info;

/// 照片类型
@property (nonatomic, assign) PMPhotoType type;

/// 影音时长
@property (nonatomic, copy) NSString *timeLength;

/** 初始化照片模型 */
+ (instancetype)modelWithAsset:(id)asset type:(PMPhotoType)type;

+ (instancetype)modelWithAsset:(id)asset type:(PMPhotoType)type timeLength:(NSString *)timeLength;

@end
