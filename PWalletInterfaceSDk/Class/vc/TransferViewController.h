//
//  TransferViewController.h
//  PWallet
//
//  Created by 宋刚 on 2018/5/29.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Walletapi/Walletapi.h>
#import "LocalCoin.h"
#import <Walletapi/Walletapi.h>
#import "ScanViewController.h"
#import "Fee.h"
#import "PWAlertController.h"
#import "OrderModel.h"
#import "PWContacts.h"

@interface TransferViewController : CommonViewController
@property (nonatomic,strong)LocalCoin *coin;
@property (nonatomic,assign)NSInteger selectIndex;
@property (nonatomic,assign)TransferFrom fromTag;
@property (nonatomic,strong)PWContacts *pwcontact;
// 扫一扫进来 的
@property (nonatomic, strong) NSString *addressStr;
@property (nonatomic, strong) NSString *moneyStr;
@property (nonatomic, strong) OrderModel *orderModel;
@property(nonatomic,assign)NSInteger walletId;//快捷转账用到
@end
