//
//  PMPhotoPreviewCell.h
//  ImagePickerController
//
//  Created by 酌晨茗 on 15/12/24.
//  Copyright © 2015年 酌晨茗. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PMPhotoInfoModel;

@interface PMPhotoPreviewCell : UICollectionViewCell

@property (nonatomic, strong) PMPhotoInfoModel *model;

@property (nonatomic, copy) void (^singleTapGestureBlock)(void);

@property (nonatomic, copy) void (^doubleTapGestureBlock)(void);

@end
