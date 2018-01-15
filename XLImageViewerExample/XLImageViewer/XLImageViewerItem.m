//
//  XLImageViewerCell.m
//  XLImageViewerDemo
//
//  Created by MengXianLiang on 2017/4/18.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "XLImageViewerItem.h"
#import "UIImageView+WebCache.h"
#import "FLAnimatedImageView.h"
#import "XLImageLoading.h"
#import "FLAnimatedImageView.h"

static CGFloat maxZoomScale = 2.5f;
static CGFloat minZoomScale = 1.0f;
//最小拖拽返回相应距离
static CGFloat minPanLength = 100.0f;

@interface XLImageViewerItem ()<UIScrollViewDelegate>
{
    //ScrollView
    UIScrollView *_scrollView;
    //ImageView
    FLAnimatedImageView *_imageView;
    //加载动画
    XLImageLoading *_loading;
    //返回方法
    VoidBlock _startHideBlock;
    VoidBlock _finishHideBlock;
    VoidBlock _cancleideBlock;
    
    //是否正在执行动画
    BOOL _isAnimating;
}
@end

@implementation XLImageViewerItem

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self buildUI];
    }
    return self;
}

-(void)buildUI{
    
    //设置ScrollView 利用ScrollView完成图片的放大功能
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.delegate = self;
    _scrollView.maximumZoomScale = maxZoomScale;
    _scrollView.minimumZoomScale = minZoomScale;
    _scrollView.showsHorizontalScrollIndicator = false;
    _scrollView.showsVerticalScrollIndicator = false;
    _scrollView.decelerationRate = 0.1f;
    [_scrollView.panGestureRecognizer addTarget:self action:@selector(scrollViewPanMethod:)];
    _scrollView.userInteractionEnabled = true;
    [self.contentView addSubview:_scrollView];
    
    _imageView = [[FLAnimatedImageView alloc] initWithFrame:_scrollView.bounds];
    _imageView.layer.masksToBounds = true;
    _imageView.userInteractionEnabled = true;
    [_scrollView addSubview:_imageView];
    
    //添加双击方法
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enlargeImageView)];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
    
    //添加单击方法
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showShrinkDownAnimation)];
    [self addGestureRecognizer:singleTap];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    //添加加载动画
    _loading = [XLImageLoading showInView:self];
    [_loading hide];
}

#pragma mark -
#pragma mark 点击方法
//双击 放大缩小
-(void)enlargeImageView{
    //已经放大后 双击还原 未放大则双击放大
    CGFloat zoomScale = _scrollView.zoomScale != minZoomScale ? minZoomScale : maxZoomScale;
    [_scrollView setZoomScale:zoomScale animated:true];
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
#pragma mark ImageView设置Frame相关方法
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

-(CGRect)imageViewFrame
{
    if (!_imageView.image) {
        return _scrollView.bounds;
    }
    UIImage *image = _imageView.image;
    CGFloat width = self.bounds.size.width;
    CGFloat height = width * image.size.height/image.size.width;
    CGFloat y = height < self.bounds.size.height ? (self.bounds.size.height - height)/2.0f : 0;
    return CGRectMake(0, y, width, height);
}

#pragma mark -
#pragma mark Setter
-(void)setImageUrl:(NSString *)imageUrl{
    _scrollView.zoomScale = minZoomScale;
    _imageUrl = imageUrl;
    //显示本地图片
    if (!_showNetImage) {
        _imageView.image = [UIImage imageWithContentsOfFile:imageUrl];
        [self setImageViewFrame];
        [_loading hide];
        return;
    }
    //显示网络图片
    [_imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:nil options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_loading show];
            _loading.progress = (CGFloat)receivedSize/(CGFloat)expectedSize;
        });
    } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        [self setImageViewFrame];
        //隐藏加载
        [_loading hide];
    }];
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

-(void)setImageViewContentMode:(UIViewContentMode)imageViewContentMode{
    _imageViewContentMode = imageViewContentMode;
    _imageView.contentMode = imageViewContentMode;
}

#pragma mark -
#pragma mark Block方法
-(void)addHideBlockStart:(VoidBlock)start finish:(VoidBlock)finish cancle:(VoidBlock)cancle{
    _startHideBlock = start;
    _finishHideBlock = finish;
    _cancleideBlock = cancle;
}

#pragma mark -
#pragma mark 显示/隐藏动画

//放大动画
-(void)showEnlargeAnimation{
    //如果还没加载完成网络图片则不显示动画
    _imageView.frame = _anchorFrame;
    _collectionView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    [UIView animateWithDuration:0.35 animations:^{
        _collectionView.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
        _imageView.frame = [self imageViewFrame];
    }completion:^(BOOL finished) {
        if (!_imageView.image) {
            [_loading show];
        }
    }];
}

//缩小动画
-(void)showShrinkDownAnimation{
    _startHideBlock();
    //如果还没加载完成网络图片则不显示动画
    if (_imageView.image) {
        CGRect startRect = CGRectMake(-_scrollView.contentOffset.x + _imageView.frame.origin.x, -_scrollView.contentOffset.y + _imageView.frame.origin.y, _imageView.frame.size.width, _imageView.frame.size.height);
        _imageView.frame = startRect;
        [self.contentView addSubview:_imageView];
    }
    //设置CollectionView透明度
    _collectionView.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
    [UIView animateWithDuration:0.35 animations:^{
        _collectionView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        if (_isStart && _imageView.image) {
            _imageView.frame = _anchorFrame;
        }else{self.alpha = 0;}
    }completion:^(BOOL finished) {
        //通知回调
        _finishHideBlock();
        _imageView.frame = [self imageViewFrame];
        self.alpha = 1;
        _scrollView.zoomScale = minZoomScale;
        [_scrollView addSubview:_imageView];
        [_scrollView setContentOffset:CGPointZero];
    }];
}

#pragma mark -
#pragma mark 拖拽返回方法


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (ABS(_scrollView.contentOffset.y) < minPanLength) {
        CGFloat alpha = 1 - ABS(_scrollView.contentOffset.y/(_scrollView.bounds.size.height));
        _collectionView.backgroundColor = [UIColor colorWithWhite:0 alpha:alpha];
    }
}

-(void)scrollViewPanMethod:(UIPanGestureRecognizer*)pan{
    if (_scrollView.zoomScale != 1.0f) {return;}
    if (_scrollView.contentOffset.y > 0) {
        _cancleideBlock();
        return;
    }
    //拖拽结束后判断位置
    if (pan.state == UIGestureRecognizerStateEnded) {
        if (ABS(_scrollView.contentOffset.y) < minPanLength) {
            _cancleideBlock();
            [UIView animateWithDuration:0.35 animations:^{
                _scrollView.contentInset = UIEdgeInsetsZero;
            }];
        }else{
            [UIView animateWithDuration:0.35 animations:^{
                //设置移除动画
                CGRect frame = _imageView.frame;
                frame.origin.y = _scrollView.bounds.size.height;
                _imageView.frame = frame;
                _collectionView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
            }completion:^(BOOL finished) {
                //先通知上层返回
                _finishHideBlock();
                //重置状态
                _imageView.frame = [self imageViewFrame];
                _scrollView.contentInset = UIEdgeInsetsZero;
            }];
        }
    }else{
        //拖拽过程中逐渐改变透明度
        _scrollView.contentInset = UIEdgeInsetsMake(-_scrollView.contentOffset.y, 0, 0, 0);
        CGFloat alpha = 1 - ABS(_scrollView.contentOffset.y/(_scrollView.bounds.size.height));
        _collectionView.backgroundColor = [UIColor colorWithWhite:0 alpha:alpha];
        _startHideBlock();
    }
}

#pragma mark -
#pragma mark 保存图片
-(void)saveImage{
    if (!_imageView.image) {return;}
    UIImageWriteToSavedPhotosAlbum(_imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error != NULL) {return;}
    [XLImageLoading showAlertInView:self message:@"图片存储成功"];
}

@end
