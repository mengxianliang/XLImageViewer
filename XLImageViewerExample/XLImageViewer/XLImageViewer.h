//
//  XLImageViewer.h
//  XLImageViewerExample
//
//  Created by MengXianLiang on 2017/4/20.
//  Copyright © 2017年 MengXianLiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XLImageViewer : UIView

/**
 * 单利方法
 */
+(XLImageViewer*)shareInstanse;

/**
 * 显示网络图片方法
 * @param imageUrls      网络图片地址
 * @param index          显示第几张图片
 * @param imageContainer 图片容器
 */
-(void)showNetImages:(NSArray <NSString *>*)imageUrls index:(NSInteger)index fromImageContainer:(UIView*)imageContainer;

/**
 * 显示本地图片方法
 * @param imagePathes    本地图片路径
 * @param index          显示第几张图片
 * @param imageContainer 图片容器
 */
-(void)showLocalImages:(NSArray <NSString *>*)imagePathes index:(NSInteger)index fromImageContainer:(UIView*)imageContainer;

@end
