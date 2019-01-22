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

@property (nonatomic, strong) id asset;             ///< PHAsset or ALAsset


/** 是否选择了该照片 */
@property (nonatomic, assign) BOOL isSelected;


@property (nonatomic, assign) PMPhotoType type;

@property (nonatomic, copy) NSString *timeLength;

//初始化照片模型
+ (instancetype)modelWithAsset:(id)asset type:(PMPhotoType)type;

+ (instancetype)modelWithAsset:(id)asset type:(PMPhotoType)type timeLength:(NSString *)timeLength;

@end
