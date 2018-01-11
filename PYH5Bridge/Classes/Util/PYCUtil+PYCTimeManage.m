//
//  PYUtil+TimeManage.m
//  PYLibrary
//
//  Created on 16/9/21.
//  Copyright © 2016年 PYCredit. All rights reserved.
//

#import "PYCUtil+PYCTimeManage.h"

@implementation PYCUtil (PYCTimeManage)

+ (NSString *)getTimeStampString
{
    double timeStamp = [[NSDate date] timeIntervalSince1970];
    NSMutableString * result = [NSMutableString stringWithFormat:@"%f",timeStamp];
    [result deleteCharactersInRange:[result rangeOfString:@"."]];

    return result;
}

+ (NSString *)getUnixTimeStampString
{
    double timeStamp = [[NSDate date] timeIntervalSince1970];
    NSMutableString * result = [NSMutableString stringWithFormat:@"%f",timeStamp/1000];
    [result deleteCharactersInRange:[result rangeOfString:@"."]];
    
    return result;
}

+ (NSString *)getTimeStampWithData:(NSDate *)currentDate
{
    double timeStamp = [currentDate timeIntervalSince1970];
    NSMutableString * result = [NSMutableString stringWithFormat:@"%.3f",timeStamp/1000];
    [result deleteCharactersInRange:[result rangeOfString:@"."]];

    return result;
}

+ (NSString *)getDateTimeStamp:(NSString *)date

{
    NSDateFormatter *dateFomatter = [[NSDateFormatter alloc] init];
    dateFomatter.dateFormat = @"yyyy-MM-dd";
    NSDate *expireDate = [dateFomatter dateFromString:date];
    
    double timeStamp = [expireDate timeIntervalSince1970];
    NSMutableString * result = [NSMutableString stringWithFormat:@"%.3f",timeStamp];
    [result deleteCharactersInRange:[result rangeOfString:@"."]];

    return result;
}

+ (NSString *)getLeftDateStr:(NSString *)leftdate
{
    NSString *str = @"";
    NSInteger oneTime = 24*60*60;
    if ( [leftdate integerValue]/oneTime == 0)
    {
        str = @"小于1天";
    }
    else
    {
        if ([leftdate integerValue]%oneTime == 0)
        {
            str = [NSString stringWithFormat:@"%ld天", (long)[leftdate integerValue]/oneTime];
        }
        else
        {
            str = [NSString stringWithFormat:@"%ld天", (long)[leftdate integerValue]/oneTime + 1];
        }
    }

    return str;
}

+ (NSString *)getTimeDifference:(NSInteger)day
{
    NSDate *date = [NSDate date];
    NSTimeInterval dayinterval = 60 * 60 * 24 * day;
    NSDate *localeDate = [date initWithTimeInterval:dayinterval sinceDate:date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [dateFormatter stringFromDate:localeDate];

    return dateString;
}


//与当前日期相差多少天
+ (NSInteger)compareDate:(NSString*)date01
{
    NSInteger ci;
    
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localDate = [date  dateByAddingTimeInterval: interval];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *dt1 = [df dateFromString:date01];
    NSComparisonResult result = [dt1 compare:localDate];
    switch (result)
    {
            //比date01大
        case NSOrderedAscending:
            ci=1;
            break;
            //比date01小
        case NSOrderedDescending:
            ci=-1;
            break;
           
        case NSOrderedSame:
            ci=0;
            break;
        default:
            break;
    }
    return ci;
}



+ (NSString *)dateTodateStr:(NSDate *)currentDate dateFormatter:(NSString *)formatter;
{
    NSDateFormatter* formate=[[NSDateFormatter alloc]init];
    [formate setDateFormat:formatter];
    return [formate stringFromDate:currentDate];
}

@end
