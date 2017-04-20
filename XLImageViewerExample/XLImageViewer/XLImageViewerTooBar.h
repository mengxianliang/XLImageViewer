//
//  XLImageViewerTooBar.h
//  XLImageViewerDemo
//
//  Created by MengXianLiang on 2017/4/20.
//  Copyright © 2017年 Apple. All rights reserved.
//  可以做一下拓展、例如加入分享按钮、图片标题/简介 可以通过更改ToolBarHeight改变工具栏的高度



#import <UIKit/UIKit.h>

static CGFloat ToolBarHeight = 35.0f;

typedef void(^VoidBlock)(void);

@interface XLImageViewerTooBar : UIView

@property (nonatomic, copy) NSString *text;

-(void)addSaveBlock:(VoidBlock)saveBlock;

-(void)show;

-(void)hide;

@end
