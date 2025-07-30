//
//  BackUpChineseViewController.h
//  PWallet
//
//  Created by 宋刚 on 2018/5/24.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChineseCodeBackUpView.h"
#import "ChineseCodeChooseView.h"
#import "AppDelegate.h"
#import "PWDataBaseManager.h"
#import <Walletapi/Walletapi.h>

@interface BackUpChineseViewController : CommonViewController
@property (nonatomic,strong)LocalWallet *wallet;
@property (nonatomic,copy) NSString *chineseCode;
@property (nonatomic,copy) NSString *walletName;
@property (nonatomic,copy) NSString *password;
@property (nonatomic, copy) NSString *labCode;
@property (nonatomic,assign) ParentViewControllerFrom parentFrom;
@end
