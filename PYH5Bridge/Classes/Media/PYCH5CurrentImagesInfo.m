//
//  PYCH5CurrentImagesInfo.m
//  PYH5Bridge
//
//  Created on 17/1/3.
//

#import "PYCH5CurrentImagesInfo.h"

@implementation PYCH5CurrentImagesInfo

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        
        NSDictionary *args = dict[@"args"];
        NSDictionary *data = args[@"data"];
        
        _action = [args objectForKey:@"action"];
        _defaultDirection = [data objectForKey:@"defaultDirection"];
        _height = [data objectForKey:@"height"];
        _thumbHeight = [data objectForKey:@"thumbHeight"];
        _thumbWidth = [data objectForKey:@"thumbWidth"];
        _width = [data objectForKey:@"width"];
        _error = [dict objectForKey:@"error"];
        _success = [dict objectForKey:@"success"];
    }
    return self;
}

@end
