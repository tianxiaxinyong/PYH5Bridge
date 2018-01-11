//
//  PYJSBaseWebViewModel.h
//  PYH5Bridge
//
//  Created by huwei on 2017/7/19.
//  Copyright © 2017年 pycredit.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>


//首先创建一个实现了JSExport协议的协议
@protocol PYCJSObjectProtocol <JSExport,NSObject>
@optional
/**
 调用照相
 
 @param dict 回调参数
 */
- (void)takePictureWithData:(NSDictionary *)dict;
/**
 调用选照片
 
 @param dict 回调参数
 */
- (void)selectPicWithData:(NSDictionary *)dict;
/**
 调用定位
 
 @param dict 回调参数
 */
- (void)locationWithData:(NSDictionary *)dict;
/**
 调用JS里面自定义函数
 
 @param methodDic 回调参数
 */
- (void)excuteMethodWithMethodDic:(NSDictionary *)methodDic;
@end

@interface PYCJSBaseWebViewModel : NSObject


@property (nonatomic,weak) id <PYCJSObjectProtocol> delegate;
@property (nonatomic,copy) NSArray *actionNameArr;

@property (nonatomic,weak) JSContext *context;

- (void)cleanDelegate;
//+ (instancetype)shareInstance;
@end
