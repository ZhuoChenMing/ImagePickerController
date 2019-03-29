//
//  PMAlbumInfoModel.h
//  ImagePickerController
//
//  Created by 酌晨茗 on 16/3/2.
//  Copyright © 2016年 酌晨茗. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PHFetchResult, PHAsset;

@interface PMAlbumInfoModel : NSObject

/** 相册名 */
@property (nonatomic, strong) NSString *name;

/** 相册中照片个数 */
@property (nonatomic, assign) NSInteger count;

/** < PHFetchResult<PHAsset> 或者 ALAssetsGroup<ALAsset> */
@property (nonatomic, strong) id result;

@end
