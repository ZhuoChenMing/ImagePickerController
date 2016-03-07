//
//  PhotoPickerCell.h
//  ImagePickerController
//
//  Created by 酌晨茗 on 15/12/24.
//  Copyright © 2015年 酌晨茗. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaType.h"

@class PhotoPickerModel;

@interface PhotoPickerCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIButton *selectPhotoButton;

@property (nonatomic, strong) PhotoPickerModel *model;

@property (nonatomic, copy) void (^didSelectPhotoBlock)(BOOL);

@property (nonatomic, assign) AlbumModelMediaType type;

@end

