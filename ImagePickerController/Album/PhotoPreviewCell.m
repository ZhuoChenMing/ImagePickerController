//
//  PhotoPreviewCell.m
//  ImagePickerController
//
//  Created by 酌晨茗 on 15/12/24.
//  Copyright © 2015年 酌晨茗. All rights reserved.
//

#import "PhotoPreviewCell.h"
#import "PhotoPickerModel.h"
#import "AlbumDataHandle.h"

@interface PhotoPreviewCell ()<UIScrollViewDelegate>

@property (nonatomic, assign) CGFloat aspectRatio;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation PhotoPreviewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        CGFloat width = CGRectGetWidth(self.frame);
        CGFloat height = CGRectGetHeight(self.frame);
        self.backgroundColor = [UIColor blackColor];
        
        self.scrollView = [[UIScrollView alloc] init];
        self.scrollView.frame = CGRectMake(0, 0, width, height);
        self.scrollView.bouncesZoom = YES;
        self.scrollView.maximumZoomScale = 2.5;
        self.scrollView.minimumZoomScale = 1.0;
        self.scrollView.multipleTouchEnabled = YES;
        self.scrollView.delegate = self;
        self.scrollView.scrollsToTop = NO;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.scrollView.delaysContentTouches = NO;
        self.scrollView.canCancelContentTouches = YES;
        self.scrollView.alwaysBounceVertical = NO;
        [self addSubview:_scrollView];
        
        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.500];
        _imageView.clipsToBounds = YES;
        [self.scrollView addSubview:_imageView];
  
        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        [self addGestureRecognizer:tap1];
        
        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        
        tap2.numberOfTapsRequired = 2;
        [tap1 requireGestureRecognizerToFail:tap2];
        [self addGestureRecognizer:tap2];
        
    }
    return self;
}

- (void)setModel:(PhotoPickerModel *)model {
    _model = model;
    [self.scrollView setZoomScale:1.0 animated:NO];
    
    [[AlbumDataHandle manager] getPhotoWithAsset:model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        self.imageView.image = photo;
        [self autouLayoutImageView];
    }];
}

#pragma mark - 调整图片大小
- (void)autouLayoutImageView {
    CGFloat viewWidth = CGRectGetWidth(self.frame);
    CGFloat viewHeight = CGRectGetHeight(self.frame);
    
    CGRect rect = CGRectZero;
    rect.origin = CGPointZero;
    rect.size.width = viewWidth;
    
    UIImage *image = _imageView.image;
    if (image.size.height / image.size.width > viewHeight / viewWidth) {
        rect.size.height = floor(image.size.height / (image.size.width / viewWidth));
    } else {
        CGFloat height = image.size.height / image.size.width * viewWidth;
        if (height < 1 || isnan(height)) {
            height = viewHeight;
        }
        height = floor(height);
        rect.size.height = height;
        rect.origin.y = (viewHeight - height) / 2.0;
    }
    if (rect.size.height > viewHeight && rect.size.height - viewHeight <= 1) {
        rect.size.height = viewHeight;
    }
    
    self.scrollView.contentSize = CGSizeMake(viewWidth, MAX(rect.size.height, viewHeight));
    [self.scrollView scrollRectToVisible:self.bounds animated:NO];
    self.scrollView.alwaysBounceVertical = rect.size.height <= viewHeight ? NO : YES;
    _imageView.frame = rect;
}

#pragma mark - 手势响应事件
- (void)singleTap:(UITapGestureRecognizer *)tap {
    if (self.singleTapGestureBlock) {
        self.singleTapGestureBlock();
    }
}

- (void)doubleTap:(UITapGestureRecognizer *)tap {
    if (self.scrollView.zoomScale > 1.0) {
        [self.scrollView setZoomScale:1.0 animated:YES];
    } else {
        CGPoint touchPoint = [tap locationInView:_imageView];
        CGFloat newZoomScale = self.scrollView.maximumZoomScale;
        CGFloat xsize = self.frame.size.width / newZoomScale;
        CGFloat ysize = self.frame.size.height / newZoomScale;
        [self.scrollView zoomToRect:CGRectMake(touchPoint.x - xsize / 2.0, touchPoint.y - ysize / 2.0, xsize, ysize) animated:YES];
    }
    if (self.doubleTapGestureBlock) {
        self.doubleTapGestureBlock();
    }
}

#pragma mark - UIScrollView代理
- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    CGFloat width = CGRectGetWidth(scrollView.frame);
    CGFloat height = CGRectGetHeight(scrollView.frame);
    
    CGFloat offsetX = (width > scrollView.contentSize.width) ? (width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (height > scrollView.contentSize.height) ? (height - scrollView.contentSize.height) * 0.5 : 0.0;
    self.imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}

@end
