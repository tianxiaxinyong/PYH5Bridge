//
//  ShowByWKWebViewController.m
//  PYH5BridgeDemo
//
//  Created by wangmin on 2017/10/18.
//  Copyright © 2017年 wangm. All rights reserved.
//

#import "ShowByWKWebViewController.h"
#import "PYCWebViewHelper.h"

#define kPYStatusBarHeight                  [[UIApplication sharedApplication] statusBarFrame].size.height
#define kPYNavigationBarHeight              self.navigationController.navigationBar.frame.size.height
#define kPYSafeAreaTopHegiht                (kPYNavigationBarHeight + kPYStatusBarHeight)
#define kPYSafeAreaBottomHeight             (kPY_IS_iPhoneX ? 34.f : 0.f)

@interface ShowByWKWebViewController ()<WKNavigationDelegate,WKUIDelegate>

@property (nonatomic, strong) PYCWebViewHelper *pycWebViewHelper;
@property (nonatomic, strong) WKWebView *baseWebView;

@end

@implementation ShowByWKWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self customBackItem];
    
    self.baseWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, kPYSafeAreaTopHegiht,[UIScreen mainScreen].bounds.size.width ,[UIScreen mainScreen].bounds.size.height - kPYSafeAreaTopHegiht)];
    self.baseWebView.navigationDelegate = self;
    self.baseWebView.UIDelegate = self;
    [self.view addSubview:self.baseWebView];
    
#warning 需要替换为真正的URL
    NSURL *url = [[NSURL alloc] initWithString:@"** 使用鹏元提供的渠道url **"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [self.baseWebView loadRequest:request];
    
    //无广告的初始化方法
    //self.pycWebViewHelper = [[PYCWebViewHelper alloc] init];
    
    //有广告的初始化方法，URL为图片链接（建议使用https协议链接应对苹果的ATS政策），Block为用户点击广告时的回调方法
    self.pycWebViewHelper = [[PYCWebViewHelper alloc] initWithUrl:@"** 广告图片链接，建议使用https协议链接应对苹果的ATS政策 **" webViewHelperBlock:^(NSString *urlString) {
        //可以自由跳转WebView或App内部模块
        
    }];
    
    [self.pycWebViewHelper addScriptMessageHandlerToWebView:self.baseWebView webViewDelegate:self];
}

#pragma mark- WKNavigationDelegate
-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    [self.pycWebViewHelper pycWebView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
}

#pragma mark- WKUIDelegate
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    return [self.pycWebViewHelper pyWebView:webView createWebViewWithConfiguration:configuration forNavigationAction:navigationAction windowFeatures:windowFeatures];
}

#pragma mark ------ 处理H5页面的后退事件------------------
- (void)customBackItem
{
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(backBtnClicked:)];
    self.navigationItem.leftBarButtonItem = backItem;
}

- (void)closeAndBackItem
{
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(backBtnClicked:)];
    
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc]initWithTitle:@"关闭"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(closeBtnClicked:)];
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:backItem,closeItem, nil];
}

- (void)backBtnClicked:(id)sennder
{
    if ([self.baseWebView canGoBack]) {
        [self closeAndBackItem];
        [self.baseWebView goBack];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)closeBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)dealloc
{
    [_pycWebViewHelper removeScriptMessageHandler];
}

#pragma mark ----- 强制该界面竖屏显示
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //设置竖屏
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInt:UIInterfaceOrientationPortrait] forKey:@"orientation"];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.baseWebView.frame = CGRectMake(0, kPYSafeAreaTopHegiht,[UIScreen mainScreen].bounds.size.width ,[UIScreen mainScreen].bounds.size.height - kPYSafeAreaTopHegiht);
}

- (BOOL)shouldAutorotate
{
    return YES;
}

//强制竖屏
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
