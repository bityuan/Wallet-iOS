//
//  ChangePwdViewController.h
//  PWallet
//
//  Created by 宋刚 on 2018/6/4.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocalWallet.h"
#import "PWDataBaseManager.h"
#import "AppDelegate.h"
@interface ChangePwdViewController : CommonViewController
@property (nonatomic,strong) LocalWallet *wallet;

@end
