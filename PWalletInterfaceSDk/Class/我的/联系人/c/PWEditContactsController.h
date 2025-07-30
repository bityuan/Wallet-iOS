//
//  PWEditContactsController.h
//  PWallet
//  编辑联系人
//  Created by 陈健 on 2018/5/31.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PWContacts.h"
#import "PWContactsCoin.h"
#import "PWCoin.h"
#import "ContactCoinViewController.h"


@interface PWEditContactsController : CommonViewController
//联系人  这个属性用于"编辑联系人"时使用
@property(nonatomic,strong)PWContacts *contacts;
@end
