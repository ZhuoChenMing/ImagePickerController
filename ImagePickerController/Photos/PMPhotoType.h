//
//  PMPhotoTypeProtocol.h
//  ImagePickerController
//
//  Created by 酌晨茗 on 16/3/2.
//  Copyright © 2016年 酌晨茗. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    PMPhotoTypePhoto = 0,
    PMPhotoTypeLivePhoto,
    PMPhotoTypeVideo,
    PMPhotoTypeAudio
} PMPhotoType;

#define iOS7Later ([UIDevice currentDevice].systemVersion.floatValue >= 7.0f)
#define iOS8Later ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f)
#define iOS9Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f)
#define iOS9_1Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.1f)
