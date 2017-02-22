//
//  XLImageContainer.m
//  XLImageViewerDemo
//
//  Created by Apple on 2017/2/17.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "XLImageContainer.h"
#import "UIImageView+WebCache.h"

static CGFloat maxZoomScale = 2.5f;
static CGFloat minZoomScale = 1.0f;

@interface XLImageContainer ()<UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
    
    UIImageView *_imageView;
    
    VoidBlock _tapBlock;
}
@end

@implementation XLImageContainer

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self buildUI];
    }
    return self;
}

-(instancetype)init
{
    if (self = [super init]) {
        [self buildUI];
    }
    return self;
}

-(void)buildUI
{
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.delegate = self;
    _scrollView.maximumZoomScale = maxZoomScale;
    _scrollView.minimumZoomScale = minZoomScale;
    _scrollView.showsHorizontalScrollIndicator = false;
    _scrollView.showsVerticalScrollIndicator = false;
    [self addSubview:_scrollView];
    
    _imageView = [[UIImageView alloc] init];
    _imageView.layer.masksToBounds = true;
    [_scrollView addSubview:_imageView];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap)];
    [self addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap)];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
    
    //单击双击共存
    [singleTap requireGestureRecognizerToFail:doubleTap];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    _imageView.contentMode = _imageContentMode;
}

-(void)updateImageFrame
{
    CGRect imageFrame = _imageView.frame;
    
    if (imageFrame.size.width < self.bounds.size.width) {
        imageFrame.origin.x = (self.bounds.size.width - imageFrame.size.width)/2.0f;
    }else{
        imageFrame.origin.x = 0;
    }
    
    if (imageFrame.size.height < self.bounds.size.height) {
        imageFrame.origin.y = (self.bounds.size.height - imageFrame.size.height)/2.0f;
    }else{
        imageFrame.origin.y = 0;
    }
    
    if (!CGRectEqualToRect(_imageView.frame, imageFrame)){
        _imageView.frame = imageFrame;
    }
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    //设置ScrollView的frame
    _scrollView.frame = self.bounds;
}

-(void)setImageViewFrame
{
    //这只imageview的图片和范围
    _imageView.frame = CGRectMake(0, 0, _scrollView.bounds.size.width, [self imageViewHeight]);
    //如果图片过长则以图片的高度为高度
    if ([self imageViewHeight] < self.bounds.size.height) {
        _imageView.center = _scrollView.center;
    }
    //设置ScrollView的滚动范围
    _scrollView.contentSize = CGSizeMake(_imageView.bounds.size.width, [self imageViewHeight]);
}

-(void)setImageUrl:(NSString *)imageUrl
{
    _imageUrl = imageUrl;
    [_imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:nil options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
    } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        [self setImageViewFrame];
    }];
}


-(CGFloat)imageViewHeight
{
    UIImage *image = _imageView.image;
    CGFloat width = self.bounds.size.width;
    CGFloat height = width * image.size.height/image.size.width;
    return height;
}

#pragma mark -
#pragma mark ScrollViewDelegate
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self updateImageFrame];
}

#pragma mark -
#pragma mark 显示/隐藏动画
-(void)showLoadAnimateFromRect:(CGRect)rect
{
    _imageView.frame = rect;
    CGRect targetFrame = CGRectMake(0, 0, _scrollView.bounds.size.width, [self imageViewHeight]);
    //如果图片过长则以图片的高度为高度
    if ([self imageViewHeight] < self.bounds.size.height) {
        targetFrame.origin.y = (self.bounds.size.height - [self imageViewHeight])/2.0f;
    }
    [UIView animateWithDuration:0.35 animations:^{
        _imageView.frame = targetFrame;
    }];
    
}

-(void)showHideAnimateToRect:(CGRect)rect
{
    CGRect startRect = CGRectMake(-_scrollView.contentOffset.x + _imageView.frame.origin.x, -_scrollView.contentOffset.y + _imageView.frame.origin.y, _imageView.frame.size.width, _imageView.frame.size.height);
    _imageView.frame = startRect;
    [self addSubview:_imageView];
    [UIView animateWithDuration:0.35 animations:^{
        _imageView.frame = rect;
    }completion:^(BOOL finished) {
        _scrollView.zoomScale = minZoomScale;
        [_scrollView addSubview:_imageView];
    }];
}

#pragma mark -
#pragma mark 双击 单击方法
-(void)addTapBlock:(VoidBlock)tapBlock
{
    _tapBlock = tapBlock;
}

-(void)singleTap
{
    _tapBlock();
    NSLog(@"单击");
}

-(void)doubleTap
{
    //已经放大后 双击还原 未放大则双击放大
    CGFloat zoomScale = _scrollView.zoomScale != minZoomScale ? minZoomScale : maxZoomScale;
    [_scrollView setZoomScale:zoomScale animated:true];
}

@end
