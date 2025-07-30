//
//  AddCoinViewController.h
//  PWallet
//
//  Created by 宋刚 on 2018/5/28.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoinTableViewCell.h"
#import "SearchCoinViewController.h"
#import "PWDataBaseManager.h"



typedef void(^ReloadHomePage)(void);
@interface AddCoinViewController : CommonViewController
@property (nonatomic,copy) LocalWallet *selectedWallet;
@property (nonatomic,copy) ReloadHomePage reloadHomePage;
@end
