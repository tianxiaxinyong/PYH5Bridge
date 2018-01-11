//
//  PYCWebViewHelper.m
//  PYH5Bridge
//
//  Created by Lijun on 2017/10/16.
//  Copyright © 2017年 Pengyuan Credit Service Co., Ltd. All rights reserved.
//

#import "PYCWebViewHelper.h"
#import "PYCH5CurrentImagesInfo.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "PYCH5IOImageHelper.h"
#import "PYCUtil.h"
#import "PYCJSResultData.h"
#import "UIImage+PYCScaleSize.h"
#import "PYCUtil+PYCFilePath.h"
#import "PYCUtil+PYCTimeManage.h"
#import "PYCPostImageFile.h"
#import "UIView+Toast.h"
#import "PYCH5CurrentImagesInfo.h"
#import "PYCH5IOImageHelper.h"
#import "JZAlbumViewController.h"
#import "PYCUtil+PYCAppAndServiceInfo.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "PYCUtil+PYCInvocatSystemOperate.h"
#import "PYCUtil+PYCStringManager.h"
#import "MBProgressHUD.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "PYCUtil+PYCNetwork.h"
#import "PYCJSBaseWebViewModel.h"

@interface PYCWebViewHelper ()<PYCH5IOImageHelperProtocol,WKNavigationDelegate,UIWebViewDelegate,PYCJSObjectProtocol>

@property (nonatomic, copy) NSArray *jsActionNameArr;
@property (nonatomic, weak) id scriptMessageHandler;
///内部使用的webView
@property (nonatomic, readonly) id realWebView;
///是否正在使用 UIWebView
@property (nonatomic, readonly) BOOL                  usingUIWebView;
@property (nonatomic,strong) JSContext                *context;
@property (nonatomic,strong)  PYCH5CurrentImagesInfo   *h5CurrentImagesInfo;
@property (nonatomic, strong) PYCH5IOImageHelper       *h5IOImageHelper;
@property (nonatomic, strong) NSMutableDictionary <NSString *, PYCJSResultData *>    *resultDataDictionary;
@property (strong, nonatomic) PYCJSBaseWebViewModel *viewModel;
typedef void(^addReferrInReuqstBlock)(NSURLRequest *request);
typedef void(^successOpenPaymentApp)(void);

/**
 增加referrBlock
 */
@property (nonatomic, copy) addReferrInReuqstBlock requestBlock;


/**
 成功打开第三方支付block
 */
@property (nonatomic, copy) successOpenPaymentApp successBlock;
@end

@implementation PYCWebViewHelper
- (void)dealloc
{
    [_viewModel cleanDelegate];
    NSLog(@"PYCWebViewHelper dealloc .....");
}
/**
 初始化方法
 
 @param usrString url地址
 @param webViewHelperBlock 回调block
 @return 实例
 */
- (instancetype)initWithUrl:(NSString *)usrString webViewHelperBlock:(PYCWebViewHelperBlock)webViewHelperBlock
{
    if (self = [super init]) {
        _urlString = usrString;
        _webViewHelperBlock = webViewHelperBlock;
    }
    return self;
}
/**
 增加监听JS事件
 
 @param webView webView description
 */
- (void)addScriptMessageHandlerToWebView:(id)webView webViewDelegate:(id)scriptMessageHandler
{
    _realWebView = webView;
    if ([webView isKindOfClass:[UIWebView class]]) {
        _usingUIWebView = YES;
    }
    else
    {
        _usingUIWebView = NO;
    }
    
    [self setupWebView:webView];
    _scriptMessageHandler = scriptMessageHandler;
}
/**
 删除事件，未删除会导致内存泄露
 */
- (void)removeScriptMessageHandler
{
    [self removeJSScripToWebView];
}
- (NSArray *)jsActionNameArr {
    if (_jsActionNameArr == nil) {
         _jsActionNameArr = [[NSArray alloc] initWithObjects:@"cameraGetImage", @"previewImage", @"uploadImage", @"openPayApp",@"getAdBannerURL",@"clickAd", nil];
    }
    
    return _jsActionNameArr;
}
- (PYCH5IOImageHelper *)h5IOImageHelper
{
    if (_h5IOImageHelper == nil) {
        _h5IOImageHelper = [[PYCH5IOImageHelper alloc] initWithDelegate:self];
    }
    return _h5IOImageHelper;
}

/**
 用于显示load界面及弹出界面
 
 @return 界面控制器
 */
- (UIViewController *)showHUDParentViewController
{
    return _scriptMessageHandler;
}

- (void) setupWebView:(id)webView
{
    [self addJSActionToWebView:webView];
}

- (void) dispatchScriptMessage:(id)message
{
    WKScriptMessage *wkMessage = message;
    
    if ([wkMessage.body isKindOfClass:[NSString class]])
    {
        //执行各种js方法
        NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:[wkMessage.body dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        
        //执行代理类方法
        if (_scriptMessageHandler) {
            [_scriptMessageHandler performSelectorOnMainThread:@selector(excuteMethodWithMethodDic:)
                                                    withObject:jsonObject
                                                 waitUntilDone:NO];
        }
        else
            [self excuteMethodWithMethodDic:jsonObject];
    }
    
}

#pragma mark ------ 处理JS直接调用OC原生的方法开始------------------
- (void) addJSActionToWebView:(id)webView
{
    if ([webView isKindOfClass:[WKWebView class]])
    {
        WKWebView *wkWebView = (WKWebView *)webView;
        WKUserContentController *userControl = wkWebView.configuration.userContentController;
        for (NSString *actionName in self.jsActionNameArr)
        {
            [userControl addScriptMessageHandler:self name:actionName];
        }

    }
    else
    {
//        UIWebView *uiWebView = (UIWebView *)webView;
        self.context = [self valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
        _viewModel = [[PYCJSBaseWebViewModel alloc] init];
        __weak typeof(self) weakSelf = self;
        self.context[@"PYCREDIT_BRIDGE"] = _viewModel;
        _viewModel.delegate = weakSelf;
        _viewModel.context = weakSelf.context;
        _viewModel.actionNameArr = weakSelf.jsActionNameArr;
        
    }
}
/**
 WKWebView
 */
- (void)removeJSScripToWebView
{
    if (!_usingUIWebView)
    {
        WKUserContentController *userControl = self.webconfig.userContentController;
        for (NSString *actionName in self.jsActionNameArr)
        {
            [userControl removeScriptMessageHandlerForName:actionName];
        }
    }
}

- (void)excuteMethodWithMethodDic:(NSDictionary *)dict
{
    PYCJSResultData  *resultData = [[PYCJSResultData alloc]initWithDictionary:dict];
    
    if (!self.resultDataDictionary) {
        self.resultDataDictionary = @{}.mutableCopy;
    }
    
    [self.resultDataDictionary setValue:resultData forKey:resultData.action];
    
    if ([resultData.action isEqualToString:@"cameraGetImage"]) {
        [self _actionCameraGetImage:dict];
    }
    else if ([resultData.action isEqualToString:@"previewImage"]){
        [self _actionPreviewImage:dict];
    }
    else if ([resultData.action isEqualToString:@"uploadImage"]){
        [self _actionUploadImage:dict];
    }
    else if ([resultData.action isEqualToString:@"openPayApp"]){
        [self _actionOpenApp:dict];
    }
    else if ([resultData.action isEqualToString:@"getAdBannerURL"]){//获取广告图片URL
        [self _actiongetAdBannerURL:dict];
    }
    else if ([resultData.action isEqualToString:@"clickAd"]){//广告点击事件
        [self _actionclickAd:dict];
    }
}
#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *requestURL = [request URL];
    if (self.requestBlock) {
        self.requestBlock(request);
        self.requestBlock = nil;
    }
    
    if ( ( [[requestURL scheme]isEqualToString:@"http" ] ||
          [[requestURL scheme]isEqualToString:@"https"] ||
          [[requestURL scheme] isEqualToString: @"mailto" ]) &&
        ( navigationType == UIWebViewNavigationTypeLinkClicked ) )
    {
        return ![[UIApplication sharedApplication] openURL:requestURL];
    }
    else if([[requestURL scheme]isEqualToString:@"js2os"])
    {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1)),
                       dispatch_get_main_queue(),
                       ^{
                           NSString * requestString = [PYCUtil urlDecodeString:[requestURL relativeString]];
                           NSString * jsonString = [requestString stringByReplacingOccurrencesOfString:@"js2os://" withString:@""];
                           id jsonObject = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
                           if ([jsonObject isKindOfClass:[NSDictionary class]])
                           {
                               [self excuteMethodWithMethodDic:jsonObject];
                           }
                       });
        return NO;
    }
    else if([[requestURL scheme]isEqualToString:@"tel"])
    {
        //防止用户过快点击出现两次弹框
        webView.userInteractionEnabled = NO;
        [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                 selector:@selector(setRealWebViewUserInteractionEnabled:)
                                                   object:@(YES)];
        [self performSelector:@selector(setRealWebViewUserInteractionEnabled:)
                   withObject:@(YES)
                   afterDelay:0.5f];
        return YES;
    }
    
    else if ([[requestURL scheme] isEqualToString: @"weixin"])
    {
        if (self.successBlock) {
            self.successBlock();
            self.successBlock = nil;
        }
        return YES;
    }
    
    return YES;
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if ([message.body isKindOfClass:[NSString class]])
    {
        NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:[message.body dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        [self excuteMethodWithMethodDic:jsonObject];
    }
}

- (BOOL)callback_webViewShouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(NSInteger)navigationType
{
    return  [self pycWebView:_realWebView shouldStartLoadWithRequest:request navigationType:navigationType];
}

- (WKWebViewConfiguration *)webconfig
{
    if(!_usingUIWebView)
    {
        WKWebView* webView = _realWebView;
        return webView.configuration;
    }
    return nil;
}
- (id)valueForKeyPath:(NSString *)keyPath
{
    if(_usingUIWebView)
    {
        return [(UIWebView*)self.realWebView valueForKeyPath:keyPath];
    }
    else
    {
        return [(WKWebView*)self.realWebView valueForKeyPath:keyPath];
    }
}
#pragma  mark - uploadInfo to h5
///uploadImageData to JS
- (void)_uploadImageData:(NSString *)imageData withPath:(NSString *)path
{
    NSString *jsStr = [NSString stringWithFormat:@"%@({\"base64\":\"%@\", \"localId\":\"%@\"})", self.resultDataDictionary[@"cameraGetImage"].successFunName, imageData, path];
    
    [self executeJSFunctionWithString:jsStr];
}

- (void) executeJSFunctionWithString:(NSString *)jsString
{
    if(_usingUIWebView)
    {
        [(UIWebView*)self.realWebView stringByEvaluatingJavaScriptFromString:jsString];
    }
    else
    {
        return [(WKWebView*)self.realWebView evaluateJavaScript:jsString completionHandler:nil];
    }
}
#pragma  mark - PYCH5IOImageHelperProtocol
- (NSData *)convertDataBySelect:(NSData *)selectImageData needTrim:(BOOL)isNeedTrim
{
    return selectImageData;
}

- (void)convertImagesCompleteWith:(NSArray <PYCPostImageFile *> *)images
                         needTrim:(BOOL)isNeedTrim
                        authority:(BOOL)hasAuthority
                      cancelClick:(BOOL)clickCancel
{
    if (clickCancel) {
        NSString *jsString = [NSString stringWithFormat:@"%@({\"code\":\"error_1002\", \"message\":\"用户取消拍照\"})", self.resultDataDictionary[@"cameraGetImage"].errorFunName];
        [self executeJSFunctionWithString:jsString];
        
        return;
    }
    //权限不足
    if (hasAuthority == NO) {
        NSString *jsString = [NSString stringWithFormat:@"%@({\"code\":\"error_1001\", \"message\":\"拍照权限不足，请检查\"})", self.resultDataDictionary[@"cameraGetImage"].errorFunName];
        [self executeJSFunctionWithString:jsString];
        return;
    }
    
    //取消拍照
    if (images.count == 0) {
        NSString *jsString = [NSString stringWithFormat:@"%@({\"code\":\"error_1002\", \"message\":\"用户取消拍照\"})", self.resultDataDictionary[@"cameraGetImage"].errorFunName];
        [self executeJSFunctionWithString:jsString];
        
        return;
    }
    
    //todo: 生成缩略图
    PYCPostImageFile *imageFile = images[0];
    UIImage *image = [UIImage imageWithContentsOfFile:imageFile.imgFilePath];
    PYCJSResultData *jsResultData = (PYCJSResultData *)self.resultDataDictionary[@"cameraGetImage"];
    NSString *width = jsResultData.data[@"thumbWidth"];
    if (width == nil) {
        width = @"0";
    }
    UIImage *newImage = [UIImage py_resizeImage:image maxPixelSize:width.floatValue];
    NSData *data = UIImageJPEGRepresentation(newImage, 1.0);
    
    NSString        *base64String = [PYCUtil encodeBase64Data:data];
    [self _uploadImageData:base64String withPath:imageFile.imgFilePath];
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 1000:
        case 1001:
        {
            if (buttonIndex != alertView.cancelButtonIndex) {
                [PYCUtil openSystemSettingOfApp];
            }
            
            break;
        }
            
        default:
            break;
    }
}
#pragma mark - actionFuns

- (void) _actionPreviewImage:(NSDictionary *)dict
{
    NSMutableArray *imgArr = @[].mutableCopy;
    NSDictionary *data = dict[@"args"][@"data"];
    if (data == nil) {
        NSString *jsString = [NSString stringWithFormat:@"%@({\"code\":\"error_4001\", \"message\":\"paramter invalid\"})", self.resultDataDictionary[@"previewImage"].errorFunName];
        [self executeJSFunctionWithString:jsString];
        return;
    }
    NSString *imagePath = data[@"localId"];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:imagePath];
    if (image) {
        [imgArr addObject:image];
    }
    
    if (imgArr.count == 0)
    {
        NSString *jsString = [NSString stringWithFormat:@"%@({\"code\":\"error_4001\", \"message\":\"not found\"})", self.resultDataDictionary[@"previewImage"].errorFunName];
        [self executeJSFunctionWithString:jsString];
        return;
    }
    
    JZAlbumViewController *vc = [[JZAlbumViewController alloc] init];
    vc.imgArr = imgArr;
    
    vc.currentIndex = 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        [_scriptMessageHandler presentViewController:vc animated:YES completion:^{
            NSString *jsString = [NSString stringWithFormat:@"%@()", self.resultDataDictionary[@"previewImage"].successFunName];
            [self executeJSFunctionWithString:jsString];
        }];
    });
}

- (void) _actionUploadImage:(NSDictionary *)dict
{
    NSDictionary *data = dict[@"args"][@"data"];
    if (data == nil) {
        NSString *jsString = [NSString stringWithFormat:@"%@({\"code\":\"error_2001\", \"message\":\"paramter invalid\"})", self.resultDataDictionary[@"uploadImage"].errorFunName];
        [self executeJSFunctionWithString:jsString];
        return;
    }
    
    NSMutableDictionary *dcty = [[NSMutableDictionary alloc] init];
    if (data[@"key"]) {
        [dcty setObject:data[@"key"] forKey:@"key"];
    }
    
    if (data[@"token"]) {
        [dcty setObject:data[@"token"] forKey:@"token"];
    }
    
    if (data[@"width"]) {
        [dcty setObject:data[@"width"] forKey:@"width"];
    }
    else {
        [dcty setObject:@1920 forKey:@"width"];
    }
    
    if (data[@"height"]) {
        [dcty setObject:data[@"height"] forKey:@"height"];
    }
    else {
        [dcty setObject:@1080 forKey:@"height"];
    }
    
    NSString *imagePath = data[@"file"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    
    [PYCUtil upLoadImageToQiniu:image parameterDic:dcty maxLength:300 progressHandler:nil finishBlock:^(id result) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:result options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSString *jsString = [NSString stringWithFormat:@"%@(%@)", self.resultDataDictionary[@"uploadImage"].successFunName, jsonString];
        [self executeJSFunctionWithString:jsString];
    } failedBlock:^(id result) {
//        NSError *error = (NSError *)result;
        NSString *jsString = [NSString stringWithFormat:@"%@({\"code\":\"error_2001\", \"message\":\"%@\"})", self.resultDataDictionary[@"uploadImage"].errorFunName, @"网络错误，上传失败"];
        [self executeJSFunctionWithString:jsString];
    }];
}

- (void) _actionOpenApp:(NSDictionary *)dict
{
    NSDictionary *payInfoDict = dict[@"args"][@"data"];
    //判断是否有安装相关支付app
    if ( ![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:payInfoDict[@"scheme"]]])
    {
        NSDictionary *errorDict = @{@"code":@"error_3001",@"message":@"用户没有安装支付 App"};
        [self callJSFuntionBackWithData:errorDict func:dict[@"error"]];
        return;
    }
    
    UIWebView *tempWebview = [[UIWebView alloc] initWithFrame:CGRectZero];
    tempWebview.delegate = self;
    [((UIViewController *)_scriptMessageHandler).view addSubview:tempWebview];
    //增加Referr,否则不能跳转微信支付
    if ([payInfoDict[@"scheme"] containsString:@"weixin"])
    {
        NSURL *url = [NSURL URLWithString:[PYCUtil strongUrlWithUrlStr:payInfoDict[@"mwebUrl"]]];
        __weak __typeof(tempWebview) weakTempWebview = tempWebview;
        self.requestBlock = ^(NSURLRequest *request){
            BOOL headerIsPresent = [[request allHTTPHeaderFields] objectForKey:@"Referer"]!=nil;
            if (!headerIsPresent){
                NSMutableURLRequest* mutableRequest = [request mutableCopy];
                [mutableRequest addValue:payInfoDict[@"redirectUrl"] forHTTPHeaderField:@"Referer"];
                [weakTempWebview loadRequest:mutableRequest];
            }
        };
        [tempWebview loadRequest:[NSURLRequest requestWithURL:url]];
        __weak typeof(self) weakSelf = self;
        self.successBlock = ^(){
            //dispatch_after(dispatch_getm, <#dispatch_queue_t  _Nonnull queue#>, <#^(void)block#>)
            [weakSelf callJSFuntionBackWithData:@{} func:dict[@"success"]];
        };
    }
}
- (void)_actionCameraGetImage:(NSDictionary *)dict
{
    
    _h5CurrentImagesInfo = [[PYCH5CurrentImagesInfo alloc] initWithDictionary:dict];
    
    //前或后摄像头
    UIImagePickerControllerCameraDevice cameraDeviceType = UIImagePickerControllerCameraDeviceFront;
    if (_h5CurrentImagesInfo.defaultDirection.integerValue == 1) {
        cameraDeviceType = UIImagePickerControllerCameraDeviceRear;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.h5IOImageHelper showSelectImageActionSheetWithSelectMaxSum:1
                                                        maxPixelSize:0
                                                            needTrim:NO
                                                    cameraDeviceType:cameraDeviceType];
    });
}

/**
 获取广告图片URL

 @param dict 参数
 */
- (void)_actiongetAdBannerURL:(NSDictionary *)dict
{
    NSString *jsString = nil;
    if (_urlString.length > 0) {
        jsString = [NSString stringWithFormat:@"%@({\"url\":\"%@\"})", self.resultDataDictionary[@"getAdBannerURL"].successFunName, _urlString];
    }
    else
    {
        jsString = [NSString stringWithFormat:@"%@({\"code\":\"error_5001\", \"message\":\"没有广告 banner\"})", self.resultDataDictionary[@"getAdBannerURL"].errorFunName];
    }

    [self executeJSFunctionWithString:jsString];
}
/**
 广告点击事件
 
 @param dict 参数
 */
- (void)_actionclickAd:(NSDictionary *)dict
{
    NSDictionary *data = dict[@"args"][@"data"];
    if (data == nil) {
        NSString *jsString = [NSString stringWithFormat:@"%@({\"code\":\"error_6001\", \"message\":\"没有广告\"})", self.resultDataDictionary[@"clickAd"].errorFunName];
        [self executeJSFunctionWithString:jsString];
        return;
    }
    NSString *tempString = data[@"url"];
    if (tempString.length == 0)
    {
        NSString *jsString = [NSString stringWithFormat:@"%@({\"code\":\"error_6001\", \"message\":\"没有广告\"})", self.resultDataDictionary[@"clickAd"].errorFunName];
        [self executeJSFunctionWithString:jsString];
        return;
    }
    
    //回调给用户
    if (_webViewHelperBlock) {
        _webViewHelperBlock(tempString);
    }
    
}
/**
 APP将数据传给JS
 
 @param data 数据
 @param func 方法名
 */

- (void)callJSFuntionBackWithData:(id)data
                             func:(NSString *)func
{
    if (func == nil)
    {
        return;
    }
    if (data!= nil)
    {
        NSMutableString *tmpJSStr = [NSMutableString string];
        NSString *basicStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:data options:0 error:nil] encoding:NSUTF8StringEncoding];
        [tmpJSStr appendFormat:@"%@(%@)",func,basicStr];
        [self executeJSFunctionWithString:tmpJSStr];
    }
}

/**
 用户要调用的方法

 @param webView <#webView description#>
 @param request <#request description#>
 @param navigationType <#navigationType description#>
 @return <#return value description#>
 */
- (BOOL)pycWebView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *requestURL = [request URL];
    if (self.requestBlock) {
        self.requestBlock(request);
    }
    if ( ( [[requestURL scheme]isEqualToString:@"http" ] ||
          [[requestURL scheme]isEqualToString:@"https"] ||
          [[requestURL scheme] isEqualToString: @"mailto" ]) &&
        ( navigationType == UIWebViewNavigationTypeLinkClicked ) )
    {
        return ![[UIApplication sharedApplication] openURL:requestURL];
    }
    else if([[requestURL scheme]isEqualToString:@"js2os"])
    {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1)),
                       dispatch_get_main_queue(),
                       ^{
                           NSString * requestString = [PYCUtil urlDecodeString:[requestURL relativeString]];
                           NSString * jsonString = [requestString stringByReplacingOccurrencesOfString:@"js2os://" withString:@""];
                           id jsonObject = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
                           if ([jsonObject isKindOfClass:[NSDictionary class]])
                           {
                               [self excuteMethodWithMethodDic:jsonObject];
                           }
                       });
        return NO;
    }
    else if([[requestURL scheme]isEqualToString:@"tel"])
    {
        //防止用户过快点击出现两次弹框
        webView.userInteractionEnabled = NO;
        [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                 selector:@selector(setRealWebViewUserInteractionEnabled:)
                                                   object:@(YES)];
        [self performSelector:@selector(setRealWebViewUserInteractionEnabled:)
                   withObject:@(YES)
                   afterDelay:0.5f];
        return YES;
    }
    
    return YES;
}

/**
 设置用户是否 点击

 @param userInteractionEnabled <#userInteractionEnabled description#>
 */
- (void)setRealWebViewUserInteractionEnabled:(NSNumber *)userInteractionEnabled
{
    ((UIView *)_realWebView).userInteractionEnabled = userInteractionEnabled.boolValue;
}
/**
 用户要调用的方法

 @param webView WKWebView description
 @param navigationAction <#navigationAction description#>
 @param decisionHandler <#decisionHandler description#>
 */
-(void)pycWebView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    
    ///允许H5 发起 电话，邮件等action
    NSURL *url = navigationAction.request.URL;
    NSString *strUrl = [NSString stringWithFormat:@"%@",url];
    if (![strUrl hasPrefix:@"http"]) {
        if ( [[UIApplication sharedApplication] canOpenURL:url]) {
            
            //防止用户过快点击出现两次弹框
            webView.userInteractionEnabled = NO;
            [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                     selector:@selector(setRealWebViewUserInteractionEnabled:)
                                                       object:@(YES)];
            [self performSelector:@selector(setRealWebViewUserInteractionEnabled:)
                       withObject:@(YES)
                       afterDelay:0.5f];
            
            
            [[UIApplication sharedApplication] openURL:url];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    
    BOOL resultBOOL = [self callback_webViewShouldStartLoadWithRequest:navigationAction.request navigationType:navigationAction.navigationType];
    if(resultBOOL)
    {
        //        self.currentRequest = navigationAction.request;
        if(navigationAction.targetFrame == nil)
        {
            [webView loadRequest:navigationAction.request];
        }
        decisionHandler(WKNavigationActionPolicyAllow);
    }
    else
    {
        decisionHandler(WKNavigationActionPolicyCancel);
    }
}

/**
 会拦截到window.open()事件.只需要我们在方法内进行处理

 @param webView <#webView description#>
 @param configuration <#configuration description#>
 @param navigationAction <#navigationAction description#>
 @param windowFeatures <#windowFeatures description#>
 @return <#return value description#>
 */
- (WKWebView *)pyWebView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}
@end
