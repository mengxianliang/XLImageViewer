//
//  XLImageContainer.m
//  XLImageViewerDemo
//
//  Created by Apple on 2017/2/17.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "XLImageContainer.h"
#import "UIImageView+WebCache.h"
#import "XLImageLoading.h"

static CGFloat maxZoomScale = 2.5f;
static CGFloat minZoomScale = 1.0f;
//最小拖拽返回相应距离
static CGFloat minPanLength = 100.0f;

@interface XLImageContainer ()<UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
    
    UIImageView *_imageView;
    
    VoidBlock _tapBackBlock;
    
    XLImageLoading *_loading;
    
    VoidBlock _paningBlock;
    
    BoolBlock _panBackBlock;
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
    _scrollView.decelerationRate = 0.1f;
    [_scrollView.panGestureRecognizer addTarget:self action:@selector(scrollHandlePan:)];
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
    
    _loading = [XLImageLoading showInView:self];
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
    _imageView.frame = [self imageViewFrame];
    //设置ScrollView的滚动范围
    
    
    CGFloat height = [self imageViewFrame].size.height > _scrollView.bounds.size.height ? [self imageViewFrame].size.height : _scrollView.bounds.size.height + 1;
    _scrollView.contentSize = CGSizeMake(_imageView.bounds.size.width, height);
}

-(void)setImageUrl:(NSString *)imageUrl
{
    _imageUrl = imageUrl;
    [_imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:nil options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _loading.progress = (CGFloat)receivedSize/(CGFloat)expectedSize;
        });
    } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        [self setImageViewFrame];
        //隐藏加载
        [_loading hide];
    }];
}

-(void)setImagePath:(NSString *)imagePath
{
    _imagePath = imagePath;
    //隐藏加载
    [_loading hide];
    _imageView.image = [UIImage imageWithContentsOfFile:imagePath];
    [self setImageViewFrame];
}

-(CGRect)imageViewFrame
{
    UIImage *image = _imageView.image;
    CGFloat width = self.bounds.size.width;
    CGFloat height = width * image.size.height/image.size.width;
    CGFloat y = height < self.bounds.size.height ? (self.bounds.size.height - height)/2.0f : 0;
    return CGRectMake(0, y, width, height);
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

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    if (scale != 1) {return;}
    CGFloat height = [self imageViewFrame].size.height > _scrollView.bounds.size.height ? [self imageViewFrame].size.height : _scrollView.bounds.size.height + 1;
    _scrollView.contentSize = CGSizeMake(_imageView.bounds.size.width, height);
}

#pragma mark -
#pragma mark 显示/隐藏动画
-(void)showAnimateFromRect:(CGRect)rect finish:(VoidBlock)finisnBlock
{
    //如果还没加载完成网络图片则不显示动画
    _imageView.frame = rect;
    self.superview.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    [UIView animateWithDuration:0.35 animations:^{
        self.superview.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
        if (_imageView.image) {
            _imageView.frame = [self imageViewFrame];
        }
    }completion:^(BOOL finished) {
        finisnBlock();
    }];
}

-(void)hideAnimateToRect:(CGRect)rect changeRect:(BOOL)changeRect finish:(VoidBlock)finisnBlock;
{
    if (_imageView.image) {
        CGRect startRect = CGRectMake(-_scrollView.contentOffset.x + _imageView.frame.origin.x, -_scrollView.contentOffset.y + _imageView.frame.origin.y, _imageView.frame.size.width, _imageView.frame.size.height);
        _imageView.frame = startRect;
        [self addSubview:_imageView];
    }
    [UIView animateWithDuration:0.35 animations:^{
        if (changeRect && _imageView.image) {
            _imageView.frame = rect;
            self.superview.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        }else{
            self.superview.alpha = 0;
        }
    }completion:^(BOOL finished) {
        finisnBlock();
        self.superview.alpha = 1;
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
    [XLImageLoading showAlertInView:self message:@"图片存储成功"];
}

#pragma mark -
#pragma mark RecyleMethod
-(void)destroy
{
    [_imageView removeFromSuperview];
    _imageView = nil;
    
    [_loading removeFromSuperview];
    _loading = nil;
    
    [_scrollView removeFromSuperview];
    _scrollView = nil;
    
}

#pragma mark -
#pragma mark 手势方法 双击 单击 拖拽
-(void)addTapBlack:(VoidBlock)tapBlackBlock
{
    _tapBackBlock = tapBlackBlock;
}

-(void)singleTap
{
    _tapBackBlock();
}

-(void)doubleTap
{
    //已经放大后 双击还原 未放大则双击放大
    CGFloat zoomScale = _scrollView.zoomScale != minZoomScale ? minZoomScale : maxZoomScale;
    [_scrollView setZoomScale:zoomScale animated:true];
}

#pragma mark -
#pragma mark ScrollView拖拽方法

-(void)addPanBackBlockPaning:(VoidBlock)paning back:(BoolBlock)back
{
    _paningBlock = paning;
    _panBackBlock = back;
}

-(void)scrollHandlePan:(UIPanGestureRecognizer*)pan
{
    if (_scrollView.zoomScale != 1.0f) {return;}
    if (_scrollView.contentOffset.y > 0) {return;}
    
    if (pan.state == UIGestureRecognizerStateEnded) {
        if (ABS(_scrollView.contentOffset.y) < minPanLength) {
            _panBackBlock(false);
            [UIView animateWithDuration:0.35 animations:^{
                _scrollView.contentInset = UIEdgeInsetsZero;
            }];
        }else{
            [UIView animateWithDuration:0.35 animations:^{
                CGRect frame = _imageView.frame;
                frame.origin.y = _scrollView.bounds.size.height;
                _imageView.frame = frame;
                self.superview.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
            }completion:^(BOOL finished) {
                _panBackBlock(true);
            }];
        }
    }else{
        _paningBlock();
        _scrollView.contentInset = UIEdgeInsetsMake(-_scrollView.contentOffset.y, 0, 0, 0);
        CGFloat alpha = 1 - ABS(_scrollView.contentOffset.y/(_scrollView.bounds.size.height));
        self.superview.backgroundColor = [UIColor colorWithWhite:0 alpha:alpha];
    }
}

@end
