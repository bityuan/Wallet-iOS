//
//  PWLoginTool.m
//  PWallet
//
//  Created by 于优 on 2018/10/25.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import "PWLoginTool.h"
#import <CommonCrypto/CommonDigest.h>
#import <SAMKeychain/SAMKeychain.h>
#import "PWVersionView.h"
#import "PWVersionModel.h"
#import "YYModel.h"

@implementation PWLoginTool

+ (UIViewController *)getCurrentVC {
    
    UIViewController *result = nil;
    
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    do {
        if ([rootVC isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navi = (UINavigationController *)rootVC;
            UIViewController *vc = [navi.viewControllers lastObject];
            result = vc;
            rootVC = vc.presentedViewController;
            continue;
        } else if([rootVC isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tab = (UITabBarController *)rootVC;
            result = tab;
            rootVC = [tab.viewControllers objectAtIndex:tab.selectedIndex];
            continue;
        } else if([rootVC isKindOfClass:[UIViewController class]]) {
            result = rootVC;
            rootVC = nil;
        }
    } while (rootVC != nil);
    
    return result;
}

+ (NSString *)generateTradeNO {
    
    static int kNumber = 6;
    NSString *sourceStr = @"0123456789";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    srand((unsigned)time(0));
    for (int i = 0; i < kNumber; i++) {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    
    return resultStr;
}

+ (NSString *)md5:(NSString *)str {
    //    str = @"6227073201280428卢月玲中国建设银行杭大路分理处";÷
    
    const char *cStr = [str UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

// 获取设备UUID
+ (NSString *)getUUID {
    NSString *u = [SAMKeychain passwordForService:@"keychain" account:@"key_chain"];
    
    if (!u || u.length == 0) {
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        NSString *strUUID = (NSString *)CFBridgingRelease(CFUUIDCreateString (kCFAllocatorDefault,uuidRef));
        [self saveUUID:strUUID];
        u = strUUID;
    }
    NSLog(@"device is %@",u);
    
    return u;
}

+ (void)saveUUID:(NSString *)uuid {
    
    [SAMKeychain setPassword:uuid forService:@"keychain" account:@"key_chain"];
    
}

+ (NSInteger)compareOneDay:(NSDate *)currentDay withAnotherDay:(NSDate *)BaseDay {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy-HHmmss"];
    NSString *currentDayStr = [dateFormatter stringFromDate:currentDay];
    NSString *BaseDayStr = [dateFormatter stringFromDate:BaseDay];
    NSDate *dateA = [dateFormatter dateFromString:currentDayStr];
    NSDate *dateB = [dateFormatter dateFromString:BaseDayStr];
    NSComparisonResult result = [dateA compare:dateB];
    NSLog(@"date1 : %@, date2 : %@", currentDay, BaseDay);
    if (result == NSOrderedDescending) {
        //NSLog(@"在当前日期之前");
        return 1;
    }
    else if (result == NSOrderedAscending){
        //NSLog(@"在当前日期之后");
        return -1;
    }
    //NSLog(@"相同");
    return 0;
}


+ (void)checkUpdate:(UIViewController *)Vc data:(NSDictionary *)data {
    
    PWVersionModel *model = [PWVersionModel yy_modelWithDictionary:data];
    
    NSString *versionInServer = model.version;
    NSString *currentVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    NSArray *serverVersionArray = [versionInServer componentsSeparatedByString:@"."];
    NSArray *currentVersionArray = [currentVersion componentsSeparatedByString:@"."];
    NSInteger serverVersionValue = 0;
    NSInteger currentVersionValue = 0;
    for ( long i = (serverVersionArray.count - 1); i >= 0; i--) {
        NSInteger value = [[serverVersionArray objectAtIndex:(serverVersionArray.count - 1 - i)] integerValue];
        serverVersionValue = serverVersionValue + pow(10, i) * value;
    }
    
    for ( long i = (currentVersionArray.count - 1); i >= 0; i--) {
        NSInteger value = [[currentVersionArray objectAtIndex:(serverVersionArray.count - 1 - i)] integerValue];
        currentVersionValue = currentVersionValue + pow(10, i) * value;
    }
    
    if (currentVersionValue < serverVersionValue) {
        if (model.status == 4) { // 4强制更新
            [self forcedUpdate:Vc data:model];
        }
        else {
            [self recommendUpdate:Vc data:model];
        }
    }
}

+ (void)recommendUpdate:(UIViewController *)Vc data:(PWVersionModel *)data {
    PWVersionView *view = [PWVersionView shopView];
    view.versionModel = data;
    view.updateType = PWUpdateTypeNormal;
    [[UIApplication sharedApplication].keyWindow addSubview:view];
}

+ (void)forcedUpdate:(UIViewController *)Vc data:(PWVersionModel *)data {
    
    PWVersionView *view = [PWVersionView shopView];
    view.versionModel = data;
    view.updateType = PWUpdateTypeMust;
    [[UIApplication sharedApplication].keyWindow addSubview:view];//熔阅科  情拍骗  两式成  物话罩  指乙果
}

+ (void)presentLoginViewController:(UIViewController *)superVc wihtNavVc:(UINavigationController *)navVc {
    
    navVc.navigationBar.barTintColor = UIColor.whiteColor;
    navVc.navigationBar.backgroundColor = UIColor.whiteColor;
    
    UIImage *image = [[UIImage alloc] init];
    [navVc.navigationBar setShadowImage:image];
//    [navVc.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [navVc.navigationBar setBackgroundImage:image forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    
    [superVc presentViewController:navVc animated:YES completion:nil];
}

@end
