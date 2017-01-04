//
//  AlbumModel.h
//  ImagePickerController
//
//  Created by 酌晨茗 on 15/12/24.
//  Copyright © 2015年 酌晨茗. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MediaType.h"

@class PHAsset;

@interface PhotoPickerModel : NSObject

@property (nonatomic, strong) id asset;             ///< PHAsset or ALAsset

@property (nonatomic, assign) BOOL isSelected;      ///< The select status of a photo, default is No

@property (nonatomic, assign) AlbumModelMediaType type;

@property (nonatomic, copy) NSString *timeLength;

//初始化照片模型
+ (instancetype)modelWithAsset:(id)asset type:(AlbumModelMediaType)type;

+ (instancetype)modelWithAsset:(id)asset type:(AlbumModelMediaType)type timeLength:(NSString *)timeLength;

@end
