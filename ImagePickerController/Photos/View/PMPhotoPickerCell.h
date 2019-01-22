//
//  PMPhotoPickerCell.h
//  ImagePickerController
//
//  Created by 酌晨茗 on 15/12/24.
//  Copyright © 2015年 酌晨茗. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PMPhotoType.h"

@class PMPhotoInfoModel;

@interface PMPhotoPickerCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIButton *selectPhotoButton;

@property (nonatomic, strong) PMPhotoInfoModel *model;

@property (nonatomic, copy) void (^didSelectPhotoBlock)(BOOL);

@property (nonatomic, assign) PMPhotoType type;

@end

