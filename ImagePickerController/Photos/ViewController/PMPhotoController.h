//
//  PMPhotoController.h
//  ImagePickerController
//
//  Created by 酌晨茗 on 15/12/24.
//  Copyright © 2015年 酌晨茗. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PMNavigationController.h"

@class PMPhotoInfoModel;

@interface PMPhotoController : UIViewController

//所有图片的数组
@property (nonatomic, strong) NSArray <PMPhotoInfoModel *>*models;

//当前选中的图片数组
@property (nonatomic, strong) NSMutableArray <PMPhotoInfoModel *>*selectedModels;

//用户点击的图片的索引
@property (nonatomic, assign) NSInteger currentIndex;

//是否返回原图
@property (nonatomic, assign) BOOL isSelectOriginalPhoto;

//返回最新的选中图片数组
@property (nonatomic, copy) void (^returnNewSelectedPhotoArrBlock)(NSMutableArray *newSeletedPhotoArr, BOOL isSelectOriginalPhoto);

@property (nonatomic, copy) void (^okButtonClickBlock)(NSMutableArray *newSeletedPhotoArr, BOOL isSelectOriginalPhoto);

@end
