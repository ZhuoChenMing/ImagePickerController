//
//  PMPhotoPickerCell.m
//  ImagePickerController
//
//  Created by 酌晨茗 on 15/12/24.
//  Copyright © 2015年 酌晨茗. All rights reserved.
//

#import "PMPhotoPickerCell.h"
#import "PMPhotoInfoModel.h"
#import "PMDataManager.h"

@interface PMPhotoPickerCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UIImageView *selectImageView;

@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (weak, nonatomic) IBOutlet UILabel *timeLength;

@end

@implementation PMPhotoPickerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.timeLength.font = [UIFont boldSystemFontOfSize:11];  
}

- (void)setModel:(PMPhotoInfoModel *)model {
    _model = model;
    [[PMDataManager manager] getPhotoWithAsset:model.asset photoWidth:CGRectGetWidth(self.frame) completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        self.imageView.image = photo;
    }];
    self.selectPhotoButton.selected = model.isSelected;
    self.selectImageView.image = self.selectPhotoButton.isSelected ? [UIImage imageNamed:@"photo_sel_photoPickerVc"] : [UIImage imageNamed:@"photo_def_photoPickerVc"];
    self.type = PMPhotoTypePhoto;
    if (model.type == PMPhotoTypeLivePhoto) {
        self.type = PMPhotoTypeLivePhoto;
    } else if (model.type == PMPhotoTypeAudio) {
        self.type = PMPhotoTypeAudio;
    } else if (model.type == PMPhotoTypeVideo) {
        self.type = PMPhotoTypeVideo;
        self.timeLength.text = model.timeLength;
    }
}

- (void)setType:(PMPhotoType)type {
    _type = type;
    if (type == PMPhotoTypePhoto || type == PMPhotoTypeLivePhoto) {
        _selectImageView.hidden = NO;
        _selectPhotoButton.hidden = NO;
        _bottomView.hidden = YES;
    } else {
        _selectImageView.hidden = YES;
        _selectPhotoButton.hidden = YES;
        _bottomView.hidden = NO;
    }
}

- (IBAction)selectPhotoButtonClick:(UIButton *)sender {
    if (self.didSelectPhotoBlock) {
        self.didSelectPhotoBlock(sender.isSelected);
    }
    self.selectImageView.image = sender.isSelected ? [UIImage imageNamed:@"photo_sel_photoPickerVc"] : [UIImage imageNamed:@"photo_def_photoPickerVc"];
    if (sender.isSelected) {
        [self showOscillatoryAnimationWithLayer:_selectImageView.layer type:0];
    }
}

- (void)showOscillatoryAnimationWithLayer:(CALayer *)layer type:(BOOL)type {
    NSNumber *animationScale1 = type == 0 ? @(1.15) : @(0.5);
    NSNumber *animationScale2 = type == 0 ? @(0.92) : @(1.15);
    
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
        [layer setValue:animationScale1 forKeyPath:@"transform.scale"];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
            [layer setValue:animationScale2 forKeyPath:@"transform.scale"];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
                [layer setValue:@(1.0) forKeyPath:@"transform.scale"];
            } completion:nil];
        }];
    }];
}

@end
