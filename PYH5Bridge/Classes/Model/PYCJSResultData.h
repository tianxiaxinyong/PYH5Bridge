//
//  PYJSResultData.h
//
//
//  Created on 16/12/16.
//

#import <Foundation/Foundation.h>

@interface PYCJSResultData : NSObject
@property (nonatomic,copy)      NSString *action;
@property (nonatomic,strong)    NSDictionary *data;
@property (nonatomic,copy)      NSString *errorFunName;///app 成功之后调用H5的方法名
@property (nonatomic,copy)      NSString *successFunName;

- (instancetype) initWithDictionary:(NSDictionary*) dictionary;
@end
