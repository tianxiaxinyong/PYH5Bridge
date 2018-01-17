
##  PYH5Bridge集成说明


##### 运行环境
支持iOS 8.0版本以上的系统。   
存在问题：在iOS 8.x系统上，退出当前H5页面后，WKWebView与UIWebView无法保存会话，再次进入时需重新登录，iOS 9.0以上系统无此问题。 


##### 集成说明
PYH5Bridge提供源码手动集成及Pod安装这2种集成方式，可任意选择一种进行集成。
###### Pod安装
```objc
	pod 'PYH5Bridge'
```  

###### 手动集成
1）将`PYH5Bridge/PYH5Bridge/Classes`目录下的所有文件先复制到项目路径下，然后在Xcode中通过"`Add Files to project`"的方式添加。  

2）在项目"`Build Phases`"的"`Link Binary With Libraries`"中添加如下框架：  
1.`AVFoundation.framework`  
2.`AssetsLibrary.framework`  
3.`libz.tbd`  
4.`libresolv.9.tbd`  
5.`JavaScriptCore.framework`  
6.`SystemConfiguration.framework`  
7.`Photos.framework`  
8.`MobileCoreServices.framework`  
9.`CoreMedia.framework`  

3）`PYH5Bridge`还依赖如下第三方组件，请手动添加到项目中(点击链接可直达github处下载)：  
1.[`AFNetworking`](https://github.com/AFNetworking/AFNetworking)  
2.[`MBProgressHUD`](https://github.com/jdg/MBProgressHUD)  
3.[`Qiniu`](https://github.com/qiniu/objc-sdk)  
4.[`HappyDNS`](https://github.com/qiniu/happy-dns-objc)  
5.[`IMYWebView`](https://github.com/li6185377/IMYWebView)  
  

###### 额外设置
1）由于iOS 11的权限策略变更，需要在info.plist中添加"Privacy - Camera Usage Description"项，`Type`为String，`Value`为申请相机权限时的提示文字。  
2）info.plist中添加"LSApplicationQueriesSchemes"项，`Type`为Array，增加一个子项, `Key`可以自由命名，`Type`为String，`Value`为"weixin"。  
3）由我们为用户生成一个`URL scheme`标识, 在项目工程里面的info选项里面的URL Type里添加一项，`URL scheme`为我们后台生成的标识，添加以后在手机上运行一次，然后可以在手机Safari浏览器里面输入刚添加的"URL scheme://"，验证是否能跳转到自己的应用。



##### 使用说明  

PYH5Bridge提供了WebView的PYCWebViewHelper类，用于设置WebView的JS Bridge。
      
```objc
#import "PYCWebViewHelper.h" 

@property (nonatomic, strong) PYCWebViewHelper *pycWebViewHelper;  

- (void)viewDidLoad {  
　　[super viewDidLoad];  

　　//WebView可从WKWebView和UIWebView中自由选择一种，若选择UIWebView，  
　　//必须实现UIWebViewDelegate的shouldStartLoadWithRequest方法  
　　self.baseWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64)]; 

　　//UIWebView必须实现UIWebViewDelegate  
　　self.baseWebView.delegate = self; 
 
　　//WKWebView必须实现navigationDelegate和UIDelegate  
　　self.baseWebView.navigationDelegate = self;  
　　self.baseWebView.UIDelegate = self;  
    
　　_pycWebViewHelper = [[PYCWebViewHelper alloc] init];  
　　[_pycWebViewHelper addScriptMessageHandlerToWebView:self.baseWebView webViewDelegate:self];  
    
　　[self.view addSubview:self.baseWebView]; 
  
}  

- (void)dealloc  
{  
    　　[_pycWebViewHelper removeScriptMessageHandler];  
} 

//UIWebView实现UIWebViewDelegate  
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType  
{  
　　//do something  
　　return [self.pycWebViewHelper pycWebView:webView shouldStartLoadWithRequest:request navigationType:navigationType];  
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
```


##### 处理H5页面的后退事件  
在用户使用H5页面时，通过导航栏的返回按钮只能返回到上一界面，不能回退到H5前一页面，因此需要通过处理返回按钮点击事件来实现H5页面回退。 
  
  
在WebView所在ViewController`"xxxxViewController.m"`中添加代码：  

```objc
- (void)customBackButton  
{  
    　　UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backBtnClicked:)];  
    　　self.navigationItem.leftBarButtonItem = item;  
} 

- (void)backBtnClicked:(id)sennder  
{  
    　　if ([self.baseWebView canGoBack]) {  
        　　　　[self.baseWebView goBack];  
    　　}
    　　else {  
        　　　　[self.navigationController popViewControllerAnimated:YES];  
    　　}  
}
```
  
##### 添加广告
可以在H5页面底部添加一个广告，用于展示指定图片（尺寸为1080 * 286），用户点击图片广告后将会回调App预先设置的方法进行处理。  
由于H5页面使用了https协议，因浏览器安全限制，广告图片的链接必须使用https协议，否则图片无法加载和展示。点击广告后指向的页面链接不受限制，可以是http或https协议的。 
 
```objc
- (void)viewDidLoad {  
   [super viewDidLoad];  
    
　　//WebView可从WKWebView和UIWebView中自由选择一种，若选择UIWebView，  
　　//必须实现UIWebViewDelegate的shouldStartLoadWithRequest方法  
　　self.baseWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64)];  
　　//UIWebView必须实现UIWebViewDelegate  
　　self.baseWebView.delegate = self;  
　　//WKWebView必须实现navigationDelegate和UIDelegate  
　　self.baseWebView.navigationDelegate = self;  
　　self.baseWebView.UIDelegate = self;  

　　 //无广告的初始化方法  
　　_pycWebViewHelper = [[PYCWebViewHelper alloc] init];  
 　　//有广告的初始化方法，URL为图片链接，Block为用户点击广告时的回调方法  
    　　_pycWebViewHelper = [[PYCWebViewHelper alloc] initWithUrl:@"https://www.xxx.com/xxx.png" webViewHelperBlock:^(NSString *urlString) {  
        　　　　//可以自由跳转WebView或App内部模块
        　　  
    　　}];`  
    
　　[_pycWebViewHelper addScriptMessageHandlerToWebView:self.baseWebView webViewDelegate:self];  
    
　　[self.view addSubview:self.baseWebView]; 
}  
```

##### 竖屏展示H5页面
为了更好的用户使用体验，建议在竖屏状态下展示H5页面，在PYH5BridgeDemo中有相应实现代码供参考。  
部分代码展示：  

```objc
- (BOOL)shouldAutorotate 
{  
    　　return YES;  
}  

//只支持竖屏  
- (UIInterfaceOrientationMask)supportedInterfaceOrientations  
{  
    　　return UIInterfaceOrientationMaskPortrait;  
}  
```

##### 添加关闭按钮
用户在使用H5页面时，若进入的层级较深，只能点击多次"返回"按钮来退出当前ViewController，无法一次性关闭当前界面，目前比较通用的方法是添加关闭按钮来直接关闭当前界面。  

在PYH5BridgeDemo中有相应实现代码供参考,部分代码如下：  

```objc
UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"返回"  
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　style:UIBarButtonItemStylePlain  
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　target:self  
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　action:@selector(backBtnClicked:)];  
                                                              
UIBarButtonItem *closeItem = [[UIBarButtonItem alloc]initWithTitle:@"关闭"  
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　style:UIBarButtonItemStylePlain  
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　target:self  
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　action:@selector(closeBtnClicked:)];  
                                                                
self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:backItem,closeItem, nil];

//返回按钮点击事件   
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

//关闭按钮点击事件  
- (void)closeBtnClicked:(id)sender  
{  
    　　[self.navigationController popViewControllerAnimated:YES];  
}  
```
