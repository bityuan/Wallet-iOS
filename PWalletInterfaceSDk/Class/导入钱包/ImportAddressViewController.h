//
//  ImportAddressViewController.h
//  PWallet
//
//  Created by 郑晨 on 2019/10/21.
//  Copyright © 2019 陈健. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImportAddressViewController : CommonViewController

@property (nonatomic, strong) UITextView *addressTextView; // 私钥
@property (nonatomic, strong) UILabel *palceHoldLab; // 占位符
- (instancetype)initWithChainName:(NSString *)chainName ChainIcon:(NSString *)chainIcon CoinName:(NSString *)coinName;
@end

NS_ASSUME_NONNULL_END
