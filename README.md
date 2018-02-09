##  PYH5Bridge集成说明


### 1. 运行环境
支持iOS 8.0及8.0以上的系统。   
> 存在问题：在iOS 8.x系统上，退出当前H5页面后，WKWebView与UIWebView无法保存会话，再次进入时需重新登录，iOS 9.0及9.0以上系统无此问题。 


### 2. 集成说明
PYH5Bridge提供源码手动集成及CocoaPods集成这2种集成方式，可任意选择一种方式进行集成。
#### 2.1 CocoaPods集成
在工程的`Podfile`文件中添加：

```objc
	pod 'PYH5Bridge'
```  
保存并执行`pod install`命令，即可将PYH5Bridge集成到已有工程中。  
若要更新版本，执行`pod update`命令即可将`PYH5Bridge`更新到最新版本。

#### 2.2 手动集成
**2.2.1** 下载并解压`PYH5Bridge`源码，将`PYH5Bridge/Classes`及`PYH5Bridge/Assets`目录下的所有文件先复制到项目路径下，然后在Xcode中通过"`Add Files to project`"的方式添加。  

**2.2.2** 在项目"`Build Phases`"的"`Link Binary With Libraries`"中添加如下框架：  

* `AVFoundation.framework`  
* `AssetsLibrary.framework`  
* `libz.tbd`  
* `libresolv.9.tbd`  
* `JavaScriptCore.framework`  
* `SystemConfiguration.framework`  
* `Photos.framework`  
* `MobileCoreServices.framework`  
* `CoreMedia.framework`  


**2.2.3** `PYH5Bridge`还依赖如下第三方组件，请手动添加到项目中，若项目中已存在，则不用再次添加(点击链接可直达github下载页面)：  

* [`AFNetworking`(3.x)](https://github.com/AFNetworking/AFNetworking)  
* [`MBProgressHUD`(1.1.x)](https://github.com/jdg/MBProgressHUD)  
* [`Qiniu`(7.2.x)](https://github.com/qiniu/objc-sdk)  
* [`HappyDNS`(0.3.x)](https://github.com/qiniu/happy-dns-objc)  

  

#### 2.3 额外设置
**权限申请描述**  

* 在info.plist中添加"Privacy - Camera Usage Description"项，`Type`为String，`Value`为申请相机权限的理由描述文字。
* 在info.plist中添加"Privacy - Microphone Usage Description"项，`Type`为String，`Value`为申请麦克风权限的理由描述文字。
* 在info.plist中添加"Privacy - Location When In Use Usage Description"项，`Type`为String，`Value`为申请使用应用时定位权限的理由描述文字。  


**支付方式设置**

* 微信支付支持：在info.plist中添加"LSApplicationQueriesSchemes"项，`Type`为Array，增加一个子项, `Type`为String，`Value`为"weixin"。  
* 支付宝支持：在info.plist中添加"LSApplicationQueriesSchemes"项，`Type`为Array，增加一个子项, `Type`为String，`Value`为"alipay"。
* 微信支付完成回调：由天下信用后台为用户生成一个"`URL Scheme`"标识（下面以"`PYTXXY`"来示范）, 在项目工程里面的`info`选项卡下`URL Type`分组添加一项，`URL Schemes`的值为"`PYTXXY`"。添加以后在手机上运行一次项目，然后在手机`Safari`浏览器里面输入刚添加的"`PYTXXY://`"，验证是否能跳转到自己的应用。



### 3. 使用说明  

PYH5Bridge提供了WebView的PYCWebViewHelper类，用于设置WebView的JS Bridge。
      
```objc
#import "PYCWebViewHelper.h" 

@property (nonatomic, strong) PYCWebViewHelper *pycWebViewHelper;  

- (void)viewDidLoad {  
　　[super viewDidLoad];  

　　//WebView可从WKWebView和UIWebView中自由选择一种，若选择UIWebView，  
　　//必须实现UIWebViewDelegate的shouldStartLoadWithRequest方法  
　　self.baseWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, kPYSafeAreaTopHegiht, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - kPYSafeAreaTopHegiht)]; 

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

//用于在WKWebview页面被系统结束后重载
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView
{
    [self.pycWebViewHelper pyWebViewWebContentProcessDidTerminate:webView];
}

#pragma mark- WKUIDelegate  
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures  
{  
    return [self.pycWebViewHelper pyWebView:webView createWebViewWithConfiguration:configuration forNavigationAction:navigationAction windowFeatures:windowFeatures];  
}
```

### 4. 其他功能
这一节中描述了一些增强用户体验的设置或额外功能，用户可根据项目实际情况考虑是否采用。  

#### 4.1 处理H5页面的后退事件  
在用户访问H5页面时，通过导航栏的返回按钮只能返回到上一界面，不能回退到H5前一页面，因此需要通过处理返回按钮点击事件来实现H5页面回退。 
  
  
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
  
#### 4.2 添加广告
可以在H5页面底部添加一个广告，用于展示指定图片（尺寸为1080 * 286），用户点击图片广告后将会回调App预先设置的方法进行处理。  
由于H5页面使用了https协议，因浏览器安全限制，广告图片的链接必须使用https协议，否则图片无法加载和展示。点击广告后指向的页面链接不受限制，可以是http或https协议的。   
> 使用此功能时，需提前与天下信用沟通，否则可能无法生效。  
 
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
 　　//有广告的初始化方法，URL为图片链接（建议使用https协议链接应对苹果的ATS政策），Block为用户点击广告时的回调方法  
    　　_pycWebViewHelper = [[PYCWebViewHelper alloc] initWithUrl:@"https://www.xxx.com/xxx.png" webViewHelperBlock:^(NSString *urlString) {  
        　　　　//可以自由跳转WebView或App内部模块
        　　  
    　　}];`  
    
　　[_pycWebViewHelper addScriptMessageHandlerToWebView:self.baseWebView webViewDelegate:self];  
    
　　[self.view addSubview:self.baseWebView]; 
}  
```

#### 4.3 竖屏展示H5页面
为了更好的用户使用体验，建议在竖屏状态下展示H5页面，在`PYH5Bridge_Example`中有相应实现代码供参考。  
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

#### 4.4 添加关闭按钮
用户在访问H5页面时，若进入的层级较深，只能点击多次"返回"按钮来退出当前ViewController，无法一次性关闭当前界面。目前比较通用的方法是添加关闭按钮来直接关闭当前界面。  

在`PYH5Bridge_Example`中有相应实现代码供参考,部分代码如下：  

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
  
  
[更新日志](Change_Log.md) 