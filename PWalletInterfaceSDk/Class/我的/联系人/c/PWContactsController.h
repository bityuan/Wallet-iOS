//
//  PWContactsController.h
//  PWallet
//  联系人主界面
//  Created by 陈健 on 2018/5/28.
//  Copyright © 2018年 陈健. All rights reserved.
//

typedef enum : NSUInteger {
    ContactParentTransfer,
    ContactParentMine
} ContactParentController;

#import <UIKit/UIKit.h>
#import "PWContacts.h"
typedef void (^SelectContact) (PWContacts *);

@interface PWContactsController : CommonViewController
@property (nonatomic,assign)ContactParentController parentController;
@property (nonatomic,copy) NSString *transferCoinType;
@property (nonatomic,copy) SelectContact selectContact;
@end
