//
//  PMNavigationController.m
//  ImagePickerController
//
//  Created by 酌晨茗 on 16/3/7.
//  Copyright © 2016年 酌晨茗. All rights reserved.
//

#import "PMNavigationController.h"
#import "PMAlbumViewController.h"
#import "PMPhotoPickerController.h"

#import "PMDataManager.h"

@interface PMNavigationController ()

@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, strong) UILabel *tipLable;

@property (nonatomic, strong) UIButton *progressHUD;
@property (nonatomic, strong) UIView *HUDContainer;
@property (nonatomic, strong) UIActivityIndicatorView *HUDIndicatorView;
@property (nonatomic, strong) UILabel *HUDLable;

@end

@implementation PMNavigationController

- (instancetype)initWithMaxImageCount:(NSInteger)maxImageCount delegate:(id<PMNavigationControllerDelegate>)delegate {
    PMAlbumViewController *viewController = [[PMAlbumViewController alloc] init];
    if (self = [super initWithRootViewController:viewController]) {
        self.maxImageCount = maxImageCount > 0 ? maxImageCount : 9; // Default is 9 / 默认最大可选9张图片
        self.pickerDelegate = delegate;
        
        // 默认准许用户选择原图和视频, 你也可以在这个方法后置为NO
        self.canPickOriginalPhoto = YES;
        self.canPickVideo = YES;
        
        if (![[PMDataManager manager] authorizationStatusAuthorized]) {
            self.tipLable = [[UILabel alloc] init];
            self.tipLable.frame = CGRectMake(8, 0, CGRectGetWidth(self.view.frame) - 16, 300);
            self.tipLable.textAlignment = NSTextAlignmentCenter;
            self.tipLable.numberOfLines = 0;
            self.tipLable.font = [UIFont systemFontOfSize:16];
            self.tipLable.textColor = [UIColor blackColor];
            NSString *appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleDisplayName"];
            if (!appName) {
                appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleName"];
            }
            self.tipLable.text = [NSString stringWithFormat:@"请在%@的\"设置-隐私-照片\"选项中，\r允许%@访问你的手机相册。",[UIDevice currentDevice].model, appName];
            [self.view addSubview:_tipLable];
            
            self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
            dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC, 0.5 * NSEC_PER_SEC);
            dispatch_source_set_event_handler(_timer, ^{
                [self observeAuthrizationStatusChange];
            });
            dispatch_resume(_timer);
        } else {
            [self pushToPhotoPickerViewController];
        }
    }
    return self;
}

- (void)observeAuthrizationStatusChange {
    if ([[PMDataManager manager] authorizationStatusAuthorized]) {
        if (_timer) {
            dispatch_source_cancel(_timer);
        }
        
        if ([[NSThread currentThread] isMainThread]) {
            [self.tipLable removeFromSuperview];
            [self pushToPhotoPickerViewController];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tipLable removeFromSuperview];
                [self pushToPhotoPickerViewController];
            });
        }
    }
}

- (void)pushToPhotoPickerViewController {
    //    PMPhotoPickerController *pickerVC = [[PMPhotoPickerController alloc] init];
    //    [[PMDataManager manager] getCameraRollAlbum:self.canPickVideo completion:^(PMAlbumInfoModel *model) {
    //        pickerVC.model = model;
    //        [self pushViewController:pickerVC animated:YES];
    //    }];
    
    PMAlbumViewController *viewController = [[PMAlbumViewController alloc] init];
    viewController.navigationItem.hidesBackButton = YES;
    [self pushViewController:viewController animated:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationBar.translucent = YES;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    // 默认的外观，你可以在这个方法后重置
    self.oKButtonTitleColorNormal = [UIColor colorWithRed:(83 / 255.0) green:(179 / 255.0) blue:(17 / 255.0) alpha:1.0];
    self.oKButtonTitleColorDisabled = [UIColor colorWithRed:(83 / 255.0) green:(179 / 255.0) blue:(17 / 255.0) alpha:0.5];
    
    if (iOS7Later) {
        self.navigationBar.barTintColor = [UIColor colorWithRed:(34 / 255.0) green:(34 / 255.0)  blue:(34 / 255.0) alpha:1.0];
        self.navigationBar.tintColor = [UIColor whiteColor];
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    UIBarButtonItem *barItem;
    if (iOS9Later) {
        barItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[PMAlbumViewController class]]];
    } else {
        barItem = [UIBarButtonItem appearanceWhenContainedIn:[PMAlbumViewController class], nil];
    }
#pragma clang diagnostic pop    
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = [UIColor whiteColor];
    textAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:15];
    [barItem setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (void)showAlertWithTitle:(NSString *)title {
    if (iOS8Later) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        [[[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil] show];
    }
}
#pragma clang diagnostic pop

- (void)showProgressHUD {
    if (!_progressHUD) {
        _progressHUD = [UIButton buttonWithType:UIButtonTypeCustom];
        [_progressHUD setBackgroundColor:[UIColor clearColor]];
        
        _HUDContainer = [[UIView alloc] init];
        _HUDContainer.frame = CGRectMake((CGRectGetWidth(self.view.frame) - 120) / 2, (CGRectGetHeight(self.view.frame) - 90) / 2, 120, 90);
        _HUDContainer.layer.cornerRadius = 8;
        _HUDContainer.clipsToBounds = YES;
        _HUDContainer.backgroundColor = [UIColor darkGrayColor];
        _HUDContainer.alpha = 0.7;
        
        _HUDIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _HUDIndicatorView.frame = CGRectMake(45, 15, 30, 30);
        
        _HUDLable = [[UILabel alloc] init];
        _HUDLable.frame = CGRectMake(0,40, 120, 50);
        _HUDLable.textAlignment = NSTextAlignmentCenter;
        _HUDLable.text = @"正在处理...";
        _HUDLable.font = [UIFont systemFontOfSize:15];
        _HUDLable.textColor = [UIColor whiteColor];
        
        [_HUDContainer addSubview:_HUDLable];
        [_HUDContainer addSubview:_HUDIndicatorView];
        [_progressHUD addSubview:_HUDContainer];
    }
    [_HUDIndicatorView startAnimating];
    [[UIApplication sharedApplication].keyWindow addSubview:_progressHUD];
}

- (void)hideProgressHUD {
    if (_progressHUD) {
        [_HUDIndicatorView stopAnimating];
        [_progressHUD removeFromSuperview];
    }
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (iOS7Later) {
        viewController.automaticallyAdjustsScrollViewInsets = NO;
    }

//    if (self.childViewControllers.count > 0) {
//        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(-8, 0, 44, 44)];
//        [backButton setImage:[UIImage imageNamed:@"navi_back"] forState:UIControlStateNormal];
//        backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 0);
//        [backButton setTitle:@"返回" forState:UIControlStateNormal];
//        backButton.titleLabel.font = [UIFont systemFontOfSize:15];
//        [backButton addTarget:self action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
//        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
//    }
    [super pushViewController:viewController animated:animated];
}

@end
