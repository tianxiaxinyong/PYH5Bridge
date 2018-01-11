//
//  PYUtil+FilePath.h
//  PYLibrary
//
//  Created on 16/9/21.
//  Copyright © 2016年 PYCredit. All rights reserved.
/**
 *  文件路径
 */

#import "PYCUtil.h"

@interface PYCUtil (PYCFilePath)

/** 数据基本路径,return:NSString */
+ (NSString *)databasePath;

/** library文件夹路径,return:NSString */
+ (NSString *)libraryPath;

/** document文件夹路径,return:NSString */
+ (NSString *)documentPath;

/** 临时文件路径,return:NSString */
+ (NSString *)templatePath;

/** 临时文件路径,return:NSString */
+ (NSString *)imagesTemplatePath;

/** 临时视频路径,return:NSString */
+ (NSString *)vedioTemplatePath;

/** library文件夹下的location路径,return:NSString */
+ (NSString *)locationPath;

/** library文件夹下的historytxt路径文件夹路径,return:NSString */
+ (NSString *)historyPath;

/** document里面文件的路径,return:NSString */
+ (NSString *)pathForResrouceInDocuments:(NSString *)relativePath;

// 数据库路径
+ (NSString *)pyDBFilePath;

/** 配置文件路径,return:NSString */
+ (NSString *)configPath;

+ (NSString *)pathWithSearchPathDirectory:(NSSearchPathDirectory)searchPathDirectory;

@end
