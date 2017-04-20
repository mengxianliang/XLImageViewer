//
//  XLImageLoading.m
//  LoadingDemo
//
//  Created by Apple on 2017/2/23.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "XLImageLoading.h"

@interface XLImageLoading ()
{
    UILabel *_loadingLabel;
    CAShapeLayer* _progressLayer;
}
@end

@implementation XLImageLoading

+(XLImageLoading*)showInView:(UIView *)view
{
    XLImageLoading *loading = [[XLImageLoading alloc] initWithFrame:view.bounds];
    [view addSubview:loading];
    return loading;
}

+(XLImageLoading*)showAlertInView:(UIView*)view message:(NSString*)message
{
    XLImageLoading *loading = [[XLImageLoading alloc] initWithFrame:view.bounds mesasge:message];
    [view addSubview:loading];
    return loading;
}


-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self buildLoadingView];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame mesasge:(NSString*)message
{
    if (self = [super initWithFrame:frame]) {
        [self buildAlertView:message];
    }
    return self;
}


-(void)buildLoadingView
{
    CGFloat viewWidth = 35.0f;
    _loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewWidth)];
    _loadingLabel.textAlignment = NSTextAlignmentCenter;
    _loadingLabel.textColor = [UIColor whiteColor];
    _loadingLabel.font = [UIFont systemFontOfSize:10.0f];
    _loadingLabel.center = self.center;
    _loadingLabel.text = @"0%";
    [self addSubview:_loadingLabel];
    
    CGFloat lineWidth = 3.0f;
    float centerX = viewWidth/2.0;
    float centerY = viewWidth/2.0;
    //半径
    float radius = (viewWidth - lineWidth)/2.0f;
    //创建贝塞尔路径
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(centerX, centerY) radius:radius startAngle:(-0.5f*M_PI) endAngle:1.5f*M_PI clockwise:YES];
    //添加背景圆环
    CAShapeLayer *backLayer = [CAShapeLayer layer];
    backLayer.frame = _loadingLabel.bounds;
    backLayer.fillColor =  [[UIColor clearColor] CGColor];
    backLayer.strokeColor  = [UIColor colorWithRed:50.0/255.0f green:50.0/255.0f blue:50.0/255.0f alpha:1].CGColor;
    backLayer.lineWidth = lineWidth;
    backLayer.path = [path CGPath];
    backLayer.strokeEnd = 1;
    [_loadingLabel.layer addSublayer:backLayer];
    //创建进度layer
    _progressLayer = [CAShapeLayer layer];
    _progressLayer.frame = _loadingLabel.bounds;
    _progressLayer.fillColor =  [[UIColor clearColor] CGColor];
    _progressLayer.strokeColor  = [[UIColor whiteColor] CGColor];
    _progressLayer.lineCap = kCALineCapRound;
    _progressLayer.lineWidth = lineWidth;
    _progressLayer.path = [path CGPath];
    _progressLayer.strokeEnd = 0;
    [_loadingLabel.layer addSublayer:_progressLayer];
}

-(void)buildAlertView:(NSString*)message
{
    CGFloat alertHeignt = 70.0f;
    CGFloat alertWidth = 120;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, alertWidth, alertHeignt)];
    view.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.5];
    view.center = self.center;
    view.layer.cornerRadius = 10.0f;
    view.layer.masksToBounds = true;
    [self addSubview:view];
    
    UIBlurEffect* effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView* effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    effectView.frame = view.bounds;
    [view addSubview:effectView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:effectView.bounds];
    label.text = message;
    label.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:69.0/255.0f alpha:1];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:16];
    [view addSubview:label];
    
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        [self removeFromSuperview];
    });
}

-(void)setProgress:(CGFloat)progress
{
    _progress = progress <= 0 ? 0 : progress;
    _progress = progress >= 1 ? 1 : progress;
    
    _loadingLabel.text = [NSString stringWithFormat:@"%.0f%%",_progress*100.0f];
    
    _progressLayer.strokeEnd = _progress;
}


-(void)show{
    self.hidden = false;
}

-(void)hide
{
    self.hidden = true;
}


@end
