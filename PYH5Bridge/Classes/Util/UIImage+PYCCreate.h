//
//  UIImage+Create.h
//  PYLibrary
//
//  Created on 16/9/19.
//  Copyright © 2016年 PYCredit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (PYCCreate)

/** 图片由颜色值生成，color:颜色值，size：图片大小 */
+ (UIImage *)py_imageWithColor:(UIColor *)color size:(CGSize)size;

- (UIImage *)py_fixOrientation;
@end
