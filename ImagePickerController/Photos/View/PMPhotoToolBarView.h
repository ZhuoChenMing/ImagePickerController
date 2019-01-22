//
//  PMPhotoToolBarView.h
//  ImagePickerController
//
//  Created by 酌晨茗 on 2019/1/22.
//  Copyright © 2019 zhuochenming. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PMNavigationController;

@interface PMPhotoToolBarView : UIView

@property (nonatomic, assign) BOOL isHavePreviewButton;

@property (nonatomic, strong) UIButton *previewButton;

@property (nonatomic, strong) UIButton *okButton;

@property (nonatomic, strong) UILabel *numberLable;

@property (nonatomic, strong) UIButton *originalPhotoButton;

@property (nonatomic, strong) UILabel *originalPhotoLable;

- (instancetype)initWithNavigation:(PMNavigationController *)navigation
                selectedPhotoArray:(NSArray *)selectedPhotoArray
                        photoArray:(NSArray *)photoArray
          isHavePreviewPhotoButton:(BOOL)isHave;

@end

NS_ASSUME_NONNULL_END
