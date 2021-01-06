//
//  PMNavigationController.h
//  ImagePickerController
//
//  Created by 酌晨茗 on 16/3/7.
//  Copyright © 2016年 酌晨茗. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PMNavigationController;

@protocol PMNavigationControllerDelegate <NSObject>

@optional
//这个照片选择器不会自己dismiss，用户dismiss这个选择器的时候，会走下面的回调，如果用户没有选择发送原图，Assets将是空数组
- (void)navigationController:(PMNavigationController *)navigation didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets;

- (void)navigationController:(PMNavigationController *)navigation didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets infos:(NSArray<NSDictionary *> *)infos;

- (void)navigationControllerDidCancel:(PMNavigationController *)navigation;

//如果用户选择了一个视频，下面的handle会被执行，如果系统版本大于iOS8，asset是PHAsset类的对象，否则是ALAsset类的对象
- (void)navigationController:(PMNavigationController *)navigation didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(id)asset;

@end



@interface PMNavigationController : UINavigationController

/// 初始化照片选择器
/// @param maxImageCount 最多可以选择多少张照片（0可全选）
/// @param delegate 代理
- (instancetype)initWithMaxImageCount:(NSInteger)maxImageCount delegate:(id<PMNavigationControllerDelegate>)delegate;

/// 最多可以选择多少张照片
@property (nonatomic, assign, readonly) NSInteger maxImageCount;

/// 默认为YES，如果设置为NO,原图按钮将隐藏，用户不能选择发送原图
@property (nonatomic, assign) BOOL canPickOriginalPhoto;

/// 默认为YES，如果设置为NO,用户将不能选择发送视频
@property (nonatomic, assign) BOOL canPickVideo;

/// 外观颜色
@property (nonatomic, strong) UIColor *oKButtonTitleColorNormal;
@property (nonatomic, strong) UIColor *oKButtonTitleColorDisabled;

/** 这个照片选择器不会自己dismiss，用户dismiss这个选择器的时候，会执行下面的handle;如果用户没有选择发送原图,第二个数组将是空数组 */
@property (nonatomic, copy) void (^didFinishPickingPhotosHandle)(NSArray<UIImage *> *photos, NSArray *assets);

@property (nonatomic, copy) void (^didFinishPickingPhotosWithInfosHandle)(NSArray<UIImage *> *photos,NSArray *assets, NSArray<NSDictionary *> *infos);

@property (nonatomic, copy) void (^didCancelHandle)(void);

/** 如果用户选择了一个视频，下面的handle会被执行，如果系统版本大于iOS8，asset是PHAsset类的对象，否则是ALAsset类的对象 */
@property (nonatomic, copy) void (^didFinishPickingVideoHandle)(UIImage *coverImage, id asset);

@property (nonatomic, weak) id<PMNavigationControllerDelegate> pickerDelegate;

- (void)showAlertWithTitle:(NSString *)title;

/// 加载进度框
- (void)showProgressHUD;
- (void)hideProgressHUD;

@end
