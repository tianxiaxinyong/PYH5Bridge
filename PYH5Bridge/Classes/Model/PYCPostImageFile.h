//
//  PYPostImageFile.h
//  PYH5Bridge
//
//  Created on 14/12/5.
//  Copyright (c) 2014年 PYCredit. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define ZipImageKeySuffix @"-smallImage"

@interface PYCPostImageFile : NSObject

@property (nonatomic ,copy) NSString *imageName;
@property (nonatomic, copy) NSString *imgFilePath;     // 文件地址
@property (nonatomic, assign) BOOL postFinished;         // 上传成功
@property (nonatomic, assign) float imgFileSize;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, assign) BOOL isCache;              //是否使用缓存
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy)  NSString *zipUrl;
@property (nonatomic , strong) NSDictionary *meta;//元信息
@property (nonatomic, copy) NSString *videoPath;     // 视频地址
@property (nonatomic, strong) UIImage *image; //已经在内存中的图片对象
- (instancetype)copy;

//需要手动调用填充meta信息
- (void) fillMetaInfo;

@end
