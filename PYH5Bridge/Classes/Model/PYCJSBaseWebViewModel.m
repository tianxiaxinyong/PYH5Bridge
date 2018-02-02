//
//  PYJSBaseWebViewModel.m
//  PYH5Bridge
//
//  Created by huwei on 2017/7/19.
//  Copyright © 2017年 pycredit.com. All rights reserved.
//

#import "PYCJSBaseWebViewModel.h"
#import <objc/runtime.h>



static NSString *const kFuncTakePicture = @"takePicture";
static NSString *const kFuncSelectPic = @"selectPic";
//TODO
static NSString *const kFuncLocation = @"getAppLocation";
static NSString *const kPOST_H5_STATS = @"POST_H5_STATS";
static NSString *const kJS_2_SERVER = @"JS_2_SERVER";
static NSString *const kPYCREDIT_BRIDGE = @"PYCREDIT_BRIDGE";


@implementation PYCJSBaseWebViewModel

- (void)setActionNameArr:(NSArray *)actionNameArrary
{
    _actionNameArr = [actionNameArrary mutableCopy];
    for (NSString *actionName in _actionNameArr)
    {
        //拍照 相册 方法默认注册实现，不参与回调。
        if ([actionName isEqualToString:kFuncTakePicture]) {
            self.context[kPYCREDIT_BRIDGE][actionName] = ^(){
                
                NSArray *args = [JSContext currentArguments];
                JSValue *jsvalue = args.firstObject;
                NSString *jsvalueStr = [jsvalue toString];
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[jsvalueStr dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
                
                if(_delegate && [_delegate respondsToSelector:@selector(takePictureWithData:)]){
                    [_delegate takePictureWithData:dict];
                }
            };
        } else if ([actionName isEqualToString:kFuncSelectPic]) {
            self.context[kPYCREDIT_BRIDGE][actionName] = ^(){
                NSArray *args = [JSContext currentArguments];
                JSValue *jsvalue = args.firstObject;
                NSString *jsvalueStr = [jsvalue toString];
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[jsvalueStr dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
                
                if(_delegate && [_delegate respondsToSelector:@selector(selectPicWithData:)]){
                    [_delegate selectPicWithData:dict];
                }
                
            };
        } else if ([actionName isEqualToString:kFuncLocation]) {
            self.context[kPYCREDIT_BRIDGE][actionName] = ^(){
                NSArray *args = [JSContext currentArguments];
                JSValue *jsvalue = args.firstObject;
                NSString *jsvalueStr = [jsvalue toString];
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[jsvalueStr dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
                
                if(_delegate && [_delegate respondsToSelector:@selector(locationWithData:)]){
                    [_delegate locationWithData:dict];
                }
                
            };
        } else {
            self.context[kPYCREDIT_BRIDGE][actionName] = ^(){
                NSArray *args = [JSContext currentArguments];
                for (JSValue *jsvalue in args)
                {
                    NSString *jsvalueStr = [jsvalue toString];
                    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:[jsvalueStr dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
                    if(_delegate && [_delegate respondsToSelector:@selector(excuteMethodWithMethodDic:)]){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [_delegate excuteMethodWithMethodDic:jsonObject];
                        });
                        
                    }
                }
            };
        }
        
        
    }
}
- (void)cleanDelegate
{
    for (NSString *actionName in _actionNameArr)
    {
       self.context[kPYCREDIT_BRIDGE][actionName] = nil;
    }
    
    
    _delegate = nil;
    _context = nil;
    _actionNameArr = nil;
    
}
- (void)dealloc
{
    NSLog(@"PYJSBaseWebViewModel dealloc");
}
@end
