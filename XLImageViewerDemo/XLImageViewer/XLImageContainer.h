//
//  XLImageContainer.h
//  XLImageViewerDemo
//
//  Created by Apple on 2017/2/17.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^VoidBlock)(void);

@interface XLImageContainer : UIView

@property (nonatomic,copy) NSString *imageUrl;

@property (nonatomic,copy) NSString *imagePath;

@property (nonatomic,assign) UIViewContentMode imageContentMode;

-(void)destroy;

-(void)saveImage;

-(void)addTapBlock:(VoidBlock)tapBlock;

-(void)showLoadAnimateFromRect:(CGRect)rect;

-(void)showHideAnimateToRect:(CGRect)rect;

@end
