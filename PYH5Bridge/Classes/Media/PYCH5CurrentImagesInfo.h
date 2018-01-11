//
//  PYCH5CurrentImagesInfo.h
//  PYH5Bridge
//
//  Created on 17/1/3.
//

#import <Foundation/Foundation.h>

@interface PYCH5CurrentImagesInfo : NSObject

@property (nonatomic , copy)   NSString  *action;
@property (nonatomic , assign) NSNumber *defaultDirection;
@property (nonatomic , assign) NSNumber *height;
@property (nonatomic , assign) NSNumber *thumbHeight;
@property (nonatomic , assign) NSNumber *thumbWidth;
@property (nonatomic , assign) NSNumber *width;
@property (nonatomic , copy)   NSString  *error;
@property (nonatomic , copy)   NSString  *success;

- (instancetype) initWithDictionary:(NSDictionary *) dict;

@end
