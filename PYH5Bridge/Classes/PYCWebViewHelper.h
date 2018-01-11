//
//  PYCWebViewHelper.h
//  PYH5Bridge
//
//  Created by Lijun on 2017/10/16.
//  Copyright © 2017年 Pengyuan Credit Service Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

/**
 回调函数

 @param urlString 用户传入的参数
 */
typedef void(^PYCWebViewHelperBlock)(NSString *urlString);


@protocol PYCWebViewHelperProtocol <NSObject>

@optional
/**
 用于用户自定义处理与JS的交互接口
 
 @param message <#message description#>
 */
- (void)excuteMethodWithMethodDic:(id)message;
@end


@interface PYCWebViewHelper : NSObject<WKScriptMessageHandler,PYCWebViewHelperProtocol>

/**
 用户设定的广告URL
 */
@property (nonatomic, copy) NSString *urlString;
/**
 回调函数
 */
@property (nonatomic, copy) PYCWebViewHelperBlock webViewHelperBlock;

/**
 初始化方法

 @param urlString url地址
 @param webViewHelperBlock 回调block
 @return 实例
 */
- (instancetype)initWithUrl:(NSString *)urlString webViewHelperBlock:(PYCWebViewHelperBlock)webViewHelperBlock;
/**
 增加监听JS事件
 
 @param webView webView description
 */
- (void)addScriptMessageHandlerToWebView:(id)webView webViewDelegate:(id)scriptMessageHandler;

/**
 删除事件，未删除会导致内存泄露
 */
- (void)removeScriptMessageHandler;


/**
 UIWebViewDelegate的方法，UIWebView集成时要调用此方法
 */
- (BOOL)pycWebView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
/**
  WKNavigationDelegate的方法，WKWebView集成时要调用此方法
 */
-(void)pycWebView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;

/**
 会拦截到window.open()事件.只需要我们在方法内进行处理

 */
- (WKWebView *)pyWebView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures;
@end
