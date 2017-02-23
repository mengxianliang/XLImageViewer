//
//  XLImageContainer.m
//  XLImageViewerDemo
//
//  Created by Apple on 2017/2/17.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "XLImageContainer.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"

static CGFloat maxZoomScale = 2.5f;
static CGFloat minZoomScale = 1.0f;

@interface XLImageContainer ()<UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
    
    UIImageView *_imageView;
    
    VoidBlock _tapBlock;
    
    MBProgressHUD *_hud;
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

-(void)buildUI
{
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.frame = self.bounds;
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
    
    _hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    _hud.mode = MBProgressHUDModeAnnularDeterminate;
    _hud.bezelView.color = [UIColor clearColor];
    _hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    _hud.contentColor = [UIColor whiteColor];
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

-(void)setImageViewFrame
{
    if (!_imageView.image) {return;}
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
        dispatch_async(dispatch_get_main_queue(), ^{
            _hud.progress = (CGFloat)receivedSize/(CGFloat)expectedSize;
        });
    } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        [self setImageViewFrame];
        [_hud hideAnimated:true];
    }];
}

-(void)setImagePath:(NSString *)imagePath
{
    _imagePath = imagePath;
    [_hud hideAnimated:true];
    _imageView.image = [UIImage imageWithContentsOfFile:imagePath];
    [self setImageViewFrame];
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
    //如果还没加载完成网络图片则不显示动画
    if (!_imageView.image) {return;}
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
    if (!_imageView.image) {return;}
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
#pragma mark 保存图片方法
-(void)saveImage{
    if (!_imageView.image) {return;}
    UIImageWriteToSavedPhotosAlbum(_imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error != NULL) {return;}
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkmark"]];
    hud.square = YES;
    hud.label.text = @"图片存储成功";
    [hud hideAnimated:YES afterDelay:1.50f];
}

#pragma mark -
#pragma mark RecyleMethod
-(void)destroy
{
    [_imageView removeFromSuperview];
    _imageView = nil;
    
    [_hud removeFromSuperview];
    _hud = nil;
    
    [_scrollView removeFromSuperview];
    _scrollView = nil;
    
}

#pragma mark -
#pragma mark 手势方法 双击 单击 拖拽
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
