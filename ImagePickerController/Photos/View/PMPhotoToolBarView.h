//
//  PMPhotoToolBarView.h
//  ImagePickerController
//
//  Created by 酌晨茗 on 2019/1/22.
//  Copyright © 2019 zhuochenming. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PMNavigationController, PMPhotoInfoModel;

@interface PMPhotoToolBarView : UIView

@property (nonatomic, strong) UIButton *previewButton;

@property (nonatomic, strong) UIButton *okButton;

@property (nonatomic, strong) UILabel *numberLabel;

@property (nonatomic, strong) UIButton *originalPhotoButton;

@property (nonatomic, strong) UILabel *originalPhotoLabel;

/// 初始化相片选择器
/// @param navigation 获取 PMNavigationController 的配置信息
/// @param selectedModels 选择的相片
/// @param models 全部的相片
/// @param previewPhoto 是否使用预览按钮
- (instancetype)initWithNavigation:(PMNavigationController *)navigation selectedModels:(NSArray <PMPhotoInfoModel *>*)selectedModels models:(NSArray <PMPhotoInfoModel *>*)models  previewPhoto:(BOOL)previewPhoto;

@end

NS_ASSUME_NONNULL_END
