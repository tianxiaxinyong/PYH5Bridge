//
//  PYUtil+TimeManage.h
//  PYLibrary
//
//  Created on 16/9/21.
//  Copyright © 2016年 PYCredit. All rights reserved.
/**
 *  时间相关功能
 */

#import "PYCUtil.h"

@interface PYCUtil (PYCTimeManage)

#pragma mark -- 日期、时间、时间戳的字符串处理

/** 获取时间戳,return:NSString */
+ (NSString *)getTimeStampString;

/** 根据date获取时间戳，currentDate：当前date,return:NSString */
+ (NSString *)getTimeStampWithData:(NSDate *)currentDate;

/** 计算剩余显示天数，leftDate：秒级时间,return:NSString */
+ (NSString *)getLeftDateStr:(NSString *)leftdate;

/** 计算日期，day：天数,return:NSString */
+ (NSString *)getTimeDifference:(NSInteger)day;


+ (NSString *)getDateTimeStamp:(NSString *)date;

//两个日期比较
+ (NSInteger)compareDate:(NSString*)date01;

+ (NSString *)getUnixTimeStampString;


//返回当前日期字符串
+ (NSString *)dateTodateStr:(NSDate *)currentDate dateFormatter:(NSString *)formatter;
@end
