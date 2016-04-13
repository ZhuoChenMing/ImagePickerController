//
//  AlbumListTableViewCell.h
//  ImagePickerController
//
//  Created by 酌晨茗 on 16/3/2.
//  Copyright © 2016年 酌晨茗. All rights reserved.
//

#import <UIKit/UIKit.h>

static const CGFloat AlbumListCellHeight = 70.0;

@class AlbumDataModel;

@interface AlbumListTableViewCell : UITableViewCell

@property (nonatomic, strong) AlbumDataModel *model;

@end
