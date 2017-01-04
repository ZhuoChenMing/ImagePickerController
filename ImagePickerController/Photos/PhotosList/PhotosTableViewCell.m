//
//  PhotosTableViewCell.m
//  ImagePickerController
//
//  Created by 酌晨茗 on 16/3/2.
//  Copyright © 2016年 酌晨茗. All rights reserved.
//

#import "PhotosTableViewCell.h"
#import "PhotosDataModel.h"
#import "PhotosDataHandle.h"

#define iOS7Later ([UIDevice currentDevice].systemVersion.floatValue >= 7.0f)
#define iOS8Later ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f)
#define iOS9Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f)
#define iOS9_1Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.1f)

@interface PhotosTableViewCell ()

@property (nonatomic, strong) UIImageView *albumImageView;

@property (nonatomic, strong) UILabel *titleLable;

@end

@implementation PhotosTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _albumImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0, 5.0, AlbumListCellHeight - 10.0, AlbumListCellHeight - 10.0)];
        _albumImageView.contentMode = UIViewContentModeScaleAspectFill;
        _albumImageView.clipsToBounds = YES;
        [self addSubview:_albumImageView];
        
        _titleLable = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(_albumImageView.frame) + 10, 0, 150, AlbumListCellHeight)];
        [self addSubview:_titleLable];
    }
    return self;
}

- (void)setModel:(PhotosDataModel *)model {
    _model = model;
    NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc] initWithString:model.name attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor blackColor]}];
    NSAttributedString *countString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"  (%zd)", model.count] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16], NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
    [nameString appendAttributedString:countString];
    self.titleLable.attributedText = nameString;
    [[PhotosDataHandle manager] getPostImageWithAlbumModel:model completion:^(UIImage *postImage) {
        self.albumImageView.image = postImage;
    }];
}

- (void)layoutSubviews {
    if (iOS7Later) {
        [super layoutSubviews];
    }
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    if (iOS7Later) {
        [super layoutSublayersOfLayer:layer];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
