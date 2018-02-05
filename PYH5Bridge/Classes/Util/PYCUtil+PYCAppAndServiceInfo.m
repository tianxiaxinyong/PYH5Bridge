//
//  PYUtil+AppAndServiceInfo.m
//  PYLibrary
//
//  Created on 16/9/21.
//  Copyright © 2016年 PYCredit. All rights reserved.
//

#import "PYCUtil+PYCAppAndServiceInfo.h"
#import <sys/utsname.h>
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import <Photos/PHPhotoLibrary.h>
#import <sys/utsname.h>

@implementation PYCUtil (PYCAppAndServiceInfo)


+ (NSString *)appVersion {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    return app_Version;
}

+ (NSString *)appBuildVersion {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_build = [infoDictionary objectForKey:@"CFBundleVersion"];
    
    return app_build;
}

+ (NSString *)getDeviceNameIdentifier
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceName = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    return deviceName;
}


+ (BOOL)hasPhotosRights {
    __block BOOL bReturn = NO;
    ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
    if (authStatus == ALAuthorizationStatusRestricted || authStatus == ALAuthorizationStatusDenied)
    {
        return NO;
    }
    else if (authStatus == AVAuthorizationStatusNotDetermined)//如果是第一次打开
    {
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized)
            {
                //用户明确许可与否，媒体需要捕获，但用户尚未授予或拒绝许可。
                bReturn = YES;
                dispatch_semaphore_signal(sema);
            }
            else{
                bReturn = NO;
                dispatch_semaphore_signal(sema);
            } }];
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    else
        bReturn = YES;
    
    return bReturn;
}

+ (BOOL)hasCameraRights:(BOOL *)isFirstSetting {
    
    __block BOOL bReturn = NO;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied)
    {
        return NO;
    }
    else if (authStatus == AVAuthorizationStatusNotDetermined)//如果是第一次打开
    {
        if (isFirstSetting) {
            *isFirstSetting = YES;
        }
        
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if(granted){//点击允许访问时调用
                //用户明确许可与否，媒体需要捕获，但用户尚未授予或拒绝许可。
                bReturn = YES;
                dispatch_semaphore_signal(sema);
            }
            else {
                bReturn = NO;
                dispatch_semaphore_signal(sema);
            }
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    else
        bReturn = YES;
    
    return bReturn;
}

/**
 麦克风权限

 @return <#return value description#>
 */
+ (BOOL)hasAudioRights:(BOOL *)isFirstSetting {
    
    __block BOOL bReturn = NO;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied)
    {
        return NO;
    }
    else if (authStatus == AVAuthorizationStatusNotDetermined)//如果是第一次打开
    {
        if (isFirstSetting) {
            *isFirstSetting = YES;
        }
        
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {//麦克风权限
            if(granted){//点击允许访问时调用
                //用户明确许可与否，媒体需要捕获，但用户尚未授予或拒绝许可。
                bReturn = YES;
                dispatch_semaphore_signal(sema);
            }
            else {
                bReturn = NO;
                dispatch_semaphore_signal(sema);
            }
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    else
        bReturn = YES;
    
    return bReturn;
}

+ (CGFloat) screenWidth
{
    return [UIScreen mainScreen].bounds.size.width;
}

+ (CGFloat) screenHeight
{
    return [UIScreen mainScreen].bounds.size.height;
}

/**
 手机类型

 @return 手机类型
 */
+ (NSString *)iphoneType {
    
    //需要导入头文件：#import <sys/utsname.h>
    
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString*platform = [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding];
    
    if([platform isEqualToString:@"iPhone1,1"])
        return @"iPhone 2G";
    if([platform isEqualToString:@"iPhone1,2"])
        return @"iPhone 3G";
    if([platform isEqualToString:@"iPhone2,1"])
        return @"iPhone 3GS";
    if([platform isEqualToString:@"iPhone3,1"])
        return @"iPhone 4";
    if([platform isEqualToString:@"iPhone3,2"])
        return @"iPhone 4";
    if([platform isEqualToString:@"iPhone3,3"])
        return @"iPhone 4";
    if([platform isEqualToString:@"iPhone4,1"])
        return @"iPhone 4S";
    if([platform isEqualToString:@"iPhone5,1"])
        return @"iPhone 5";
    if([platform isEqualToString:@"iPhone5,2"]) return@"iPhone 5";
    if([platform isEqualToString:@"iPhone5,3"]) return@"iPhone 5c";
    if([platform isEqualToString:@"iPhone5,4"]) return@"iPhone 5c";
    if([platform isEqualToString:@"iPhone6,1"]) return@"iPhone 5s";
    if([platform isEqualToString:@"iPhone6,2"]) return@"iPhone 5s";
    if([platform isEqualToString:@"iPhone7,1"]) return@"iPhone 6 Plus";
    if([platform isEqualToString:@"iPhone7,2"]) return@"iPhone 6";
    if([platform isEqualToString:@"iPhone8,1"]) return@"iPhone 6s";
    if([platform isEqualToString:@"iPhone8,2"]) return@"iPhone 6s Plus";
    if([platform isEqualToString:@"iPhone8,4"]) return@"iPhone SE";
    if([platform isEqualToString:@"iPhone9,1"]) return@"iPhone 7";
    if([platform isEqualToString:@"iPhone9,2"]) return@"iPhone 7 Plus";
    if([platform isEqualToString:@"iPhone10,1"]) return@"iPhone 8";
    if([platform isEqualToString:@"iPhone10,4"]) return@"iPhone 8";
    if([platform isEqualToString:@"iPhone10,2"]) return@"iPhone 8 Plus";
    if([platform isEqualToString:@"iPhone10,5"]) return@"iPhone 8 Plus";
    if([platform isEqualToString:@"iPhone10,3"]) return@"iPhone X";
    if([platform isEqualToString:@"iPhone10,6"]) return@"iPhone X";
    if([platform isEqualToString:@"iPod1,1"]) return@"iPod Touch 1G";
    if([platform isEqualToString:@"iPod2,1"]) return@"iPod Touch 2G";
    if([platform isEqualToString:@"iPod3,1"]) return@"iPod Touch 3G";
    if([platform isEqualToString:@"iPod4,1"]) return@"iPod Touch 4G";
    if([platform isEqualToString:@"iPod5,1"]) return@"iPod Touch 5G";
    if([platform isEqualToString:@"iPad1,1"]) return@"iPad 1G";
    if([platform isEqualToString:@"iPad2,1"]) return@"iPad 2";
    if([platform isEqualToString:@"iPad2,2"]) return@"iPad 2";
    if([platform isEqualToString:@"iPad2,3"]) return@"iPad 2";
    if([platform isEqualToString:@"iPad2,4"]) return@"iPad 2";
    if([platform isEqualToString:@"iPad2,5"]) return@"iPad Mini 1G";
    if([platform isEqualToString:@"iPad2,6"]) return@"iPad Mini 1G";
    if([platform isEqualToString:@"iPad2,7"]) return@"iPad Mini 1G";
    if([platform isEqualToString:@"iPad3,1"]) return@"iPad 3";
    if([platform isEqualToString:@"iPad3,2"]) return@"iPad 3";
    if([platform isEqualToString:@"iPad3,3"]) return@"iPad 3";
    if([platform isEqualToString:@"iPad3,4"]) return@"iPad 4";
    if([platform isEqualToString:@"iPad3,5"]) return@"iPad 4";
    if([platform isEqualToString:@"iPad3,6"]) return@"iPad 4";
    if([platform isEqualToString:@"iPad4,1"]) return@"iPad Air";
    if([platform isEqualToString:@"iPad4,2"]) return@"iPad Air";
    if([platform isEqualToString:@"iPad4,3"]) return@"iPad Air";
    if([platform isEqualToString:@"iPad4,4"]) return@"iPad Mini 2G";
    if([platform isEqualToString:@"iPad4,5"]) return@"iPad Mini 2G";
    if([platform isEqualToString:@"iPad4,6"]) return@"iPad Mini 2G";
    if([platform isEqualToString:@"iPad4,7"]) return@"iPad Mini 3";
    if([platform isEqualToString:@"iPad4,8"]) return@"iPad Mini 3";
    if([platform isEqualToString:@"iPad4,9"]) return@"iPad Mini 3";
    if([platform isEqualToString:@"iPad5,1"]) return@"iPad Mini 4";
    if([platform isEqualToString:@"iPad5,2"]) return@"iPad Mini 4";
    if([platform isEqualToString:@"iPad5,3"]) return@"iPad Air 2";
    if([platform isEqualToString:@"iPad5,4"]) return@"iPad Air 2";
    if([platform isEqualToString:@"iPad6,3"]) return@"iPad Pro 9.7";
    if([platform isEqualToString:@"iPad6,4"]) return@"iPad Pro 9.7";
    if([platform isEqualToString:@"iPad6,7"]) return@"iPad Pro 12.9";
    if([platform isEqualToString:@"iPad6,8"]) return@"iPad Pro 12.9";
    if([platform isEqualToString:@"i386"]) return@"iPhone Simulator";
    if([platform isEqualToString:@"x86_64"]) return@"iPhone Simulator";
    
    return platform;
    
}
@end
