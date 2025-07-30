//
//  CreateWalletSecondViewController.h
//  PWallet
//
//  Created by 宋刚 on 2018/5/23.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BackUpChineseViewController.h"
#import <Walletapi/Walletapi.h>

@interface CreateWalletSecondViewController : CommonViewController
@property (nonatomic,copy) NSString *walletName;
@property (nonatomic,copy) NSString *password;

@end
