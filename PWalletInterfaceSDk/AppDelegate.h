//
//  AppDelegate.h
//  PWalletInterfaceSDk
//
//  Created by fzm on 2021/8/25.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic,copy) NSString *gamePwdStr;
@property (nonatomic,assign) NSInteger gameWalletId;
@property (strong, nonatomic) UIWindow * window;
@property (nonatomic, strong) NSString *type; // 1 导入  2 创建


- (void)switchRootViewController;

@end

