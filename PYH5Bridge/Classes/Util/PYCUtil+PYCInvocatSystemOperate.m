//
//  PYUtil+InvocatSystemOperate.m
//  PYLibrary
//
//  Created on 16/9/21.
//  Copyright © 2016年 PYCredit. All rights reserved.
//

#import "PYCUtil+PYCInvocatSystemOperate.h"

@implementation PYCUtil (PYCInvocatSystemOperate)

+ (void)openSystemSettingOfApp {
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //code for opening settings app in iOS 8
//        if (&UIApplicationOpenSettingsURLString == NULL) {
//            return;
//        }

        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

@end
