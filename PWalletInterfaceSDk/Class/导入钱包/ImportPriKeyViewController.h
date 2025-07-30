//
//  ImportPriKeyViewController.h
//  PWallet
//
//  Created by 郑晨 on 2019/10/21.
//  Copyright © 2019 陈健. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocalWallet.h"
#import "AppDelegate.h"
#import "PWDataBaseManager.h"
#import <Walletapi/Walletapi.h>
NS_ASSUME_NONNULL_BEGIN

@interface ImportPriKeyViewController : CommonViewController

@property (nonatomic, strong) UITextView *addressTextView; // 私钥

@property (nonatomic, strong) UILabel *palceHoldLab; // 占位符

@property (nonatomic, strong) NSString *chainStr;

@end

NS_ASSUME_NONNULL_END
