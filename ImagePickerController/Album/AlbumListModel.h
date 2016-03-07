//
//  AlbumListModel.h
//  ImagePickerController
//
//  Created by 酌晨茗 on 16/3/2.
//  Copyright © 2016年 酌晨茗. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PHFetchResult, PHAsset;

@interface AlbumListModel : NSObject

@property (nonatomic, strong) NSString *name;        ///< The album name

@property (nonatomic, assign) NSInteger count;       ///< Count of photos the album contain

@property (nonatomic, strong) id result;             ///< PHFetchResult<PHAsset> or ALAssetsGroup<ALAsset>

@end
