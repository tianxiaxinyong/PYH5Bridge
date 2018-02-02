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
        *isFirstSetting = YES;
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
        *isFirstSetting = YES;
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

@end
