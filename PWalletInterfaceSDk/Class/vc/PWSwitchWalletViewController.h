//
//  PWSwitchWalletViewController.h
//  PWallet
//
//  Created by 郑晨 on 2019/11/7.
//  Copyright © 2019 陈健. All rights reserved.
//

#import "CommonViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    SwitchWalletTypeSwitch = 0,
    SwitchWalletTypeManage,
    SwitchWalletTypeExplore,
} SwitchWalletType;

typedef void(^RefreshHomeView)(NSInteger walletId);

@interface PWSwitchWalletViewController : CommonViewController
@property (nonatomic,copy) RefreshHomeView refreshHomeView;

@property (nonatomic) SwitchWalletType switchWalletType;

@end

NS_ASSUME_NONNULL_END
