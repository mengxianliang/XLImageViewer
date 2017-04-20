//
//  XLImageViewerCell.h
//  XLImageViewerDemo
//
//  Created by MengXianLiang on 2017/4/18.
//  Copyright © 2017年 Apple. All rights reserved.
//  用于显示图片的缩放、手势等操作

#import <UIKit/UIKit.h>

typedef void(^VoidBlock)(void);

@interface XLImageViewerCell : UICollectionViewCell

//显示网路图片
@property (nonatomic ,assign) BOOL showNetImage;
//起始位置
@property (nonatomic, assign) CGRect anchorFrame;
//是否是起始Cell
@property (nonatomic, assign) BOOL isStart;
//图片地址
@property (nonatomic, copy) NSString *imageUrl;
//imageView的ContentMode，与Superview相同
@property (nonatomic, assign) UIViewContentMode imageViewContentMode;

//保存CollectionView
@property (nonatomic, weak) UICollectionView *collectionView;

//返回回调
-(void)addHideBlockStart:(VoidBlock)start finish:(VoidBlock)finish cancle:(VoidBlock)cancle;
//显示放大动画
-(void)showEnlargeAnimation;

-(void)saveImage;

@end
