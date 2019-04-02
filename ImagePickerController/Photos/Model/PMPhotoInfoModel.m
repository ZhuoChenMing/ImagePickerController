//
//  AlbumModel.m
//  ImagePickerController
//
//  Created by 酌晨茗 on 15/12/24.
//  Copyright © 2015年 酌晨茗. All rights reserved.
//

#import "PMPhotoInfoModel.h"

@implementation PMPhotoInfoModel

+ (instancetype)modelWithAsset:(id)asset type:(PMPhotoType)type {
    PMPhotoInfoModel *model = [[PMPhotoInfoModel alloc] init];
    model.asset = asset;
    model.isSelected = NO;
    model.type = type;
    return model;
}

+ (instancetype)modelWithAsset:(id)asset type:(PMPhotoType)type timeLength:(NSString *)timeLength {
    PMPhotoInfoModel *model = [self modelWithAsset:asset type:type];
    model.timeLength = timeLength;
    return model;
}

@end
