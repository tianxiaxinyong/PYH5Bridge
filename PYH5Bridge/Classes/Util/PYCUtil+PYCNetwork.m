//
//  PYUtil+Network.m
//  PYH5Bridge
//
//  Created by huwei on 2017/10/13.
//  Copyright © 2017年 Pengyuan Credit Service Co., Ltd. All rights reserved.
//

#import "PYCUtil+PYCNetwork.h"
#import "AFHTTPSessionManager.h"
#import "UIImage+PYCScaleSize.h"
#import "QNUploadOption.h"
#import "QNUploadManager.h"
#import "QNResponseInfo.h"

static NSString *kTokenString               = @"token";
static NSString *kKeyString                 = @"key";
static NSString *kFileString                = @"file";
static NSString *kUrlString                 = @"url";
static NSString *kBodyString                = @"body";
static NSString *kWidthString               = @"width";
static NSString *kHeightString              = @"height";

@implementation PYCUtil (PYCNetwork)


/**
 上传数据到7牛

 @param image UIImage对象
 @param paraDic 参数
 @param maxLength 每张容许上传图片的大小的最大值
 @param progressHandler 回调block
 @param finishBlock 成功回调block
 @param failedBlock 失败回调block
 */
+ (void)upLoadImageToQiniu:(UIImage *)image
             parameterDic:(NSDictionary *)paraDic
                maxLength:(double)maxLength
          progressHandler:(void (^)(NSString *key, float percent))progressHandler
              finishBlock:(PY7NiuFinishBlock)finishBlock
              failedBlock:(PY7NiuFinishBlock)failedBlock
{
//    NSString *urlString = [paraDic objectForKey:kUrlString];
    NSString *key = [paraDic objectForKey:kKeyString];
    NSString *token = [paraDic objectForKey:kTokenString];
    NSNumber *widthNumber = [paraDic objectForKey:kWidthString];
    if (widthNumber == nil) {
        widthNumber = @0;
    }
    image = [UIImage py_resizeImage:image maxPixelSize:widthNumber.floatValue];

    NSData *data = [UIImage scaleImage:image toKb:maxLength];
    
    QNUploadOption *option =[[QNUploadOption alloc] initWithMime:nil
                                                 progressHandler:progressHandler
                                                          params:nil
                                                        checkCrc:YES
                                              cancellationSignal:nil];
    
    
    QNUploadManager *upManager = [[QNUploadManager alloc] init];
    [upManager putData:data
                   key:(key.length == 0?nil:key)
                 token:token
              complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                  if (info.error) {
                      failedBlock(info.error);
                  }
                  else
                      finishBlock(resp);
              } option:option];
}
@end
