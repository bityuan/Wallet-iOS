//
//  AppDelegate.m
//  PWalletInterfaceSDk
//
//  Created by fzm on 2021/8/25.
//

#import "AppDelegate.h"
#import "PWNewsHomeNoWalletViewController.h"
#import "PWNewsHomeViewController.h"
#import "PWDataBaseManager.h"
#import "MainTabBarController.h"
#import <SDWebImageWebPCoder/SDWebImageWebPCoder.h>
#import "AppDelegate+WCV2Config.h"
#import "PWalletInterfaceSDk-Swift.h"
#import "PWChoiceFeeSheetView.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize gamePwdStr;
@synthesize gameWalletId;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    

    if (@available(iOS 15.0, *)) {
        [UITableView appearance].sectionHeaderTopPadding = 0;
    }
    // 配置walletconnectv2
    [self configV2];
    [GoFunction setSessionId];
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    
    
    MainTabBarController *tbc = [[MainTabBarController alloc] init];
    self.window.rootViewController = tbc;
    
    [self.window makeKeyAndVisible];
    // 加载webp图片
    SDImageWebPCoder *webpCoder = [SDImageWebPCoder sharedCoder];
    [[SDImageCodersManager sharedManager] addCoder:webpCoder];
    
    [[IQKeyboardManager sharedManager] setEnable:true];
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:true];
     
    
    return YES;
}


- (void)switchRootViewController
{
    MainTabBarController *tbc = [[MainTabBarController alloc] init];
    self.window.rootViewController = tbc;
}



- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    // 如果wallect connect正在连接，退出之后通知vc断开连接
    [[NSNotificationCenter defaultCenter] postNotificationName:@"exitapp" object:nil];
}

@end
