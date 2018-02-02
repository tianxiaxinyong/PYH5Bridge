//
//  PYUtil.h
//  pycredit
//
//  Created on 14-9-16.
//
//
/*
 本文件提供一些常用的工具方法，多了以后可以拆分类别出去
 */


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

#define TOP_BAR_HEIGHT 40.f
#define BOTTOM_BAR_HEIGHT (SCREEN_HEIGHT - ((SCREEN_WIDTH / 3 ) * 4 + TOP_BAR_HEIGHT))


@interface PYCUtil : NSObject

//处理http || https url
+ (NSString *) strongUrlWithUrlStr:(NSString*) urlStr;


//image
+ (UIImage *) imageCompressForWidth:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth;
+ (UIImage *) creatThumbnailByAsset:(AVURLAsset *)asset ;


///date time
+ (NSString *) timestampWithStringTime:(NSString *) stringTime;
+ (NSString *) currentTimestamp;


///
+ (NSString*) encodeBase64Data:(NSData *)data;

+ (NSString *) md5:(NSString *)string;

@end
