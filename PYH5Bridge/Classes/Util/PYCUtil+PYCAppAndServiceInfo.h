//
//  PYUtil+AppAndServiceInfo.h
//  PYLibrary
//
//  Created on 16/9/21.
//  Copyright © 2016年 PYCredit. All rights reserved.
//
/**
 *  app信息以及设备信息获取
 */
#import "PYCUtil.h"

@interface PYCUtil (PYCAppAndServiceInfo)

/** 获取内部版本号,return:NSString */
+ (NSString *)appVersion;

/** 获取发布版本号,return:NSString */
+ (NSString *)appBuildVersion;


/** 获取设备的标示符,return:NSString */
+ (NSString *)getDeviceNameIdentifier;

#pragma mark App Authorization Status

/** 判断App是否有访问照片权限 */
+ (BOOL)hasPhotosRights;

/** 判断App是否有访问相机权限 */
+ (BOOL)hasCameraRights;

#pragma mark -- devieceInfo
/** 屏幕宽 */
+ (CGFloat)screenWidth;

/** 屏幕宽 */
+ (CGFloat)screenHeight;
@end
