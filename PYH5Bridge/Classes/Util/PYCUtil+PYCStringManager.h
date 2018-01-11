//
//  PYUtil+StringManager.h
//  PYLibrary
//
//  Created on 16/9/21.
//  Copyright © 2016年 PYCredit. All rights reserved.
/**
 *  与业务相关的字符串处理方法
 */

#import "PYCUtil.h"

@interface PYCUtil (PYCStringManager)

#pragma mark -- url编码、译码

/** 对url进行编码,return:NSString */
+ (NSString *)urlEncodedString:(NSString *)string;

/** 对url进行译码,return:NSString */
+ (NSString *)urlDecodeString:(NSString *) string;

#pragma mark -- 字符串查找、过滤、替换、删除特殊字符等操作

/** 将手机号中间3-7的location替换成*,return:NSString */
+ (NSString *)getFormatPhoneNumber:(NSString *)phone;

/** 将身份证中间替换成*,return:NSString */
+ (NSString *)getFormatIdCard:(NSString *)idCard;

@end
