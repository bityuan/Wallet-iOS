//
//  ContactCoinViewController.h
//  PWallet
//
//  Created by 宋刚 on 2018/6/14.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UISearchBar+SearchBarPlaceholder.h"
#import <MJRefresh/MJRefresh.h>
#import "CoinTableViewCell.h"
#import "ContactCoinTableViewCell.h"

typedef void(^SelectCoin)(NSString *,NSString *,NSString *);

@interface ContactCoinViewController : UIViewController
@property (nonatomic,copy) SelectCoin selectCoin;
@end
