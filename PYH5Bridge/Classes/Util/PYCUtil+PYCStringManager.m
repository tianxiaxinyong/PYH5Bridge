//
//  PYUtil+StringManager.m
//  PYLibrary
//
//  Created on 16/9/21.
//  Copyright © 2016年 PYCredit. All rights reserved.


#import "PYCUtil+PYCStringManager.h"

@implementation PYCUtil (PYCStringManager)

+ (NSString*)urlEncodedString:(NSString *)string
{
    NSString * encodedString = (__bridge_transfer  NSString*) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)string, NULL, (__bridge CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8 );

    return encodedString;
}
+ (NSString *)urlDecodeString:(NSString *) string
{
    if (string)
    {
        NSMutableString *outputStr = [NSMutableString stringWithString:string];
        [outputStr replaceOccurrencesOfString:@"+"
                                   withString:@" "
                                      options:NSLiteralSearch
                                        range:NSMakeRange(0,[outputStr length])];
        return [outputStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }

    return nil;
}



+ (NSString *)getFormatPhoneNumber:(NSString *)phone
{
    NSString *phoneStr = phone;
    if( phone == nil  ||
       [phone isKindOfClass:[NSNull class]] ||
       [phone isEqualToString:@"(null)"] ||
       [phone isEqualToString:@"<null>"])
    {
        phoneStr = @"";
    }
    NSMutableString * phoneNumber = [phoneStr mutableCopy];
    if (phoneNumber.length >= 7) {
        [phoneNumber replaceCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
    }

    return phoneNumber;
}

+ (NSString *)getFormatIdCard:(NSString *)idCard
{
    NSString *idCardStr = idCard;
    if( idCardStr == nil  ||
       [idCardStr isKindOfClass:[NSNull class]] ||
       [idCardStr isEqualToString:@"(null)"] ||
       [idCardStr isEqualToString:@"<null>"])
    {
        idCardStr = @"";
    }
    NSMutableString * idCardNumber = [idCardStr mutableCopy];
    if (idCard.length >= 6)
    {
        return [self replaceStringWithOriginalStr:idCardNumber startLocation:4 lenght:idCardNumber.length -6];
    }
    return idCardNumber;
}

+ (NSString *)replaceStringWithOriginalStr:(NSString *)originalStr startLocation:(NSInteger)startLocation lenght:(NSInteger)lenght
{
    NSString *newStr = originalStr;
    for (int i = 0; i < lenght; i++) {
        NSRange range = NSMakeRange(startLocation, 1);
        newStr = [newStr stringByReplacingCharactersInRange:range withString:@"*"];
        startLocation ++;
    }
    return newStr;
}

@end
