//
//  PYJSResultData.m
//  gzjd
//
//  Created on 16/12/16.
//

#import "PYCJSResultData.h"
/*
 {
 args =     {
 action = actionGetAvatar;
 data =         {
 size = 200;
 };
 };
 error = bridgeJsonpError0;
 success = bridgeJsonpSuccess0;
 }
 */

@implementation PYCJSResultData
- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        NSDictionary *args = dictionary[@"args"];
        _action = [self string_safeTransform:args[@"action"]] ;
        _data = args[@"data"];
        _errorFunName =[self string_safeTransform:dictionary[@"error"] ];
        _successFunName = [self string_safeTransform:dictionary[@"success"]];
        
    }
    return self;
}

- (NSString*) string_safeTransform:(id) _object
{
    if ([_object isKindOfClass:[NSString class] ]|| [_object isKindOfClass:[NSNumber class]]) {
        return [NSString stringWithFormat:@"%@",_object];
    }
    else
    {
        return nil;
    }
    return nil;
}
@end
