//
//  MainTabBarController.m
//  PWalletInterfaceSDk
//
//  Created by fzm on 2021/12/7.
//

#import "MainTabBarController.h"
#import "PWNewsHomeNoWalletViewController.h"
#import "ExploreVC.h"
#import "PWNavigationController.h"
#import "PWNewsHomeViewController.h"
#import "PWWalletHomeViewController.h"
#import "PWNewsMineViewController.h"
#import "WebViewController.h"
#import "PWalletInterfaceSDk-Swift.h"
#import "AppDelegate.h"

#define keywindow [UIApplication sharedApplication].keyWindow

@interface MainTabBarController ()<UITabBarControllerDelegate>

@property (nonatomic, strong) UITabBarItem *homeTabBarItem;
@property (nonatomic, strong) UITabBarItem *exploreTabBarItem;
@property (nonatomic, strong) UITabBarItem *mineTabBarItem;
@property (nonatomic, strong) UITabBarItem *webTabBarItem;


@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UIButton *dappVCBtn;
@property (nonatomic, strong) UIImageView *wciconImgView;
@property (nonatomic) BOOL showDappVc;

@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate = self;
    //去掉tabBar顶部黑线
    self.tabBar.backgroundImage = [[UIImage alloc]init];
    self.tabBar.shadowImage = [[UIImage alloc]init];
    
//    self.tabBar.layer.shadowColor = CMColor(204, 204, 204).CGColor;
//    self.tabBar.layer.shadowOffset = CGSizeMake(0, -1);
//    self.tabBar.layer.shadowOpacity = 0.3;
    [self loadViewControllers];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeLanguage)
                                                 name:kChangeLanguageNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transformrootVC) name:@"stayNotification" object:nil];
}

- (void)loadViewControllers {
    
    [[UITabBar appearance] setBackgroundColor:[UIColor whiteColor]];
    [UITabBar appearance].translucent = NO;
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:CMColor(142, 146, 163)} forState:UIControlStateNormal];
    
    [[UITabBarItem appearance]setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:CMColor(51, 54, 73)} forState:UIControlStateSelected];
    if (@available(iOS 13.0, *)) {
        self.tabBar.tintColor = CMColor(51, 54, 73);
        self.tabBar.unselectedItemTintColor = CMColor(142, 146, 163);
    }
    
   
    //首页
    UIViewController *homeVC = [[PWNewsHomeViewController alloc] init];
    if (![PWUtils checkExistWallet])
    {
        homeVC = [[PWNewsHomeNoWalletViewController alloc] init];
    }
    PWNavigationController *homeNC = [[PWNavigationController alloc] initWithRootViewController:homeVC];
    UIImage *homeUnselectedImg = [[UIImage imageNamed:@"tab_icon_home_nor"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *homeselectedImg = [[UIImage imageNamed:@"tab_icon_home_sel"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _homeTabBarItem = [[UITabBarItem alloc] initWithTitle:@"钱包".localized image:homeUnselectedImg selectedImage:homeselectedImg];

    homeNC.tabBarItem = _homeTabBarItem;
    UIViewController *exploreVC = [[ExploreVC alloc] init];
    
    PWNavigationController *exploreNC = [[PWNavigationController alloc] initWithRootViewController:exploreVC];
    UIImage *exploreUnselectedImg = [[UIImage imageNamed:@"tab_icon_biquan_nor"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *exploreselectedImg = [[UIImage imageNamed:@"tab_icon_biquan_sel"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    NSString *title = @"探索".localized;

    _exploreTabBarItem = [[UITabBarItem alloc] initWithTitle:title image:exploreUnselectedImg selectedImage:exploreselectedImg];
    exploreNC.tabBarItem = _exploreTabBarItem;
    
    //我的
    PWNewsMineViewController *mineVC = [[PWNewsMineViewController alloc] init];
    PWNavigationController *mineNC = [[PWNavigationController alloc] initWithRootViewController:mineVC];
    UIImage *mineUnselectedImg = [[UIImage imageNamed:@"tab_icon_my_nor"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *mineSelectedImg = [[UIImage imageNamed:@"tab_icon_my_sel"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _mineTabBarItem = [[UITabBarItem alloc] initWithTitle:@"我的".localized image:mineUnselectedImg selectedImage:mineSelectedImg];
    mineNC.tabBarItem = _mineTabBarItem;
    
//    BrowserViewController *vc = [[BrowserViewController alloc] init];
//    vc.webUrl = @"https://bitwish.pro/";
    WebViewController *vc = [[WebViewController alloc] init];
    vc.webUrl = @"https://bitwish.pro/";
    PWNavigationController *webNC = [[PWNavigationController alloc] initWithRootViewController:vc];
    UIImage *webUnselectedImg = [[UIImage imageNamed:@"tab_icon_my_nor"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *webSelectedImg = [[UIImage imageNamed:@"tab_icon_my_sel"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _webTabBarItem = [[UITabBarItem alloc] initWithTitle:@"我的".localized image:webUnselectedImg selectedImage:webSelectedImg];
    webNC.tabBarItem = _webTabBarItem;
    
    
    
    NSArray *controllersArray = @[homeNC,exploreNC,mineNC];
    if(![PWCheckIsVerifyManager checkIsVerify]){
        controllersArray = @[homeNC,mineNC];
    }
    [self setViewControllers:controllersArray animated:YES];

    // 根据是否有钱包来进行页面的优先显示
    if (![PWUtils checkExistWallet])
    {
        self.selectedIndex = 1;
    }
    else
    {
        self.selectedIndex = 0;
    }

}

- (void)changeLanguage
{
    _homeTabBarItem.title = @"钱包".localized;
    _mineTabBarItem.title = @"我的".localized;
    _exploreTabBarItem.title = @"探索".localized;

}


#pragma mark - 悬浮窗
- (void)createWindow
{
   
//    UIWindow *window = 
    UIWindow *window = [PWUtils getKeyWindowWithView:self.view];
    _wciconImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    _wciconImgView.image = [UIImage imageNamed:@"wcicon"];
    _wciconImgView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickBtn)];
    tap.numberOfTapsRequired = 1;
    [_wciconImgView addGestureRecognizer:tap];
    
    [window addSubview:_wciconImgView];
    
    [self.wciconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(window).offset(-8);
        make.bottom.equalTo(window).offset(-(51 + kIphoneXBottomOffset));
        make.width.mas_equalTo(64);
        make.height.mas_equalTo(70);
    }];
   
}

- (void)clickBtn
{
    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIViewController *rootVc = appdelegate.window.rootViewController;
    PWNavigationController *dappVC;
    MainTabBarController *mainTab;
    for (UIViewController *controller in rootVc.childViewControllers) {
        if ([controller isKindOfClass:[MainTabBarController class]]) {
            mainTab = (MainTabBarController*)controller;
        }
        if ([controller isKindOfClass:[PWNavigationController class]]) {
            dappVC = (PWNavigationController*)controller;
        }
    }

    [rootVc transitionFromViewController:mainTab toViewController:dappVC duration:0.1 options:UIViewAnimationOptionTransitionNone animations:nil completion:^(BOOL finished) {
        for (UIView *view in [[PWUtils getKeyWindowWithView:self.view] subviews]) {
            if ([view isKindOfClass:[UIImageView class]]) {
                self.wciconImgView = (UIImageView *)view;
            }
        }
        self.wciconImgView.hidden = YES;
    }];
    
}

- (void)transformrootVC {
   
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"stayNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kChangeLanguageNotification object:nil];
    
    BOOL isStay = [[[NSUserDefaults standardUserDefaults] objectForKey:@"stay"] boolValue];
    // 获取控制器
    AppDelegate *appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    UIViewController *rootVc = appdelegate.window.rootViewController;
    PWNavigationController *dappVC;
   
    for (UIViewController *controller in rootVc.childViewControllers) {
        if ([controller isKindOfClass:[MainTabBarController class]]) {
            [controller removeFromParentViewController];
        }
        if ([controller isKindOfClass:[PWNavigationController class]]) {
            dappVC = (PWNavigationController*)controller;
        }
    }
    MainTabBarController *mainTab = [[MainTabBarController alloc] init];
//    
    [rootVc addChildViewController:mainTab];
    [rootVc.view addSubview:dappVC.view];
    
    [rootVc transitionFromViewController:dappVC
                        toViewController:mainTab
                                duration:0.1
                                 options:UIViewAnimationOptionTransitionCurlUp
                              animations:^{
        
    } completion:^(BOOL finished) {
        
        if (isStay)
        {
            for (UIView *view in [[PWUtils getKeyWindowWithView:self.view] subviews]) {
                if ([view isKindOfClass:[UIImageView class]]) {
                    self.wciconImgView = (UIImageView *)view;
                }
            }
            if (self.wciconImgView) {
                self.wciconImgView.hidden = NO;
            }else{
                [self createWindow];
            }
        }else{
            for (UIView *view in [[PWUtils getKeyWindowWithView:self.view] subviews]) {
                if ([view isKindOfClass:[UIImageView class]]) {
                    self.wciconImgView = (UIImageView *)view;
                }
            }
            if (self.wciconImgView) {
                self.wciconImgView.hidden = YES;
                [self.wciconImgView removeFromSuperview];
            }
        }
    }];
   
    
    
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
