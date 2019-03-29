//
//  PMPhotoToolBarView.m
//  ImagePickerController
//
//  Created by 酌晨茗 on 2019/1/22.
//  Copyright © 2019 zhuochenming. All rights reserved.
//

#import "PMPhotoToolBarView.h"
#import "PMNavigationController.h"

#import "PMDataManager.h"

@implementation PMPhotoToolBarView

- (instancetype)initWithNavigation:(PMNavigationController *)navigation
                selectedPhotoArray:(NSArray *)selectedPhotoArray
                        photoArray:(NSArray *)photoArray
          isHavePreviewPhotoButton:(BOOL)isHave {
    if (self = [super init]) {
        CGRect windowRect = [UIScreen mainScreen].bounds;
        CGFloat width = CGRectGetWidth(windowRect);
        CGFloat height = CGRectGetHeight(windowRect);
        
        self.frame = CGRectMake(0, height - 50, width, 50);
        CGFloat rgb = 253 / 255.0;
        self.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:1.0];
        
        UIView *divide = [[UIView alloc] init];
        CGFloat rgb2 = 222 / 255.0;
        divide.backgroundColor = [UIColor colorWithRed:rgb2 green:rgb2 blue:rgb2 alpha:1.0];
        divide.frame = CGRectMake(0, 0, width, 1);
        [self addSubview:divide];
        
        self.okButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.okButton.frame = CGRectMake(width - 44 - 12, 3, 44, 44);
        self.okButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [self.okButton setTitle:@"确定" forState:UIControlStateNormal];
        [self.okButton setTitle:@"确定" forState:UIControlStateDisabled];
        [self.okButton setTitleColor:navigation.oKButtonTitleColorNormal forState:UIControlStateNormal];
        [self.okButton setTitleColor:navigation.oKButtonTitleColorDisabled forState:UIControlStateDisabled];
        self.okButton.enabled = selectedPhotoArray.count > 0;
        [self addSubview:_okButton];
        
        self.numberLabel = [[UILabel alloc] init];
        self.numberLabel.frame = CGRectMake(width - 56 - 24, 12, 26, 26);
        self.numberLabel.layer.cornerRadius = 13.0;
        self.numberLabel.clipsToBounds = YES;
        self.numberLabel.font = [UIFont systemFontOfSize:16];
        self.numberLabel.textColor = [UIColor whiteColor];
        self.numberLabel.textAlignment = NSTextAlignmentCenter;
        self.numberLabel.text = [NSString stringWithFormat:@"%zd", selectedPhotoArray.count];
        self.numberLabel.hidden = selectedPhotoArray.count <= 0;
        self.numberLabel.backgroundColor = navigation.oKButtonTitleColorNormal;
        [self addSubview:_numberLabel];
        
        if (navigation.canPickOriginalPhoto) {
            self.originalPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.originalPhotoButton.imageEdgeInsets = UIEdgeInsetsMake(0, -8, 0, 0);
            self.originalPhotoButton.contentEdgeInsets = UIEdgeInsetsMake(0, -45, 0, 0);
            self.originalPhotoButton.titleLabel.font = [UIFont systemFontOfSize:16];
            [self.originalPhotoButton setTitle:@"原图" forState:UIControlStateNormal];
            [self.originalPhotoButton setTitle:@"原图" forState:UIControlStateSelected];
            [self.originalPhotoButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [self.originalPhotoButton setTitleColor:navigation.oKButtonTitleColorNormal forState:UIControlStateSelected];
            [self.originalPhotoButton setImage:[UIImage imageNamed:@"photo_original_def"] forState:UIControlStateNormal];
            [self.originalPhotoButton setImage:[UIImage imageNamed:@"photo_original_sel"] forState:UIControlStateSelected];
            
            self.originalPhotoLabel = [[UILabel alloc] init];
            self.originalPhotoLabel.frame = CGRectMake(70, 0, 60, 50);
            self.originalPhotoLabel.textAlignment = NSTextAlignmentLeft;
            self.originalPhotoLabel.font = [UIFont systemFontOfSize:16];
            self.originalPhotoLabel.textColor = navigation.oKButtonTitleColorNormal;
            if (isHave) {
                [[PMDataManager manager] getPhotoBytesWithPhotoArray:photoArray completion:^(NSString *totalBytes) {
                    self.originalPhotoLabel.text = [NSString stringWithFormat:@"(%@)",totalBytes];
                }];
            }
            [self.originalPhotoButton addSubview:_originalPhotoLabel];
            [self addSubview:_originalPhotoButton];
        }
        
        if (isHave) {
            self.originalPhotoButton.frame = CGRectMake(60, 0, 130, 50);
            self.originalPhotoButton.enabled = selectedPhotoArray.count > 0;
            
            self.previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.previewButton.frame = CGRectMake(10, 3, 44, 44);
            self.previewButton.titleLabel.font = [UIFont systemFontOfSize:16];
            [self.previewButton setTitle:@"预览" forState:UIControlStateNormal];
            [self.previewButton setTitle:@"预览" forState:UIControlStateDisabled];
            [self.previewButton setTitleColor:navigation.oKButtonTitleColorNormal forState:UIControlStateNormal];
            [self.previewButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
            self.previewButton.enabled = NO;
            [self addSubview:_previewButton];
        } else {
            self.originalPhotoButton.frame = CGRectMake(10, 0, 130, 50);
        }
    }
    return self;
}

@end
