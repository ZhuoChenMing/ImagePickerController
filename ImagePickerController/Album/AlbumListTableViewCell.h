//
//  AlbumListTableViewCell.h
//  ImagePickerController
//
//  Created by 酌晨茗 on 16/3/2.
//  Copyright © 2016年 酌晨茗. All rights reserved.
//

#import <UIKit/UIKit.h>

#define AlbumListImageWidth 70

@class AlbumListModel;

@interface AlbumListTableViewCell : UITableViewCell

@property (nonatomic, strong) AlbumListModel *model;

@end
