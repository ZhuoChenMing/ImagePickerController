//
//  PhotosTableViewCell.h
//  ImagePickerController
//
//  Created by 酌晨茗 on 16/3/2.
//  Copyright © 2016年 酌晨茗. All rights reserved.
//

#import <UIKit/UIKit.h>

static const CGFloat AlbumListCellHeight = 70.0;

@class PhotosDataModel;

@interface PhotosTableViewCell : UITableViewCell

@property (nonatomic, strong) PhotosDataModel *model;

@end
