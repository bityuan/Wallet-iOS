//
//  CreateRecoverWalletViewController.h
//  PWalletInterfaceSDk
//
//  Created by 郑晨 on 2022/8/31.
//  Copyright © 2022 fzm. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    RecoverTimeType7 = 0, // 7天找回
    RecoverTimeType30, // 30天找回
    RecoverTimeType90, // 60天找回
} RecoverTimeType;

typedef enum : NSUInteger {
    RecoverCoinTypeBTY = 0, // bty钱包找回
    RecoverCoinTypeYCC,// ycc钱包找回
}RecoverCoinType;

@interface CreateRecoverWalletViewController : CommonViewController

@property (nonatomic) RecoverTimeType recoverTimeType;
@property (nonatomic) RecoverCoinType recoverCoinType;
@end

NS_ASSUME_NONNULL_END
