//
//  PWNewsSearchCoinViewController.h
//  PWallet
//
//  Created by 郑晨 on 2020/1/3.
//  Copyright © 2020 陈健. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocalWallet.h"

NS_ASSUME_NONNULL_BEGIN

@interface PWNewsSearchCoinViewController : CommonViewController
@property (nonatomic, strong) LocalWallet *selectedWallet;
@property(nonatomic,copy)NSArray *localArray;
@end

NS_ASSUME_NONNULL_END
