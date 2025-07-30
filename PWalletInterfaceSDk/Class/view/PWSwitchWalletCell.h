//
//  PWSwitchWalletCell.h
//  PWallet
//
//  Created by 郑晨 on 2019/11/7.
//  Copyright © 2019 陈健. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocalWallet.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PWSwitchWalletCellDelegate <NSObject>

- (void)toLogin:(UIButton *)sender;

@end

@interface PWSwitchWalletCell : UITableViewCell

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *walletLogoImageView;
@property (nonatomic, strong) UILabel *walletNameLab;
@property (nonatomic, strong) UILabel *walletDesLab;
@property (nonatomic, strong) UILabel *assetLab;
@property (nonatomic, strong) UIButton *loginBtn;
@property (nonatomic, strong) UIImageView *currentWalletImageView;
@property (nonatomic, strong) UIButton *currentWalletBtn;
@property (nonatomic, strong) UILabel *addressLab;

@property (nonatomic) id <PWSwitchWalletCellDelegate> delegate;

@property (nonatomic, strong) LocalWallet *localWallet;

@end

NS_ASSUME_NONNULL_END
