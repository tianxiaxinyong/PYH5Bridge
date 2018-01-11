//
//  PYUtil+Network.h
//  PYH5Bridge
//
//  Created by huwei on 2017/10/13.
//  Copyright © 2017年 Pengyuan Credit Service Co., Ltd. All rights reserved.
//

#import "PYCUtil.h"
#import "QNUploadOption.h"
#import "QNUploadManager.h"
#import "QNResponseInfo.h"


typedef void(^PY7NiuFinishBlock)(id result);
/**
 网络相关类
 */
@interface PYCUtil (PYCNetwork)

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
               failedBlock:(PY7NiuFinishBlock)failedBlock;
@end
