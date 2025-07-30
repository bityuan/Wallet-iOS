//
//  PWImportWalletViewController.h
//  PWallet
//
//  Created by 郑晨 on 2019/11/4.
//  Copyright © 2019 陈健. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PWImportWalletViewController : CommonViewController

@property (nonatomic, strong) UITextView *addressTextView; // 助记词

@property (nonatomic, strong) UILabel *palceHoldLab; // 占位符
@end

NS_ASSUME_NONNULL_END
