//
//  UIImage+ScaleSize.h
//  PYLibrary
//
//  Created on 16/9/14.
//  Copyright © 2016年 PYCredit. All rights reserved.
//  用于扩充image的缩放方法

#import <UIKit/UIKit.h>
#import <AssetsLibrary/ALAssetRepresentation.h>

@interface UIImage (PYCScaleSize)

/** 放大/缩小image */
+ (UIImage *)py_scaleImage:(UIImage *)image toScale:(CGSize)reSize;

/** 压缩图片 */
+ (UIImage *)py_thumbnailForAsset:(ALAsset *)asset maxPixelSize:(NSUInteger)size;

/** 重置image尺寸 */
+ (UIImage *)py_resizeImage:(UIImage *)image maxPixelSize:(CGFloat)size;

/** 截取部分图像,return:UIImage */
-(UIImage*)py_getSubImage:(CGRect)rect;

/**
 压缩图片到指定文件大小
 
 @param image 待处理图片
 @param kb 图片大小
 @return 返回处理的图片
 */
+ (NSData *)scaleImage:(UIImage *)image toKb:(NSInteger)kb;
@end
