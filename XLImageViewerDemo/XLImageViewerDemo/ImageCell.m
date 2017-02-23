//
//  TestCell.m
//  XLImageViewerDemo
//
//  Created by Apple on 2017/2/21.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "ImageCell.h"
#import "UIImageView+WebCache.h"

@interface ImageCell ()
{
    UIImageView *_imageView;
}
@end

@implementation ImageCell

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self buildUI];
    }
    return self;
}

-(void)buildUI
{
    _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.layer.masksToBounds = true;
    [self.contentView addSubview:_imageView];
}


-(void)setImageUrl:(NSString *)imageUrl
{
    _imageUrl = imageUrl;
    [_imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"PlaceHolder"]];
}

-(void)setImagePath:(NSString *)imagePath
{
    _imagePath = imagePath;
    _imageView.image = [UIImage imageWithContentsOfFile:imagePath];
}

@end
