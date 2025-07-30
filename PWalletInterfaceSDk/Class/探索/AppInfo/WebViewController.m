//
//  WebViewController.m
//  PWallet
//
//  Created by lee on 2018/10/17.//  Created by fzm on 2021/12/7.
//
#import "WebViewController.h"
#import "GameGoFunction.h"
#include <CommonCrypto/CommonCrypto.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import "PWNewsHomeViewController.h"
#import "PWNewsHomeNoWalletViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "ExchangeModel.h"
#import "SGNetWork.h"
#import "AsyncUdpSocket.h"
#import "PWalletinterfaceSDK-Swift.h"
#import "WKWebViewConfiguration+Extension.h"
#import "DappAlertSheetView.h"
#import <JKBigInteger/JKBigInteger.h>
#import "WebSheetView.h"
#import "WebChangeAccountSheetView.h"
#import "PWApplication.h"
#import "RecentlyUsedAppTool.h"


#define kMethodArr @[@"sendTransaction",@"signTransaction",@"signPersonalMessage",@"signMessage",@"signTypedMessage",@"ethCall",@"walletSwitchEthereumChain"]
#define rootVC  UIApplication.sharedApplication.keyWindow.rootViewController


NSString *const kInitVectorForGame = @"33878402";

NSString *const DESKeyForGame = @"008f80e79e6b8c6a500e54e216e38ac2";
NSString *const FeePrikey = @"0xcc38546e9e659d15e6b4893f0ab32a06d103931a8230b0bde71459d2b27d6944";
static NSString * const dbPath = @"privacy.db";
NSString *const RPCUrl = @"https://mainnet.bityuan.com/eth";
@interface WebViewController ()
<WKUIDelegate,
WKNavigationDelegate,
UIScrollViewDelegate,
AsyncUdpSocketDelegate,
CLLocationManagerDelegate,
WKScriptMessageHandler,
WKURLSchemeHandler>
{
    WVJBResponseCallback _toPayResultrCallback;
    WKWebViewConfiguration *_configuration;
}
//设置加载进度条
@property (nonatomic,strong) UIProgressView *progressView;
@property (nonatomic , strong)WKWebView *webView;
@property WKWebViewJavascriptBridge *bridge;
@property (nonatomic, copy) NSString *feePrikey;
@property (nonatomic,assign) CGFloat btyFeeValue;
@property (nonatomic, copy) NSString *priKey;

// 去中心化交易所
@property (nonatomic, strong) WalletapiExecers *execers;
@property (nonatomic, strong) WalletapiXgo *xgo;
@property (nonatomic, strong) WalletapiUtil *util;
//树莓派ip列表
@property (nonatomic, strong) NSMutableArray *deviceList;
@property (nonatomic,copy) WVJBResponseCallback getDeviceCallback;
@property (nonatomic,copy) WVJBResponseCallback getWifiCallback;
@property (nonatomic,strong) AsyncUdpSocket *socket;
@property (nonatomic,strong) CLLocationManager* locationManager;

@property (nonatomic, copy) NSString *nonce;
@property (nonatomic, copy) NSString *gasPrice;
@property (nonatomic, strong) LocalCoin *localCoin;
@property (nonatomic, strong) DappAlertSheetView *sheetView;
@property (nonatomic, assign) BOOL isLiked;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // zhaohui.cn不需要清除缓存
    self.view.backgroundColor = UIColor.whiteColor;
    [self setNavBar];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loadWKWebView:[PWUtils getEthBtyAddress]];
    });
    
}

- (void)loadWKWebView:(NSString *)address
{
    for (UIView *view in self.view.subviews) {
        [view removeFromSuperview];
    }
    if (self.webView) {
        self.webView = nil;
    }
    
    if ([self.webUrl containsString:@" "]) {
        self.webUrl = [self.webUrl stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
        self.edgesForExtendedLayout = UIRectEdgeNone; //页面延伸到的边界
    }
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] initBroswerAddr:address rpcUrl:RPCUrl chainId:2999];
    
    [kMethodArr enumerateObjectsUsingBlock:^(NSString *method, NSUInteger idx, BOOL * _Nonnull stop) {
        [configuration.userContentController addScriptMessageHandler:self name:method];
    }];

    WKPreferences *preferences = [WKPreferences new];
    preferences.javaScriptCanOpenWindowsAutomatically = YES;
    configuration.preferences = preferences;
    
    self->_configuration = configuration;
    
    WKWebView * webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) configuration:self->_configuration];
    webView.scrollView.delegate = self;
    webView.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:webView];
    
    if (![_webUrl containsString:@"zhaohui.cn"])
       {
           if (@available(iOS 9.0, *)) {
                   //清除网页离线缓存
                   NSArray * types=@[WKWebsiteDataTypeDiskCache,//硬盘缓存
                                     WKWebsiteDataTypeOfflineWebApplicationCache,//离线应用缓存
                                     WKWebsiteDataTypeMemoryCache,//内存缓存
                                     WKWebsiteDataTypeIndexedDBDatabases,//索引数据库
                                     WKWebsiteDataTypeWebSQLDatabases];
                   NSSet *websiteDataTypes= [NSSet setWithArray:types];
                   NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
                   [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
                       
                   }];
               } else {
                   // Fallback on earlier versions
               }
           
           [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.webUrl] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:20.f]];
       }
    else
    {
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.webUrl]]];
    }
    //kvo 添加进度监控
    [webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    webView.UIDelegate = self;
    webView.navigationDelegate = self;
    self.webView = webView;

    [self.view addSubview:self.progressView];
    
    [self.webView addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:0 context:nil];

    [WKWebViewJavascriptBridge enableLogging];
    _bridge = [WKWebViewJavascriptBridge bridgeForWebView:webView];
    [_bridge setWebViewDelegate:self];

    [webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSString *currentVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
        NSString *userAgent = [NSString stringWithFormat:@"%@",result];
        NSString *addStr = [NSString stringWithFormat:@";wallet;%@",currentVersion];
        NSString *newUserAgent = [userAgent stringByAppendingString:addStr];//自定义需要拼接的字符串
        NSString *userClient = [NSString stringWithFormat:@"AlphaWallet/%@%@",currentVersion,@" 1inchWallet"];
        newUserAgent = [newUserAgent stringByAppendingString:userClient];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:newUserAgent, @"UserAgent", nil];
        [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
        [self.webView setCustomUserAgent:newUserAgent];
        [self->_bridge setWebViewDelegate:self];
    }];
    

    WEAKSELF
    [_bridge registerHandler:@"closeCurrentWebview" handler:^(id data, WVJBResponseCallback responseCallback) {
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    

    // 普通交易签名
    [_bridge registerHandler:@"sign" handler:^(id data, WVJBResponseCallback responseCallback) {
        [self authPayWithFaceIDType:FaceIDTypeSignRawTransaction res:responseCallback data:data];
        
    }];
    
   // 组交易签名
    [_bridge registerHandler:@"signTxGroup" handler:^(id data, WVJBResponseCallback responseCallback) {
        [self authPayWithFaceIDType:FaceIDTypeCoinsWithoutTxGroup res:responseCallback data:data];
        
    }];
    

    // 在浏览器中打开
    [_bridge registerHandler:@"browserOpen" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString *urlStr = [data objectForKey:@"url"];
        if (urlStr == nil) {
            [self showCustomMessage:@"发生了错误，请稍后再试".localized hideAfterDelay:2.f];
            return;
        }
        NSURL *url = [NSURL URLWithString:urlStr];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                
            }];
        }
    }];
    // 获取当前钱包BTY地址
    [_bridge registerHandler:@"getCurrentBTYAddress" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"-------- 0");
       
        NSString *btyAddressStr = [GameGoFunction querySelectedBtyAddress];

        NSLog(@"-------- %@",btyAddressStr);
        responseCallback(btyAddressStr);
    }];
    
    // 从H5得到主链的信息，然后返回给H5当前主链的地址
    [_bridge registerHandler:@"getAddress" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString *coinType = data[@"cointype"];
        NSString *address = [GameGoFunction queryAddressByChain:coinType];
        
        responseCallback(@{@"address":address});
    }];
    
    // 扫码
    [_bridge registerHandler:@"scanQRCode" handler:^(id data, WVJBResponseCallback responseCallback) {
        [weakSelf scanAction:responseCallback];
    }];
    
    //wifi名字
    [_bridge registerHandler:@"getCurrentWifi" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];
        CGFloat version = [phoneVersion floatValue];
        // 如果是iOS13 未开启地理位置权限 需要提示一下
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined && version >= 13) {
            self.locationManager = [[CLLocationManager alloc] init];
            [self.locationManager requestWhenInUseAuthorization];
            self.locationManager.delegate = self;
            self.getWifiCallback = responseCallback;
        }else if(([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) && version >= 13){
            UIAlertController* alertC = [UIAlertController alertControllerWithTitle:@"wifi信息获取失败".localized message:@"请前往设置打开定位权限，以获取wifi信息".localized preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* action = [UIAlertAction actionWithTitle:@"确定".localized style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alertC addAction:  action];
            [self presentViewController:alertC animated:true completion:nil];
            self.getWifiCallback = responseCallback;
        }else{
            responseCallback(@{@"name":[self getWifiName]});
        }
    }];
    //传输助记词给树莓派应用
    [_bridge registerHandler:@"importSeed" handler:^(id data, WVJBResponseCallback responseCallback) {
        [self authPayWithFaceIDType:FaceIDTypeImportSeed res:responseCallback data:@{}];
    }];
    //获取树莓派列表
    [_bridge registerHandler:@"getDeviceList" handler:^(id data, WVJBResponseCallback responseCallback) {
        [self.deviceList removeAllObjects];
        self.getDeviceCallback = responseCallback;
        if (self.socket == nil) {
            self.socket=[[AsyncUdpSocket alloc] initIPv4];
            self.socket.delegate = self;
            [self.socket bindToPort:8804 error:nil];
        }
        [self.socket receiveWithTimeout:100 tag:1];
    }];

}

-(NSString *)getWifiName{
    NSString *wifiName = @"Not Found WIFI";
    
    CFArrayRef myArray = CNCopySupportedInterfaces();
    
    if(myArray !=nil) {
        
        CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
        
        if(myDict !=nil) {
            
            NSDictionary*dict = (NSDictionary*)CFBridgingRelease(myDict);
            
            wifiName = [dict valueForKey:@"SSID"];
            
        }
        
    }
    return wifiName;
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
        self.getWifiCallback(@{@"name":[self getWifiName]});
    }
}

- (NSMutableArray *)deviceList{
    if (_deviceList == nil) {
        _deviceList = [[NSMutableArray alloc] init];
    }
    return _deviceList;
}

//接受信息
- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port{
    
    NSString* result;
    
    result = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    NSLog(@"%@",result);
    
    NSLog(@"%@",host);
    
    NSLog(@"收到啦");

    NSDictionary * device = @{@"serial":result,//设备唯一序列号
                              @"ip":host};
    if (![self.deviceList containsObject:device]) {
        [self.deviceList addObject:device];
    }else{
        self.getDeviceCallback(self.deviceList);
        return YES;
    }
    
    return NO;
}

//接受失败
-(void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error{
    
    NSLog(@"没有收到啊 ");
}

//关闭广播
-(void)onUdpSocketDidClose:(AsyncUdpSocket *)sock{
    
    NSLog(@"关闭啦");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.navigationController.navigationBar lt_setBackgroundColor:UIColor.whiteColor];

    if (@available(iOS 13.0, *)) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDarkContent;
    } else {
           // Fallback on earlier versions
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }
    
    if (@available(iOS 15, *))
    {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];

        appearance.backgroundColor = SGColorFromRGB(0xffffff);
        appearance.backgroundEffect = nil;
        appearance.shadowColor = UIColor.clearColor;
         appearance.titleTextAttributes = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:16], NSForegroundColorAttributeName : SGColorFromRGB(0x333649)};
        self.navigationController.navigationBar.standardAppearance = appearance;
        self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
    }
    else
    {
        [self.navigationController.navigationBar setBackgroundImage:[CommonFunction createImageWithColor:SGColorFromRGB(0xffffff)] forBarMetrics:UIBarMetricsDefault];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self getFeePrikeyWithPlatform:@"bty" CoinName:@"BTY"];
        [self getNonce];
        [self getGasPrice];
    });
    
   
    
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar lt_reset];
   
    [self.webView removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
   
}

- (void)showNotSupport
{
    // 暂不支持观察钱包，请切换至普通助记词钱包
    UIAlertController *alertvc = [UIAlertController alertControllerWithTitle:@"提示".localized
                                                                     message:@"当前钱包不支持该项目".localized
                                                              preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"知道了".localized
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
        [self homeAction];
    }];
    
    [alertvc addAction:action];
    
    [self.navigationController presentViewController:alertvc animated:YES completion:nil];

}

- (void)setNavBar{

    UIView* leftView = [[UIView alloc] init];
    leftView.backgroundColor = UIColor.whiteColor;
    //要给view预置高度不然不能点击
    [leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@44);
        make.width.equalTo(@96);
    }];

    UIButton* backBtn = [[UIButton alloc] init];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"webBack"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [leftView addSubview:backBtn];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@-16);
        make.centerY.equalTo(@0);
    }];
    UIButton* homeBtn = [[UIButton alloc] init];
    [homeBtn setImage:[UIImage imageNamed:@"webHome"] forState:UIControlStateNormal];
    [homeBtn addTarget:self action:@selector(homeAction) forControlEvents:UIControlEventTouchUpInside];
    [homeBtn sizeToFit];
//    [leftView addSubview:homeBtn];
//    [homeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(backBtn.mas_right);
//        make.centerY.equalTo(@0);
//    }];
    UIBarButtonItem *leftItem= [[UIBarButtonItem alloc] initWithCustomView:leftView];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIView* rightView = [[UIView alloc] init];
    rightView.backgroundColor= UIColor.whiteColor;
    [rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@44);
        make.width.equalTo(@96);
    }];

    UIButton* moreBtn = [[UIButton alloc] init];
    [moreBtn setImage:[UIImage imageNamed:@"web_more"] forState:UIControlStateNormal];
    
    [moreBtn addTarget:self action:@selector(moreAction) forControlEvents:UIControlEventTouchUpInside];
    [moreBtn sizeToFit];
    [rightView addSubview:moreBtn];
    [moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@16);
        make.centerY.equalTo(@0);
        make.width.mas_equalTo(50);
    }];
    
    UIButton* refreshBtn = [[UIButton alloc] init];
    [refreshBtn setImage:[UIImage imageNamed:@"webRefresh"] forState:UIControlStateNormal];
    [refreshBtn addTarget:self action:@selector(reloadWeb) forControlEvents:UIControlEventTouchUpInside];
    [refreshBtn sizeToFit];
//    [rightView addSubview:refreshBtn];
//    [refreshBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(moreBtn.mas_left);
//        make.centerY.equalTo(@0);
//    }];
    

    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightView];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return nil;
}



- (void)backAction {
    if (self.webView.canGoBack == YES) {
        //返回上级页面
        [self.webView goBack];
    }else{
        [self homeAction];
    }
}

-(void)homeAction {
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(void)reloadWeb {
    NSURL *url = self.webView.URL;
    if (url)
    {
        [self.webView reloadFromOrigin];
    }
    else
    {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.webUrl]]];
    }
}

- (void)scanAction:(WVJBResponseCallback)responseCallback {
    [self.view endEditing:true];
    ScanViewController *vc = [[ScanViewController alloc] init];
    [self.navigationController pushViewController:vc animated:false];
    vc.scanResult = ^(NSString *address) {
        if ([address containsString:@","])
        {
            NSArray *array = [address componentsSeparatedByString:@","];
            if (array.count == 3) {
                NSString *add = [NSString stringWithFormat:@"%@",array[2]];
                responseCallback(add);
            }
            else if (array.count == 2)
            {
                NSString *add = [NSString stringWithFormat:@"%@",array[1]];
                responseCallback(add);
            }
        }
        else
        {
            responseCallback(address);
        }

    };
}

- (void)likeAppAction{
    
    
    
    NSDictionary *app = @{@"name":self.title,
                           @"url":self.webUrl,
                           @"icon":self.iconUrl == nil ? @"" : self.iconUrl,
                          @"appId":self.appId == nil ? @"1111111" : self.appId};
//    PWApplication *app = [[PWApplication alloc] init];
//    app.name = self.title;
//    app.app_url = self.webUrl;
//    app.icon = self.iconUrl;
    
    if (self.isLiked) {
        [RecentlyUsedAppTool deleteLikeApp:app];
    }else{
        [RecentlyUsedAppTool setLikeApp:app];
    }
    
    
    
}

-(void)moreAction {
    
    // 先判断该网址是否已经收藏，用于显示收藏按钮图标
    NSArray *likedArr = [RecentlyUsedAppTool getLikeAppArray];
    NSMutableArray *likedUrlArr = [NSMutableArray arrayWithCapacity:likedArr.count];
    for (NSDictionary *dict in likedArr) {
        NSString *url = dict[@"url"];
        [likedUrlArr addObject:url];
    }
    
    self.isLiked = NO;
    if ([likedUrlArr containsObject:self.webUrl]) {
        self.isLiked = YES;
    }
    
    WebSheetView *sheetVew = [[WebSheetView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) isLiked:self.isLiked];
    
    sheetVew.sheetBlock = ^(WebSheetType sheetType) {
        switch (sheetType) {
            case WebSheetTypeChangeAccount:
            {
                
                [self showAccountView];
            }
                break;
            case WebSheetTypeRefresh:
            {
                [self reloadWeb];
            }
                break;
            case WebSheetTypeCopyUrl:
            {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = self.webUrl;
                [self showCustomMessage:@"复制成功".localized hideAfterDelay:2.0];
            }
                break;
            case WebSheetTypeOpenUrl:
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.webUrl]  options:@{}
                                         completionHandler:^(BOOL success) {
                    NSLog(@"Open %d",success);
                }];
            }
                break;
            case WebSheetTypeExit:
            {
                [self homeAction];
            }
                break;
            case  WebSheetTypeLike:{
                [self likeAppAction];
            }
                break;
                
            default:
                break;
        }
    };
    
    [sheetVew showWithView:self.view];
    return;
    
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

   
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"复制链接".localized style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = self.webUrl;
        [self showCustomMessage:@"复制成功".localized hideAfterDelay:2.0];
    }];
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"在浏览器中打开".localized style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
       
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.webUrl]  options:@{}
                                 completionHandler:^(BOOL success) {
            NSLog(@"Open %d",success);
        }];
        
    }];

    UIAlertAction *action6 = [UIAlertAction actionWithTitle:@"取消".localized style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"取消");
    }];

    [actionSheet addAction:action2];
    [actionSheet addAction:action3];
    [actionSheet addAction:action6];
//#endif
    //相当于之前的[actionSheet show];
    [self presentViewController:actionSheet animated:YES completion:nil];

}



- (void)showAccountView
{
    WebChangeAccountSheetView *sheetView = [[WebChangeAccountSheetView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    sheetView.changeBlock = ^(LocalWallet * _Nonnull wallet) {
        [self loadWKWebView:[PWUtils getEthBtyAddress]];
    };
    [sheetView showWithView:self.view];
}

- (NSString *)convertToJsonData:(NSDictionary *)dict
{

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;

    if (!jsonData) {
        NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    return mutStr;

}
//签名
- (void)signAction:(WVJBResponseCallback)responseCallback  object:(NSDictionary *)dic{
    
    if (!IS_BLANK(self.priKey)) {
        NSString *hashTx = dic[@"createHash"];
        NSString *coinType = dic[@"cointype"];
        NSData* hashData = WalletapiHexTobyte(hashTx);
        
        WalletapiSignData *signData = [[WalletapiSignData alloc] init];
        signData.data = hashData;
        signData.cointype = [coinType isEqualToString:@"YCC"] ? @"ETH" : @"BTY";
        signData.privKey = self.priKey;
        signData.addressID =  [coinType isEqualToString:@"YCC"] ? 2 : 0;
        NSString *signedHash =  WalletapiSignRawTransaction(signData, nil);
        
        NSDictionary *param = @{@"signHash":signedHash};
        responseCallback(param);
        return;
    }
    
    LocalWallet *selectedWallet = [[PWDataBaseManager shared] queryWalletIsSelected];
    PWAlertController *alertVC = [[PWAlertController alloc] initWithTitle:@"请输入钱包密码".localized withTextValue:@""leftButtonName:nil rightButtonName:@"确定".localized handler:^(ButtonType type, NSString *text) {
        if (type == ButtonTypeLeft){
            NSDictionary *param = @{@"error":@"取消支付".localized  };
            responseCallback(param);
        }
        if (type == ButtonTypeRight) {
            if ([GoFunction checkPassword:text hash:selectedWallet.wallet_password]) {
                NSString *hashTx = dic[@"createHash"];
                NSString *coinType = dic[@"cointype"];
                NSString *rememberCode = [GoFunction deckey:selectedWallet.wallet_remembercode password:text];
                WalletapiHDWallet *hdWallet = WalletapiNewWalletFromMnemonic_v2([coinType isEqualToString:@"YCC"] ? @"ETH" : @"BTY",[self remv:rememberCode],nil );
                NSString *priKey = [[hdWallet newKeyPriv:0 error:nil] hexString];
                LocalWallet *wallet = [[PWDataBaseManager shared] queryWalletIsSelected];
                if (wallet.wallet_issmall == 2) {
                    // 私钥钱包的话，保存的助记词就是私钥
                    priKey = rememberCode;
                }
                NSData* hashData = WalletapiHexTobyte(hashTx);
                WalletapiSignData *signData = [[WalletapiSignData alloc] init];
                signData.data = hashData;
                signData.cointype = [coinType isEqualToString:@"YCC"] ? @"ETH" : @"BTY";
                signData.privKey = priKey;
                signData.addressID =  [coinType isEqualToString:@"YCC"] ? 2 : 0;
                NSString *signedHash =  WalletapiSignRawTransaction(signData, nil);
                NSDictionary *param = @{@"signHash":signedHash};
                responseCallback(param);
            } else {
                [self showCustomMessage:@"密码错误".localized hideAfterDelay:1];
                NSDictionary *param = @{@"error":@"取消支付".localized  };
                responseCallback(param);
            }
        }
    }];
    alertVC.closeVC = ^{
        NSLog(@"取消支付");
        NSDictionary *param = @{@"error":@"取消支付".localized  };
        responseCallback(param);
        
    };
    alertVC.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    [self presentViewController:alertVC animated:false completion:nil];
}

- (void)signTxroup:(WVJBResponseCallback)responseCallback object:(NSDictionary *)dic
{
    
    if (!IS_BLANK(self.priKey)) {
        NSString *hashTx = dic[@"createHash"];
        NSString *coinType = dic[@"cointype"];
        NSInteger length = 3;
        if ([hashTx containsString:@","])
        {
            NSArray *array = [hashTx componentsSeparatedByString:@","];
            if (array.count != 0 ) {
                length = array.count + 2;
            }
        }
        WalletapiGWithoutTx *gtx = [[WalletapiGWithoutTx alloc] init];
//        if([dic[@"withhold"] isEqualToNumber:@-1]){
            [gtx setFeepriv:self.priKey];// 用户私钥
//        }else{
//            [gtx setFeepriv:self.feePrikey];// 接口获取代扣私钥
//        }
        [gtx setTxpriv:self.priKey];
        [gtx setRawTx:hashTx];
        [gtx setNoneExecer:dic[@"exer"]];
        [gtx setFee:self.btyFeeValue*length];
        [gtx setFeeAddressID:[coinType isEqualToString:@"YCC"] ? 2 : 0];
       
        NSError *error;
        WalletapiGsendTxResp *resp = WalletapiCoinsWithoutTxGroup(gtx, &error);
        NSString *signedHash = resp.signedTx;
        if (resp == nil) {
            [self showCustomMessage:@"操作失败，请重新进入页面".localized hideAfterDelay:2.f];
            return;
        }
        NSDictionary *param = @{@"signHash":signedHash};
        responseCallback(param);
        return;
    }
    LocalWallet *selectedWallet = [[PWDataBaseManager shared] queryWalletIsSelected];
    PWAlertController *alertVC = [[PWAlertController alloc] initWithTitle:@"请输入钱包密码".localized withTextValue:@""leftButtonName:nil rightButtonName:@"确定".localized handler:^(ButtonType type, NSString *text) {
        if (type == ButtonTypeLeft){
            NSDictionary *param = @{@"error":@"取消支付".localized  };
            responseCallback(param);
        }
        if (type == ButtonTypeRight) {
            if ([GoFunction checkPassword:text hash:selectedWallet.wallet_password]) {
                NSString *hashTx = dic[@"createHash"];
                NSString *coinType = dic[@"cointype"];
                NSString *rememberCode = [GoFunction deckey:selectedWallet.wallet_remembercode password:text];
                WalletapiHDWallet *hdWallet = WalletapiNewWalletFromMnemonic_v2([coinType isEqualToString:@"YCC"] ? @"ETH" : @"BTY",[self remv:rememberCode],nil );
                
                NSString *priKey = [[hdWallet newKeyPriv:0 error:nil] hexString];
                LocalWallet *wallet = [[PWDataBaseManager shared] queryWalletIsSelected];
                if (wallet.wallet_issmall == 2) {
                    // 私钥钱包的话，保存的助记词就是私钥
                    priKey = rememberCode;
                }
                
                NSInteger length = 3;
                if ([hashTx containsString:@","])
                {
                    NSArray *array = [hashTx componentsSeparatedByString:@","];
                    if (array.count != 0 ) {
                        length = array.count + 2;
                    }
                }
                WalletapiGWithoutTx *gtx = [[WalletapiGWithoutTx alloc] init];
//                if([dic[@"withhold"] isEqualToNumber:@-1]){
                    [gtx setFeepriv:priKey];// 用户私钥
//                }else{
//                    [gtx setFeepriv:self.feePrikey];// 接口获取代扣私钥
//                }
                [gtx setTxpriv:priKey];
                [gtx setRawTx:hashTx];
                [gtx setNoneExecer:dic[@"exer"]];
                [gtx setFee:self.btyFeeValue*length];
                [gtx setFeeAddressID:[coinType isEqualToString:@"YCC"] ? 2 : 0];
                NSError *error;
                WalletapiGsendTxResp *resp = WalletapiCoinsWithoutTxGroup(gtx, &error);
                NSString *signedHash = resp.signedTx;
                if (signedHash == nil) {
                    [self showCustomMessage:@"操作失败，请重新进入页面".localized hideAfterDelay:2.f];
                    return;
                }
                NSDictionary *param = @{@"signHash":signedHash};
                responseCallback(param);
            } else {
                [self showCustomMessage:@"密码错误".localized hideAfterDelay:1];
                NSDictionary *param = @{@"error":@"取消支付".localized  };
                responseCallback(param);
            }
        }
    }];
    alertVC.closeVC = ^{
        NSLog(@"取消支付");
        NSDictionary *param = @{@"error":@"取消支付".localized  };
        responseCallback(param);
        
    };
    alertVC.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    [self presentViewController:alertVC animated:false completion:nil];
}

- (NSString *)remv:(NSString *)menc
{
    NSString *codeStr = [PWUtils removeSpaceAndNewline:menc];
    if([PWUtils isChineseWithstr:codeStr]){
        NSMutableString *str = [NSMutableString new];
        for (int i = 0; i < codeStr.length; i ++) {
            [str appendString:[codeStr substringWithRange:NSMakeRange(i, 1)]];
            if (i != codeStr.length - 1) {
                [str appendString:@" "];
            }
        }
        
        return [NSString stringWithString:str];
    }else{
        return menc;
    }
    
   
}


#pragma mark - 去钱包首页
- (void)toWallet
{
   
    if (![PWUtils checkExistWallet])
    {
        PWNewsHomeNoWalletViewController *homeVC = [[PWNewsHomeNoWalletViewController alloc] init];
        [self.navigationController pushViewController:homeVC animated:YES];
    }
    else
    {
        PWNewsHomeViewController *homeVC = [[PWNewsHomeViewController alloc] init];
        [self.navigationController pushViewController:homeVC animated:YES];
    }
   
}

#pragma mark - 获取代扣私钥
- (void)getFeePrikeyWithPlatform:(NSString *)platform CoinName:(NSString *)coinName
{
    NSDictionary *param =  @{@"platform":platform,@"coinname":coinName};
    WEAKSELF
    [[SGNetWork defaultManager] sendRequestMethod:HTTPMethodGET serverUrl:WalletURL apiPath:@"/interface/coin/get-with-hold" parameters:param progress:nil success:^(BOOL isSuccess, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        
        NSInteger code = [result[@"code"] integerValue];
        if(code == 0) {
            NSDictionary *dict = result[@"data"];
            if ([dict isKindOfClass:[NSNull class]])
            {
                weakSelf.feePrikey = @"";
                weakSelf.btyFeeValue = 0;
            }
            else
            {
                weakSelf.feePrikey = [self decodeDesWithString:result[@"data"][@"private_key"]];
                weakSelf.btyFeeValue = [result[@"data"][@"bty_fee"] doubleValue];
            }
            
        }else{
            
        }
    } failure:^(NSString * _Nullable errorMessage) {
        
    }];
}

- (NSString *)decodeDesWithString:(NSString *)str{
    NSData *encryptData = [[NSData alloc] initWithBase64EncodedString:str options:NSDataBase64DecodingIgnoreUnknownCharacters];
    size_t plainTextBufferSize = [encryptData length];
    const void *vplainText = [encryptData bytes];
    CCCryptorStatus ccStatus;
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    bufferPtrSize = (plainTextBufferSize + kCCBlockSizeDES) & ~(kCCBlockSizeDES - 1);
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    const void *vkey = (const void *) [DESKeyForGame UTF8String];
    const void *vinitVec = (const void *) [kInitVectorForGame UTF8String];
    ccStatus = CCCrypt(kCCDecrypt,
                       kCCAlgorithmDES,
                       kCCOptionPKCS7Padding,
                       vkey,
                       kCCKeySizeDES,
                       vinitVec,
                       vplainText,
                       plainTextBufferSize,
                       (void *)bufferPtr,
                       bufferPtrSize,
                       &movedBytes);
    if (ccStatus == kCCSuccess)
    {
        NSString *result = [[NSString alloc] initWithData:[NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes] encoding:NSUTF8StringEncoding];
        return result;
    }
   
    return @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *url = navigationAction.request.URL;
    NSString *loadUrl = [url absoluteString];

    NSLog(@"---------------->URL变化%@",loadUrl);

//    decisionHandler(WKNavigationActionPolicyCancel);
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if (navigationAction.request.URL) {
        NSURL *url = navigationAction.request.URL;
        NSString *urlPath = url.absoluteString;
        if ([urlPath rangeOfString:@"https://"].location != NSNotFound || [urlPath rangeOfString:@"http://"].location != NSNotFound) {
            
            [[UIApplication sharedApplication] openURL:url];
        }
    }
    return nil;
}

- (void)webView:(WKWebView *)webView startURLSchemeTask:(id<WKURLSchemeTask>)urlSchemeTask{
    if (urlSchemeTask.request.URL.path != nil) {
        NSString *fileExtension = urlSchemeTask.request.URL.pathExtension;
        if ([fileExtension isEqualToString:@"otf"]){
            NSString *nameWithoutExtengsion = urlSchemeTask.request.URL.URLByDeletingPathExtension.lastPathComponent;
            NSURL *url = [NSBundle.mainBundle URLForResource:nameWithoutExtengsion withExtension:fileExtension];
            NSData *data = [NSData dataWithContentsOfURL:url options:NSDataReadingMapped error:nil];
            NSURLResponse *response = [[NSURLResponse alloc] initWithURL:urlSchemeTask.request.URL MIMEType:@"font/opentype" expectedContentLength:data.length textEncodingName:nil];
            [urlSchemeTask didReceiveResponse:response];
            [urlSchemeTask didReceiveData:data];
            [urlSchemeTask didFinish];
            return;
            
        }
    }
}

- (void)webView:(WKWebView *)webView stopURLSchemeTask:(id<WKURLSchemeTask>)urlSchemeTask{
   
}



- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
   
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"error %@",error);
}

//KVO监听进度条
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))] && object == self.webView) {
        [self.progressView setAlpha:1.0f];
        BOOL animated = self.webView.estimatedProgress > self.progressView.progress;
        [self.progressView setProgress:self.webView.estimatedProgress animated:animated];
        if(self.webView.estimatedProgress >= 1.0f) {
            [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.progressView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [self.progressView setProgress:0.0f animated:NO];
            }];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark ---- 进度条 ------
- (UIProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 3);
        
        // 设置进度条的色彩
        [_progressView setTrackTintColor:[UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0]];
        _progressView.progressTintColor = [UIColor colorWithRed:113.0/255 green:144.0/255 blue:255.0/255 alpha:1.0];
    }
    return _progressView;
}


#pragma mark -- 面容or指纹支付
- (void)authPayWithFaceIDType:(FaceIDType )faceidType res:(WVJBResponseCallback)responseCallBack data:(NSDictionary *)dic
{
    // 判断是否需要面容支付
    NSString *passwd = @"";
    LocalWallet *wallet = [[PWDataBaseManager shared] queryWalletIsSelected];
    if(wallet.wallet_issmall == 3){
        [self showNotSupport];
        return;
    }
    NSMutableDictionary *mudict = [[PWAppsettings instance] getWalletInfo];
    if (mudict == nil) {
        [self facePayState:faceidType passwd:@"" data:dic res:responseCallBack succeed:NO];
        return;
    }else{
        NSString *walletId = [NSString stringWithFormat:@"%ld",wallet.wallet_id];
        passwd = [mudict objectForKey:walletId];
        if (passwd == nil)
        {
            // 当前钱包没有密码数据，指纹or面容支付没有开启
            [self facePayState:faceidType passwd:@"" data:dic res:responseCallBack succeed:NO];
            return;
        }
    }
    YZAuthID *authId = [[YZAuthID alloc] init];
    NSString *passwdStr = [PWUtils decryptString:passwd];
    [authId yz_showAuthIDWithDescribe:nil block:^(YZAuthIDState state, NSError *error) {
        switch (state) {
            case YZAuthIDStateNotSupport:
            {
                NSLog(@"当前设备不支持TouchId、FaceId");
                [self facePayState:faceidType passwd:@"" data:dic res:responseCallBack succeed:NO];
            }
                break;
            case YZAuthIDStateSuccess:
            {
                NSLog(@"验证成功");
//
                [self facePayState:faceidType passwd:passwdStr data:dic res:responseCallBack succeed:YES];
            }
                break;
            case YZAuthIDStateFail:
            {
                NSLog(@" 验证失败");
            }
                break;
            case YZAuthIDStateUserCancel:
            {
                NSLog(@"TouchID/FaceID 被用户手动取消");
            }
                break;
            case YZAuthIDStateInputPassword:
            {
                NSLog(@"用户不使用TouchID/FaceID,选择手动输入密码");
                [self facePayState:faceidType passwd:@"" data:dic res:responseCallBack succeed:NO];
            }
                break;
            case YZAuthIDStateSystemCancel:
            {
                NSLog(@"TouchID/FaceID 被系统取消 (如遇到来电,锁屏,按了Home键等)");
            }
                break;
            case YZAuthIDStatePasswordNotSet:
            {
                NSLog(@" TouchID/FaceID 无法启动,因为用户没有设置密码");
                [self facePayState:faceidType passwd:@"" data:dic res:responseCallBack succeed:NO];
            }
                break;
            case YZAuthIDStateTouchIDNotSet:
            {
                NSLog(@"TouchID/FaceID 无法启动,因为用户没有设置TouchID/FaceID");
                [self facePayState:faceidType passwd:@"" data:dic res:responseCallBack succeed:NO];
            }
                break;
            case YZAuthIDStateTouchIDNotAvailable:
            {
                NSLog(@"TouchID/FaceID 无效");
                [self facePayState:faceidType passwd:@"" data:dic res:responseCallBack succeed:NO];
            }
                break;
            case YZAuthIDStateTouchIDLockout:
            {
                NSLog(@"TouchID/FaceID 被锁定(连续多次验证TouchID/FaceID失败,系统需要用户手动输入密码)");
            }
                break;
            case YZAuthIDStateAppCancel:
            {
                NSLog(@"当前软件被挂起并取消了授权 (如App进入了后台等)");
            }
                break;
            case YZAuthIDStateInvalidContext:
            {
                NSLog(@" 当前软件被挂起并取消了授权 (LAContext对象无效)");
            }
                break;
            case YZAuthIDStateVersionNotSupport:
            {
                NSLog(@"系统版本不支持TouchID/FaceID (必须高于iOS 8.0才能使用)");
                [self facePayState:faceidType passwd:@"" data:dic res:responseCallBack succeed:NO];
            }
                break;
                
            default:
                break;
        }
    }];
}


- (void)facePayState:(FaceIDType)faceidType  passwd:(NSString *)text data:(NSDictionary *)dic res:(WVJBResponseCallback)responseCallback succeed:(BOOL)succeed
{
    LocalWallet *selectedWallet = [[PWDataBaseManager shared] queryWalletIsSelected];
    switch (faceidType) {
        case FaceIDTypeImportSeed:
        {
            if (succeed) {
                // 指纹or面容成功
                if ([GoFunction checkPassword:text hash:selectedWallet.wallet_password]) {
                    NSString *rememberCode = [GoFunction deckey:selectedWallet.wallet_remembercode password:text];
                    NSDictionary *param = @{@"seed":rememberCode,@"passwd":text};
                    responseCallback(param);
                } else {
                    [self showCustomMessage:@"密码错误".localized hideAfterDelay:1];
                }
            }else{
                // 各种失败情况
                [self importSeed:selectedWallet res:responseCallback];
            }
        }
            break;
        case  FaceIDTypeSignRawTransaction:
        {
            if (succeed) {
                // 指纹or面容成功
                if ([GoFunction checkPassword:text hash:selectedWallet.wallet_password]) {
                    NSString *hashTx = dic[@"createHash"];
                    NSString *coinType = dic[@"cointype"];
                    NSString *rememberCode = [GoFunction deckey:selectedWallet.wallet_remembercode password:text];
                    WalletapiHDWallet *hdWallet = WalletapiNewWalletFromMnemonic_v2([coinType isEqualToString:@"YCC"] ? @"ETH" : @"BTY",[self remv:rememberCode],nil );
                    NSString *priKey = [[hdWallet newKeyPriv:0 error:nil] hexString];
                    LocalWallet *wallet = [[PWDataBaseManager shared] queryWalletIsSelected];
                    if (wallet.wallet_issmall == 2) {
                        // 私钥钱包的话，保存的助记词就是私钥
                        priKey = rememberCode;
                    }
                    NSData* hashData = WalletapiHexTobyte(hashTx);
                    WalletapiSignData *signData = [[WalletapiSignData alloc] init];
                    signData.data = hashData;
                    signData.cointype = [coinType isEqualToString:@"YCC"] ? @"ETH" : @"BTY";
                    signData.privKey = priKey;
                    signData.addressID =  [coinType isEqualToString:@"YCC"] ? 2 : 0;
                    NSString *signedHash =  WalletapiSignRawTransaction(signData, nil);
                    NSDictionary *param = @{@"signHash":signedHash};
                    responseCallback(param);
                } else {
                    [self showCustomMessage:@"密码错误".localized hideAfterDelay:1];
                    NSDictionary *param = @{@"error":@"取消支付".localized  };
                    responseCallback(param);
                }
            }else{
                // 各种失败情况
                [self signAction:responseCallback object:dic];
            }
        }
            break;
        case FaceIDTypeCoinsWithoutTxGroup:
        {
            if (succeed) {
                // 指纹or面容成功
                if ([GoFunction checkPassword:text hash:selectedWallet.wallet_password]) {
                    NSString *hashTx = dic[@"createHash"];
                    NSString *coinType = dic[@"cointype"];
                    NSString *rememberCode = [GoFunction deckey:selectedWallet.wallet_remembercode password:text];
                    WalletapiHDWallet *hdWallet = WalletapiNewWalletFromMnemonic_v2([coinType isEqualToString:@"YCC"] ? @"ETH" : @"BTY",[self remv:rememberCode],nil );
                    
                    NSString *priKey = [[hdWallet newKeyPriv:0 error:nil] hexString];
                    LocalWallet *wallet = [[PWDataBaseManager shared] queryWalletIsSelected];
                    if (wallet.wallet_issmall == 2) {
                        // 私钥钱包的话，保存的助记词就是私钥
                        priKey = rememberCode;
                    }
                    
                    NSInteger length = 3;
                    if ([hashTx containsString:@","])
                    {
                        NSArray *array = [hashTx componentsSeparatedByString:@","];
                        if (array.count != 0 ) {
                            length = array.count + 2;
                        }
                    }
                    WalletapiGWithoutTx *gtx = [[WalletapiGWithoutTx alloc] init];
//                    if([dic[@"withhold"] isEqualToNumber:@-1]){
                        [gtx setFeepriv:priKey];// 用户私钥
//                    }else{
//                        [gtx setFeepriv:self.feePrikey];// 接口获取代扣私钥
//                    }
                    [gtx setTxpriv:priKey];
                    [gtx setRawTx:hashTx];
                    [gtx setNoneExecer:dic[@"exer"]];
                    [gtx setFee:self.btyFeeValue*length];
                    [gtx setFeeAddressID:[coinType isEqualToString:@"YCC"] ? 2 : 0];
                    NSError *error;
                    WalletapiGsendTxResp *resp = WalletapiCoinsWithoutTxGroup(gtx, &error);
                    NSString *signedHash = resp.signedTx;
                    if (signedHash == nil) {
                        [self showCustomMessage:@"操作失败，请重新进入页面".localized hideAfterDelay:2.f];
                        return;
                    }
                    NSDictionary *param = @{@"signHash":signedHash};
                    responseCallback(param);
                } else {
                    [self showCustomMessage:@"密码错误".localized hideAfterDelay:1];
                    NSDictionary *param = @{@"error":@"取消支付".localized  };
                    responseCallback(param);
                }
            }else{
                // 各种失败情况
                [self signTxroup:responseCallback object:dic];
            }
        }
            break;
        default:
            break;
    }
}


- (void)importSeed:(LocalWallet *)wallet res:(WVJBResponseCallback)responseCallback
{
    PWAlertController *alertVC = [[PWAlertController alloc] initWithTitle:@"请输入钱包密码".localized withTextValue:@""  leftButtonName:nil rightButtonName:@"确定".localized handler:^(ButtonType type, NSString *text) {
        if (type == ButtonTypeLeft){
            NSDictionary *param = @{@"error":@"取消支付".localized};
            responseCallback(param);
        }
        if (type == ButtonTypeRight) {
            if ([GoFunction checkPassword:text hash:wallet.wallet_password]) {
                NSString *rememberCode = [GoFunction deckey:wallet.wallet_remembercode password:text];
                NSDictionary *param = @{@"seed":rememberCode,@"passwd":text};
                responseCallback(param);
            } else {
                [self showCustomMessage:@"密码错误".localized hideAfterDelay:1];
            }
        }
            
    }];
    alertVC.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    [self presentViewController:alertVC animated:false completion:nil];
}

#pragma mark - js method

- (void)userContentController:(nonnull WKUserContentController *)userContentController didReceiveScriptMessage:(nonnull WKScriptMessage *)message {
    NSLog(@"message->%@",message.body);
    NSDictionary *mesDict = message.body;
    if ([message.name isEqualToString:@"ethCall"])
    {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *obj = mesDict[@"object"];
            NSInteger callbackId = [mesDict[@"id"] integerValue];
            [self ethCall:obj callBackId:callbackId];
        });
    }
    else if ([message.name isEqualToString:@"sendTransaction"])
    {
        LocalWallet *wallet = [[PWDataBaseManager shared] queryWalletIsSelected];
        if(wallet.wallet_issmall == 3){
            [self showNotSupport];
            return;
        }
        NSDictionary *obj = mesDict[@"object"];
        NSInteger callbackId = [mesDict[@"id"] integerValue];
        // 要弹框
        [self showsAlert:obj callBackId:callbackId];
    }
    else if ([message.name isEqualToString:@"signPersonalMessage"])
    {
        NSInteger callbackId = [mesDict[@"id"] integerValue];
        NSDictionary *obj = mesDict[@"object"];
        [self signPersonalMessage:obj callBackId:callbackId];
    }
    else if ([message.name isEqualToString:@"walletSwitchEthereumChain"]){
        NSString *chainId = [self sixteenToTen:mesDict[@"chainId"]];
        NSInteger callbackId = [mesDict[@"id"] integerValue];
        if (chainId.floatValue != 2999 ) {
            [self showCustomMessage:@"暂不支持该网络".localized hideAfterDelay:2.f];
//            NSString *javaScript = [NSString stringWithFormat:@"executeCallback(%li, {message: \"response error\", code: -32010}, null)",callbackId];
//            [self.webView evaluateJavaScript:javaScript completionHandler:^(id _Nullable result, NSError * _Nullable error) {
//                
//            }];
        }
    }
    
}
- (void)ethCall:(NSDictionary *)obj callBackId:(NSInteger)callbackId{
    NSString *from = obj[@"from"];
    NSString *to = obj[@"to"];
    NSString *data = obj[@"data"];
    NSDictionary *params = @{@"from":from,
                             @"to":to,
                             @"data":data};
    NSDictionary *param = @{@"id":@1,
                            @"jsonrpc":@"2.0",
                            @"method":@"eth_call",
                            @"params":@[params]};
    
    
    [[SGNetWork defaultManager] sendRequestMethod:HTTPMethodPOST
                                        serverUrl:RPCUrl
                                          apiPath:@""
                                       parameters:param
                                         progress:nil
                                          success:^(BOOL isSuccess, id  _Nullable responseObject) {
        
        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"eth_call response is %@",jsonData);
        NSString *result = jsonData[@"result"];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *javaScript = [NSString stringWithFormat:@"executeCallback(%li,null,\"%@\")",callbackId,result];
            [self.webView evaluateJavaScript:javaScript completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                
            }];
        });
       
    } failure:^(NSString * _Nullable errorMessage) {
        NSLog(@"error is %@",errorMessage);
        
    }];
}

- (void)signPersonalMessage:(NSDictionary *)obj callBackId:(NSInteger)callbackId
{
    NSArray *coinArray = [[PWDataBaseManager shared] queryCoinArrayBasedOnSelectedWalletID];
    for (LocalCoin *coin in coinArray) {
        if([coin.coin_type isEqualToString:@"BTY"] && [coin.coin_chain isEqualToString:@"ETH"]){
            self.localCoin = coin;
            break;
        }
    }
    NSString *messages  = obj[@"data"];
    NSDictionary *dict = @{@"name":@"BitYuan Mainnet",
                           @"url":self.webUrl,
                           @"icon_url":@"",
                           @"addr":self.localCoin.coin_address,
                           @"message":messages};

    
    DappAlertSheetView *sheetView = [[DappAlertSheetView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)
                                                                     withType:DappAlertSheetTypePersonalSign
                                                                     withData:dict
                                                                     withCoin:self.localCoin];
    sheetView.dappBlock = ^(NSString * _Nonnull passwdStr,NSString * _Nonnull selectedGas,NSString * _Nonnull selectedGasPrice) {
        if(passwdStr.length == 0){
            [self showCustomMessage:@"请输入钱包密码".localized hideAfterDelay:2.f];
            return;
        }else if ([passwdStr isEqualToString:@"取消"]){
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *javaScript = [NSString stringWithFormat:@"executeCallback(%li,null,\"%@\")",callbackId,@""];
                [self.webView evaluateJavaScript:javaScript completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                    
                }];
            });
            return;
        }else{
            LocalWallet *wallet = [[PWDataBaseManager shared] queryWalletIsSelected];
            NSString *remebercode = [GoFunction deckey:wallet.wallet_remembercode password:passwdStr];
            WalletapiHDWallet *hdWallet = WalletapiNewWalletFromMnemonic_v2(self.localCoin.coin_chain,[self remv:remebercode],nil );
            if (hdWallet == nil) {
                [self showCustomMessage:@"密码错误".localized hideAfterDelay:2.f];
                return;
            }
            NSString *prikey = [[hdWallet newKeyPriv:0 error:nil] hexString];
            self.priKey = prikey;
            BrowserViewController *vc = [[BrowserViewController alloc] init];
            [vc signPersonalMessageWithMessage:messages prikey:self.priKey completionHandler:^(NSString * _Nullable result) {
                NSLog(@"personalsign message %@",result);
                [self.sheetView dismiss];
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *javaScript = [NSString stringWithFormat:@"executeCallback(%li,null,\"%@\")",callbackId,result];
                    [self.webView evaluateJavaScript:javaScript completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                        
                    }];
                });
            }];
            
        }
    };
    self.sheetView = sheetView;
    [self.sheetView showWithView:self.view];
}

- (void)showsAlert:(NSDictionary *)obj callBackId:(NSInteger)callbackId {
    
    [self.view endEditing:YES];
    
    NSString *from = obj[@"from"];
    NSString *to = obj[@"to"];
    NSString *value = [self sixteenToTen:obj[@"value"]]; // 需要把16进制转为10进制
    NSString *gas = @"21000"; // 需要把16进制转为10进制
    double realGas = (gas.doubleValue * self.gasPrice.doubleValue) / 1000000000000000000.0;
    
    NSArray *paramArray = @[@{@"name":@"支付信息",
                              @"info":@"转账"},
                            @{@"name":@"收款地址",
                              @"info":to},
                            @{@"name":@"付款地址",
                              @"info":from},
                            @{@"name":@"矿工费",
                              @"info":@(realGas)}];
    
   
    NSDictionary  *dict = @{@"name":@"BitYuan Mainnet",
                            @"url":self.webUrl,
                            @"icon_url":@"",
                            @"paramArray":paramArray,
                            @"value":value};
    
    NSArray *coinArray = [[PWDataBaseManager shared] queryCoinArrayBasedOnSelectedWalletID];
    for (LocalCoin *coin in coinArray) {
        if([coin.coin_type isEqualToString:@"BTY"] && [coin.coin_chain isEqualToString:@"ETH"]){
            self.localCoin = coin;
            break;
        }
    }
    DappAlertSheetView *sheetView = [[DappAlertSheetView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)
                                                                     withType:DappAlertSheetTypePay
                                                                     withData:dict
                                                                     withCoin:self.localCoin];
    sheetView.dappBlock = ^(NSString * _Nonnull passwdStr,NSString * _Nonnull selectedGas,NSString * _Nonnull selectedGasPrice) {
        if(passwdStr.length == 0){
            [self showCustomMessage:@"请输入钱包密码".localized hideAfterDelay:2.f];
            return;
        }else if ([passwdStr isEqualToString:@"取消"]){
            NSString *javaScript = [NSString stringWithFormat:@"executeCallback(%li, {message: \"response error\", code: -32010}, null)",callbackId];
            [self.webView evaluateJavaScript:javaScript completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                
            }];
            return;
        }else{
            LocalWallet *wallet = [[PWDataBaseManager shared] queryWalletIsSelected];
            NSString *remebercode = [GoFunction deckey:wallet.wallet_remembercode password:passwdStr];
            WalletapiHDWallet *hdWallet = WalletapiNewWalletFromMnemonic_v2(self.localCoin.coin_chain,[self remv:remebercode],nil );
            if (hdWallet == nil) {
                [self showCustomMessage:@"密码错误".localized hideAfterDelay:2.f];
                return;
            }
            NSString *prikey = [[hdWallet newKeyPriv:0 error:nil] hexString];
            self.priKey = prikey;
            
            [self sendTransaction:obj callBackId:callbackId prikey:self.priKey gas:selectedGas gasPrice:selectedGasPrice];
        }
    };
    self.sheetView = sheetView;
    [self.sheetView showWithView:self.view];
}

- (void)sendTransaction:(NSDictionary *)obj callBackId:(NSInteger)callbackId prikey:(NSString *)prikey gas:(NSString *)selectedGas gasPrice:(NSString *)selectedGasPrice{

//    webView.evaluateJavaScript("window.ethereum.request({ method: 'net_version' })") { (chainId, error) in
//        guard let chainId = chainId as? String else {
//            print("Error obtaining chainId: \(error?.localizedDescription ?? "Unknown error")")
//            return
//        }
//        print("Chain ID: \(chainId)")
//    }

    
    NSString *from = obj[@"from"];
    NSString *to = obj[@"to"];
    NSString *data = obj[@"data"];
    NSString *value = [self sixteenToTen:obj[@"value"]]; // 需要把16进制转为10进制
    NSString *gas = (selectedGas == nil || selectedGas.integerValue == 0) ? [self sixteenToTen:obj[@"gas"]] : selectedGas; //先判断是不是修改过矿工费，如果修改过了，就用修改的，如果没有就用前端返回的 前端返回的需要把16进制转为10进制。
    NSString *inputData64 = @"";
    if (data == nil || data.length == 0) {
        
    }else{
        NSString *inputData = [data stringByReplacingOccurrencesOfString:@"0x" withString:@""];
        inputData64 = [self base64Encoding:inputData];
    }
    
    
   
    NSDictionary *resultJson = @{@"from":from,
                                 @"gas":@(gas.integerValue),
                                 @"gasPrice":(selectedGasPrice == nil || selectedGasPrice.integerValue == 0) ? @(self.gasPrice.integerValue) : @(selectedGasPrice.doubleValue * 1000000000),
                                 @"input":inputData64,
                                 @"nonce":@(self.nonce.integerValue),
                                 @"to":to,
                                 @"value":[NSDecimalNumber decimalNumberWithString:value]};
    
    NSData *resultJsonData = [NSJSONSerialization dataWithJSONObject:resultJson options:NSJSONWritingFragmentsAllowed error:nil];
    NSString *resultJsonStr = [[NSString alloc] initWithData:resultJsonData encoding:NSUTF8StringEncoding];
    NSLog(@"构造的数据是----->%@",resultJson);
    NSError *error;
    NSData *txData = WalletapiStringTobyte(resultJsonStr, &error);
    
    WalletapiSignData *signData = [[WalletapiSignData alloc] init];
    signData.cointype = @"BTYETH";
    signData.data = txData;
    signData.privKey = prikey;
    signData.addressID = 2;

    NSString *signTx = WalletapiSignRawTransaction(signData, &error);
    if(error){
        [self showCustomMessage:@"操作失败，请稍后再试" hideAfterDelay:2.f];
        return;
    }
    [self.sheetView dismiss];
    NSDictionary *params = @{@"id":@1,
                             @"jsonrpc":@"2.0",
                             @"method":@"eth_sendRawTransaction",
                             @"params":@[signTx]};
    [self showProgressMessage:@"" hideAfterDelay:2.f];
    [[SGNetWork defaultManager] sendRequestMethod:HTTPMethodPOST
                                        serverUrl:RPCUrl
                                          apiPath:@""
                                       parameters:params
                                         progress:nil
                                          success:^(BOOL isSuccess, id  _Nullable responseObject) {
        
        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"eth_sendRawTransaction response is %@",jsonData);
        NSString *result = jsonData[@"result"];
//        {
//            error =     {
//                code = "-32000";
//                message = ErrTxFeeTooLow;
//            };
//            id = 1;
//            jsonrpc = "2.0";
//        }
        if(result == nil || result.length == 0){
            NSDictionary *dict = jsonData[@"error"];
            NSString *message = dict[@"message"];
            if (message == nil || message.length == 0) {
                [self showCustomMessage:@"操作失败，请稍后再试".localized hideAfterDelay:2.f];
            }else{
                [self showCustomMessage:message.localized hideAfterDelay:2.f];
            }
            
            NSString *javaScript = [NSString stringWithFormat:@"executeCallback(%li, {message: \"response error\", code: -32010}, null)",callbackId];
            [self.webView evaluateJavaScript:javaScript completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                
            }];
            return;
        }
        NSString *javaScript = [NSString stringWithFormat:@"executeCallback(%li,null,\"%@\")",callbackId,result];
        [self.webView evaluateJavaScript:javaScript completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            // 成功之后nonce自动加一
            NSInteger nonce = self.nonce.integerValue;
            nonce += 1;
            self.nonce = [NSString stringWithFormat:@"%li",(long)nonce];
        }];
    } failure:^(NSString * _Nullable errorMessage) {
        NSLog(@"error is %@",errorMessage);
    }];
    
    
}

- (NSString *)base64Encoding:(NSString *)input {
    NSData *inputData = WalletapiHexTobyte(input);
    
    NSString *base64str = [inputData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    
    return base64str;
}

- (void)getNonce{
    NSArray *param = @[[PWUtils getEthBtyAddress],@"latest"];
    NSDictionary *params = @{@"id":@1,
                             @"jsonrpc":@"2.0",
                             @"method":@"eth_getTransactionCount",
                             @"params":param};
    
    [[SGNetWork defaultManager] sendRequestMethod:HTTPMethodPOST
                                        serverUrl:RPCUrl
                                          apiPath:@""
                                       parameters:params
                                         progress:nil
                                          success:^(BOOL isSuccess, id  _Nullable responseObject) {
        
        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"eth_getTransactionCount is %@",jsonData);
        NSString *result = jsonData[@"result"];
        if(result != nil || result.length != 0){
            self.nonce = [self sixteenToTen:result];
        }
       
    } failure:^(NSString * _Nullable errorMessage) {
        NSLog(@"error is %@",errorMessage);
        
    }];
}

- (void)getGasPrice{
    NSDictionary *params = @{@"id":@1,
                             @"jsonrpc":@"2.0",
                             @"method":@"eth_gasPrice",
                             @"params":@[]};
    
    [[SGNetWork defaultManager] sendRequestMethod:HTTPMethodPOST
                                        serverUrl:RPCUrl
                                          apiPath:@""
                                       parameters:params
                                         progress:nil
                                          success:^(BOOL isSuccess, id  _Nullable responseObject) {
        
        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"eth_gasPrice is %@",jsonData);
        NSString *result = jsonData[@"result"];
        if(result != nil || result.length != 0){
            self.gasPrice = [self sixteenToTen:result];
        }
       
    } failure:^(NSString * _Nullable errorMessage) {
        NSLog(@"error is %@",errorMessage);
        
    }];
}

- (NSString *)sixteenToTen:(NSString *)str{

    if(str == nil){
        return @"0";
    }
    
    if([str hasPrefix:@"0x"]){
        str = [str stringByReplacingOccurrencesOfString:@"0x" withString:@""];
    }

    JKBigInteger *hexint = [[JKBigInteger alloc] initWithString:str andRadix:16];

    return [NSString stringWithFormat:@"%@",hexint];

}


@end

