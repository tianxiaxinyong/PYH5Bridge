//
//  PYUtil.m
//  pycredit
//
//  Created on 14-9-16.
//
//

#import "PYCUtil.h"
#import <CommonCrypto/CommonDigest.h>


@implementation PYCUtil

#pragma mark - NSString

+ (NSString *)strongUrlWithUrlStr:(NSString *)urlStr
{
    
    NSParameterAssert(urlStr);
    if (urlStr)
    {
        if ([urlStr hasPrefix:@"http://"] ||
            [urlStr hasPrefix:@"https://"] ||
            [urlStr hasPrefix:@"weixin://"] ||
            [urlStr hasPrefix:@"alipay://"])
        {
            /*由于这里的url 变化不可测，故只截取参数部分进行UTF-8编码处理，这样后台有更多的可操作性*/
            
            //根据参数编制 ？分割url
            NSArray *urlInfoArray = [urlStr  componentsSeparatedByString:@"?"];
            
            //url 原串
            NSString *urlWithOutParameters = urlInfoArray[0];
            
            //utf-8 编码后的参数串
            NSMutableString *urlParameters = [NSMutableString string];
            if (urlInfoArray.count > 1) {
                [urlInfoArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (idx != 0) {
                        [urlParameters appendString:obj];
                    }
                }];
            }
            NSString *utf8UrlParameters = [urlParameters stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            //处理后合并为新的url
            NSString * urlStr = [[NSString alloc]initWithFormat:@"%@?%@",urlWithOutParameters,utf8UrlParameters];
            return urlStr;
        }
    }
    return @"";
}

//指定宽度按比例缩放
+(UIImage *) imageCompressForWidth:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth{
    
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = defineWidth;
    CGFloat targetHeight = height / (width / targetWidth);
    CGSize size = CGSizeMake(targetWidth, targetHeight);
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
    if(CGSizeEqualToSize(imageSize, size) == NO){
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        }
        else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        if(widthFactor > heightFactor){
            
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
            
        }else if(widthFactor < heightFactor){
            
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(size);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil){
        
        NSLog(@"scale image fail");
    }
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)creatThumbnailByAsset:(AVURLAsset *)asset {
    
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    gen.appliesPreferredTrackTransform = YES;
    
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    
    NSError *error = nil;
    
    CMTime actualTime;
    
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    
    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
    
    CGImageRelease(image);
    
    return thumb;
    
}

//2017:01:03 14:22:56   YYYY:MM:dd HH:mm:ss
+(NSString *)timestampWithStringTime:(NSString *) stringTime
{
    //获取系统是24小时制或者12小时制
    NSString *formatStringForHours = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
    NSRange containsA = [formatStringForHours rangeOfString:@"a"];
    BOOL hasAMPM = containsA.location != NSNotFound;
    //hasAMPM==TURE为12小时制，否则为24小时制
    
    NSDateFormatter *inputFormatter= [[NSDateFormatter alloc] init] ;
    
    if (hasAMPM) {
        [inputFormatter setDateFormat:@"YYYY:MM:dd hh:mm:ss"];
    }
    else
    {
        [inputFormatter setDateFormat:@"YYYY:MM:dd HH:mm:ss"];
    }
    
    NSDate * inputDate = [inputFormatter dateFromString:stringTime];
    
    //    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[inputDate timeIntervalSince1970] * 1000];
    
    NSTimeInterval nowtime = [inputDate timeIntervalSince1970]*1000;
    
    long long theTime = [[NSNumber numberWithDouble:nowtime] longLongValue];
    
    NSString *timeSp = [NSString stringWithFormat:@"%llu",theTime];
    
    return  timeSp;
}

+ (NSString *) currentTimestamp
{
    //    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970] * 1000];
    
    NSTimeInterval nowtime = [[NSDate date] timeIntervalSince1970]*1000;
    
    long long theTime = [[NSNumber numberWithDouble:nowtime] longLongValue];
    
    NSString *timeSp = [NSString stringWithFormat:@"%llu",theTime];
    
    return timeSp;
}

+ (NSString*) encodeBase64Data:(NSData *)data
{
    data = [data base64EncodedDataWithOptions:0];
    NSString *base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return base64String;
}

+ (NSString *)md5:(NSString *)string
{
    NSString *ret;
    if (string != nil) {
        const char *cStr = [string UTF8String];
        unsigned char result[32] = {0};
        CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
        ret = [NSString stringWithFormat:
               @"%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x",
               result[0],result[1],result[2],result[3],
               result[4],result[5],result[6],result[7],
               result[8],result[9],result[10],result[11],
               result[12],result[13],result[14],result[15],
               result[16], result[17],result[18], result[19],
               result[20], result[21],result[22], result[23],
               result[24], result[25],result[26], result[27],
               result[28], result[29],result[30], result[31]];
    }
    return ret;
}


@end
