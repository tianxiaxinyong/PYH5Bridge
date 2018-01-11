//
//  PYPostImageFile.m
//  PYH5Bridge
//
//  Created on 14/12/5.
//  Copyright (c) 2014年 PYCredit. All rights reserved.
//

#import "PYCPostImageFile.h"

@implementation PYCPostImageFile

- (void)dealloc
{
    if (_isCache)
    {
        return;
    }
    if (self.imgFilePath.length > 0) {
        [[NSFileManager defaultManager] removeItemAtPath:self.imgFilePath error:nil];
    }

}

- (instancetype)copy
{
    PYCPostImageFile *newObject = [[PYCPostImageFile alloc]init];
    newObject.imageName = self.imageName;
    newObject.imgFilePath = self.imgFilePath;
    newObject.postFinished = self.postFinished;
    newObject.imgFileSize = self.imgFileSize;
    newObject.key = self.key;
    newObject.isCache  = self.isCache;
    newObject.url = self.url;
    newObject.zipUrl = self.zipUrl;
    newObject.videoPath = self.videoPath;
    return newObject;
}

- (void)fillMetaInfo
{
    
}
@end

