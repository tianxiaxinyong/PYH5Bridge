//
//  PYUtil+FilePath.m
//  PYLibrary
//
//  Created on 16/9/21.
//  Copyright © 2016年 PYCredit. All rights reserved.
//

#import "PYCUtil+PYCFilePath.h"

@implementation PYCUtil (PYCFilePath)

#pragma mark -- 获取路径

+ (NSString *)databasePath
{
    NSString* path = [self pathWithSearchPathDirectory:NSLibraryDirectory];
    path = [path stringByAppendingPathComponent:@"database"];

    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:NSFileProtectionComplete
                                                               forKey:NSFileProtectionKey];
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:attributes error:nil];
    }

    return path;
}

+ (NSString *)libraryPath
{
    NSString* path = [self pathWithSearchPathDirectory:NSLibraryDirectory];

    return path;
}

+ (NSString *)documentPath
{
    NSString* path = [self pathWithSearchPathDirectory:NSDocumentDirectory];

    return path;
}
+ (NSString *)templatePath
{
    NSString* path = NSTemporaryDirectory();

    return path;
}
+ (NSString *)imagesTemplatePath
{
    NSString* path = NSTemporaryDirectory();
    NSString *newPath =    [path stringByAppendingString:@"images/"];
    
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:newPath isDirectory:&isDir];
    
    if ( !(isDir == YES && existed == YES) ) {
        
        // 在 Document 目录下创建一个 head 目录
        [fileManager createDirectoryAtPath:newPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return  newPath;
}

+ (NSString *)vedioTemplatePath
{
    NSString* path = NSTemporaryDirectory();
    NSString *newPath =    [path stringByAppendingString:@"vedios/"];
    
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:newPath isDirectory:&isDir];
    
    if ( !(isDir == YES && existed == YES) ) {
        
        // 在 Document 目录下创建一个 head 目录
        [fileManager createDirectoryAtPath:newPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return  newPath;
}

+ (NSString *)configPath
{
    NSString* path = [self pathWithSearchPathDirectory:NSLibraryDirectory];
    path = [path stringByAppendingPathComponent:@"config_file"];

    return path;
}

+ (NSString *)locationPath
{
    NSString* path = [self pathWithSearchPathDirectory:NSLibraryDirectory];
    path = [path stringByAppendingPathComponent:@"location"];

    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:NSFileProtectionComplete
                                                               forKey:NSFileProtectionKey];
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:attributes error:nil];
    }

    return path;
}

+ (NSString *)historyPath
{
    NSString* path = [self pathWithSearchPathDirectory:NSLibraryDirectory];
    path = [path stringByAppendingPathComponent:@"historytxt"];

    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:NSFileProtectionComplete
                                                               forKey:NSFileProtectionKey];
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:attributes error:nil];
    }

    return path;
}

+ (NSString *)pathForResrouceInDocuments:(NSString *)relativePath
{
    return [[self documentPath] stringByAppendingPathComponent:relativePath];
}

+ (NSString *)pyDBFilePath
{
    NSString * databaseName = [[[NSBundle mainBundle] bundleIdentifier] stringByAppendingPathExtension:@"sqlite"];

    return [[self databasePath] stringByAppendingPathComponent:databaseName];
}

+ (NSString *)pathWithSearchPathDirectory:(NSSearchPathDirectory)searchPathDirectory
{
    NSArray* dirs = NSSearchPathForDirectoriesInDomains(searchPathDirectory,
                                                        NSUserDomainMask,
                                                        YES);
    NSString *path = [dirs objectAtIndex:0];

    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:NSFileProtectionComplete
                                                               forKey:NSFileProtectionKey];
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:attributes error:nil];
    }
    
    return path;
}

@end
