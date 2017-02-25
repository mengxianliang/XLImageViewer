//
//  XLImageContainer.h
//  XLImageViewerDemo
//
//  Created by Apple on 2017/2/17.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^VoidBlock)(void);

typedef void(^AlphaBlock)(CGFloat alpha);

typedef void(^BoolBlock)(Boolean);

@interface XLImageContainer : UIView

@property (nonatomic,copy) NSString *imageUrl;

@property (nonatomic,copy) NSString *imagePath;

@property (nonatomic,assign) UIViewContentMode imageContentMode;

-(void)destroy;

-(void)saveImage;

-(void)addTapBlack:(VoidBlock)tapBlackBlock;

-(void)addPanBackBlockPaning:(VoidBlock)paning back:(BoolBlock)back;

-(void)showAnimateFromRect:(CGRect)rect finish:(VoidBlock)finisnBlock;

-(void)hideAnimateToRect:(CGRect)rect changeRect:(BOOL)changeRect finish:(VoidBlock)finisnBlock;

@end
