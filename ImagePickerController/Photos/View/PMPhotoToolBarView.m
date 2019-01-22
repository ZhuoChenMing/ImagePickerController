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
        
        _okButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _okButton.frame = CGRectMake(width - 44 - 12, 3, 44, 44);
        _okButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_okButton setTitle:@"确定" forState:UIControlStateNormal];
        [_okButton setTitle:@"确定" forState:UIControlStateDisabled];
        [_okButton setTitleColor:navigation.oKButtonTitleColorNormal forState:UIControlStateNormal];
        [_okButton setTitleColor:navigation.oKButtonTitleColorDisabled forState:UIControlStateDisabled];
        _okButton.enabled = selectedPhotoArray.count > 0;
        [self addSubview:_okButton];
        
        _numberLable = [[UILabel alloc] init];
        _numberLable.frame = CGRectMake(width - 56 - 24, 12, 26, 26);
        _numberLable.layer.cornerRadius = 13.0;
        _numberLable.clipsToBounds = YES;
        _numberLable.font = [UIFont systemFontOfSize:16];
        _numberLable.textColor = [UIColor whiteColor];
        _numberLable.textAlignment = NSTextAlignmentCenter;
        _numberLable.text = [NSString stringWithFormat:@"%zd", selectedPhotoArray.count];
        _numberLable.hidden = selectedPhotoArray.count <= 0;
        _numberLable.backgroundColor = navigation.oKButtonTitleColorNormal;
        [self addSubview:_numberLable];
        
        if (navigation.canPickOriginalPhoto) {
            _originalPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _originalPhotoButton.imageEdgeInsets = UIEdgeInsetsMake(0, -8, 0, 0);
            _originalPhotoButton.contentEdgeInsets = UIEdgeInsetsMake(0, -45, 0, 0);
            _originalPhotoButton.titleLabel.font = [UIFont systemFontOfSize:16];
            [_originalPhotoButton setTitle:@"原图" forState:UIControlStateNormal];
            [_originalPhotoButton setTitle:@"原图" forState:UIControlStateSelected];
            [_originalPhotoButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [_originalPhotoButton setTitleColor:navigation.oKButtonTitleColorNormal forState:UIControlStateSelected];
            [_originalPhotoButton setImage:[UIImage imageNamed:@"photo_original_def"] forState:UIControlStateNormal];
            [_originalPhotoButton setImage:[UIImage imageNamed:@"photo_original_sel"] forState:UIControlStateSelected];
            
            _originalPhotoLable = [[UILabel alloc] init];
            _originalPhotoLable.frame = CGRectMake(70, 0, 60, 50);
            _originalPhotoLable.textAlignment = NSTextAlignmentLeft;
            _originalPhotoLable.font = [UIFont systemFontOfSize:16];
            _originalPhotoLable.textColor = navigation.oKButtonTitleColorNormal;
            if (isHave) {
                [[PMDataManager manager] getPhotoBytesWithPhotoArray:photoArray completion:^(NSString *totalBytes) {
                    self.originalPhotoLable.text = [NSString stringWithFormat:@"(%@)",totalBytes];
                }];
            }
            [_originalPhotoButton addSubview:_originalPhotoLable];
            [self addSubview:_originalPhotoButton];
        }
        
        if (isHave) {
            _originalPhotoButton.frame = CGRectMake(60, 0, 130, 50);
            _originalPhotoButton.enabled = selectedPhotoArray.count > 0;
            
            _previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _previewButton.frame = CGRectMake(10, 3, 44, 44);
            _previewButton.titleLabel.font = [UIFont systemFontOfSize:16];
            [_previewButton setTitle:@"预览" forState:UIControlStateNormal];
            [_previewButton setTitle:@"预览" forState:UIControlStateDisabled];
            [_previewButton setTitleColor:navigation.oKButtonTitleColorNormal forState:UIControlStateNormal];
            [_previewButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
            _previewButton.enabled = NO;
            [self addSubview:_previewButton];
        } else {
            _originalPhotoButton.frame = CGRectMake(10, 0, 130, 50);
        }
    }
    return self;
}

@end
