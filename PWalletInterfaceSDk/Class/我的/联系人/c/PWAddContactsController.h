//
//  PWAddContactsController.h
//  PWallet
//  添加联系人
//  Created by 陈健 on 2018/5/30.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import "CommonViewController.h"
#import "PWContacts.h"
#import "PWContactsCoin.h"
#import "PWCoin.h"
#import "ContactCoinViewController.h"


@interface PWAddContactsController : CommonViewController
@property (nonatomic, copy) NSString *coinType;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *optional_name;
@property (nonatomic, copy) NSString *coinPlatform;
@end
