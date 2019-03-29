//
//  PMTableViewCell.m
//  ImagePickerController
//
//  Created by 酌晨茗 on 16/3/2.
//  Copyright © 2016年 酌晨茗. All rights reserved.
//

#import "PMTableViewCell.h"
#import "PMAlbumInfoModel.h"
#import "PMDataManager.h"

@interface PMTableViewCell ()

@property (nonatomic, strong) UIImageView *albumImageView;

@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation PMTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.albumImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0, 5.0, kAlbumListCellHeight - 10.0, kAlbumListCellHeight - 10.0)];
        self.albumImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.albumImageView.clipsToBounds = YES;
        [self addSubview:_albumImageView];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(_albumImageView.frame) + 10, 0, 150, kAlbumListCellHeight)];
        [self addSubview:_nameLabel];
    }
    return self;
}

- (void)setModel:(PMAlbumInfoModel *)model {
    _model = model;
    NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc] initWithString:model.name attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor blackColor]}];
    NSAttributedString *countString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"  (%zd)", model.count] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16], NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
    [nameString appendAttributedString:countString];
    self.nameLabel.attributedText = nameString;
    [[PMDataManager manager] getPostImageWithAlbumModel:model completion:^(UIImage *postImage) {
        self.albumImageView.image = postImage;
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
