//
//  XLImageViewer.m
//  XLImageViewerDemo
//
//  Created by Apple on 2017/2/17.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "XLImageViewer.h"
#import "XLImageContainer.h"

//图片之间的间隔
static CGFloat ImageContainMargin = 10.0f;

@interface XLImageViewer ()<UIScrollViewDelegate>
{
    //滚动的ScrollView
    UIScrollView *_scrollView;
    //用于保存图片预览对象的集合
    NSMutableArray *_containers;
    //第一次加载的位置
    NSInteger _startIndex;
    //当前滚动位置
    NSInteger _currentIndex;
    //开始加载时的图片位置
    CGRect _startRect;
    //分页图片
    UILabel *_pageLabel;
    //保存按钮
    UIButton *_saveButton;
}
@end

@implementation XLImageViewer

+(XLImageViewer*)shareInstanse{
    
    static XLImageViewer *_viewer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _viewer = [[XLImageViewer alloc] init];
    });
    return _viewer;
}

-(instancetype)init{
    
    if (self = [super init]) {
        [self buildUI];
    }
    return self;
}

-(void)buildUI{
    self.frame = [UIScreen mainScreen].bounds;
    CGRect frame = self.bounds;
    frame.size.width += ImageContainMargin;
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.frame = frame;
    _scrollView.pagingEnabled = true;
    _scrollView.showsHorizontalScrollIndicator = false;
    _scrollView.showsVerticalScrollIndicator = false;
    _scrollView.delegate = self;
    [self addSubview:_scrollView];
    
    //显示分页的label
    CGFloat viewWidth = 50.0f;
    CGFloat viewHeignt = 28.0f;
    CGFloat viewMargin = 5.0f;
    _pageLabel = [[UILabel alloc] initWithFrame:CGRectMake(viewMargin, self.bounds.size.height - viewHeignt - viewMargin, viewWidth, viewHeignt)];
    _pageLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    _pageLabel.layer.cornerRadius = 5.0f;
    _pageLabel.layer.masksToBounds = true;
    _pageLabel.textColor = [UIColor whiteColor];
    _pageLabel.font = [UIFont systemFontOfSize:16];
    _pageLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_pageLabel];
    
    //保存按钮
    _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _saveButton.frame = CGRectMake(self.bounds.size.width - viewWidth - viewMargin, self.bounds.size.height - viewHeignt - viewMargin, viewWidth, viewHeignt);
    _saveButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    _saveButton.layer.cornerRadius = 5.0f;
    _saveButton.layer.masksToBounds = true;
    _saveButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_saveButton setTitle:@"保存" forState:UIControlStateNormal];
    [_saveButton addTarget:self action:@selector(saveImageMethod) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_saveButton];
    
    _containers = [[NSMutableArray alloc] init];
    _startIndex = 0;
    _currentIndex = 0;
}

#pragma mark -
#pragma mark 加载图片方法

-(void)showNetImages:(NSArray <NSString *>*)imageUrls index:(NSInteger)index from:(UIView*)imageView{
    [self showImagesFromNet:true images:imageUrls index:index from:imageView];
}

-(void)showLocalImages:(NSArray <NSString *>*)imagePathes index:(NSInteger)index from:(UIView*)imageView{
    [self showImagesFromNet:false images:imagePathes index:index from:imageView];
}

-(void)showImagesFromNet:(BOOL)fromNet images:(NSArray*)images index:(NSInteger)index from:(UIView*)imageView
{
    _startIndex = index;
    _currentIndex = index;
    
    //清除上一次的图片容器
    [self destroyContainers];
    
    for (NSInteger i = 0; i<images.count ; i++) {
        XLImageContainer *container = [[XLImageContainer alloc] initWithFrame:CGRectMake(i * _scrollView.bounds.size.width, 0, self.bounds.size.width, self.bounds.size.height)];
        if (fromNet) {
            container.imageUrl = images[i];
        }else{
            container.imagePath = images[i];
        }
        container.imageContentMode = [self getContentViewOf:imageView];
        [container addTapBlock:^{
            [self backMethod];
        }];
        [_scrollView addSubview:container];
        [_containers addObject:container];
    }
    
    _scrollView.contentSize = CGSizeMake(images.count * _scrollView.bounds.size.width , self.bounds.size.height);
    
    _scrollView.contentOffset = CGPointMake(_startIndex * _scrollView.bounds.size.width, 0);
    
    _pageLabel.text = [NSString stringWithFormat:@"%zd/%zd",_currentIndex + 1,images.count];
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    XLImageContainer *container = _containers[_currentIndex];
    
    [UIView animateWithDuration:0.35 animations:^{
        self.backgroundColor = [UIColor blackColor];
    }completion:^(BOOL finished) {
        _pageLabel.hidden = false;
        _saveButton.hidden = false;
    }];
    
    _startRect = [imageView convertRect:imageView.bounds toView:self];
    
    [container showLoadAnimateFromRect:_startRect];
}

-(void)backMethod{
    
    _pageLabel.hidden = true;
    _saveButton.hidden = true;
    [UIView animateWithDuration:0.35 animations:^{
        self.backgroundColor = [UIColor clearColor];
        if (_currentIndex != _startIndex) {self.alpha = 0;}
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
        self.alpha = 1;
    }];
    if (_currentIndex == _startIndex) {
        XLImageContainer *container = _containers[_currentIndex];
        [container showHideAnimateToRect:_startRect];
    }
}

-(UIViewContentMode)getContentViewOf:(UIView*)view{
    
    UIViewContentMode contentMode = UIViewContentModeScaleToFill;
    if ([view isKindOfClass:[UIImageView class]]) {
        contentMode = view.contentMode;
    }else{
        for (UIView *subView in view.subviews) {
            if ([subView isKindOfClass:[UIImageView class]]) {
                contentMode = subView.contentMode;
            }else{
                for (UIView *subView2 in subView.subviews) {
                    if ([subView2 isKindOfClass:[UIImageView class]]) {
                        contentMode = subView2.contentMode;
                    }
                }
            }
        }
    }
    return contentMode;
}


#pragma mark -
#pragma mark 清除方法
-(void)destroyContainers{
    
    [_containers removeAllObjects];
    for (XLImageContainer *container in _scrollView.subviews) {
        [container destroy];
        [container removeFromSuperview];
    }
}


#pragma mark -
#pragma mark 保存图片方法
-(void)saveImageMethod{
    
    XLImageContainer *container = _containers[_currentIndex];
    [container saveImage];
}

#pragma mark -
#pragma mark ScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    _currentIndex = scrollView.contentOffset.x/scrollView.bounds.size.width;
    _pageLabel.text = [NSString stringWithFormat:@"%zd/%zd",_currentIndex + 1,_containers.count];
}

@end
