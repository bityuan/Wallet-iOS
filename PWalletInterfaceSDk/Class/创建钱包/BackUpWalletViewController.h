//
//  BackUpWalletViewController.h
//  PWallet
//
//  Created by 宋刚 on 2018/5/24.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EnglishCodeBackUpView.h"
#import "EnglishCodeChooseView.h"
#import "AppDelegate.h"
#import "PWDataBaseManager.h"
#import <Walletapi/Walletapi.h>
@interface BackUpWalletViewController : CommonViewController
@property (nonatomic,copy) NSString *englishCode;
@property (nonatomic,copy) NSString *walletName;
@property (nonatomic,copy) NSString *password;
@property (nonatomic, copy) NSString *codeLab;// 助记词
@property (nonatomic,assign) ParentViewControllerFrom parentFrom;
@end
