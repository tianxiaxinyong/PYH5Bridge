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
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied)
    {
        return NO;
    }
    
    return YES;
}

+ (BOOL)hasCameraRights {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied)
    {
        return NO;
    }
    
    return YES;
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
