//
//  PWWalletForgetPwdViewController.h
//  PWallet
//
//  Created by 郑晨 on 2021/3/5.
//  Copyright © 2021 陈健. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocalWallet.h"

NS_ASSUME_NONNULL_BEGIN

@interface PWWalletForgetPwdViewController : CommonViewController
@property (nonatomic, strong) LocalWallet *localWallet;
@end

NS_ASSUME_NONNULL_END
