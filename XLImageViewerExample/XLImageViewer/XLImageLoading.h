//
//  XLImageLoading.h
//  LoadingDemo
//
//  Created by Apple on 2017/2/23.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XLImageLoading : UIView

//加载进度
@property (nonatomic,assign) CGFloat progress;

//提示信息
@property (nonatomic,copy) NSArray *message;

+(XLImageLoading*)showInView:(UIView *)view;

+(XLImageLoading*)showAlertInView:(UIView*)view message:(NSString*)message;

-(void)show;

-(void)hide;


@end
