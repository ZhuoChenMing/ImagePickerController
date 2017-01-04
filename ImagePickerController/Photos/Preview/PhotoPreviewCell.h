//
//  PhotoPreviewCell.h
//  ImagePickerController
//
//  Created by 酌晨茗 on 15/12/24.
//  Copyright © 2015年 酌晨茗. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoPickerModel;

@interface PhotoPreviewCell : UICollectionViewCell

@property (nonatomic, strong) PhotoPickerModel *model;

@property (nonatomic, copy) void (^singleTapGestureBlock)();

@property (nonatomic, copy) void (^doubleTapGestureBlock)();

@end
