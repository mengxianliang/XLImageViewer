//
//  XLImageViewer.h
//  XLImageViewerDemo
//
//  Created by Apple on 2017/2/17.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XLImageViewer : UIView

-(void)showImages:(NSArray <NSString *>*)imageUrls index:(NSInteger)index from:(UIView*)imageView;

+(XLImageViewer*)shareInstanse;

@end
