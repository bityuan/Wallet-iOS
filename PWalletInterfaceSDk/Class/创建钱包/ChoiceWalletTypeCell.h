//
//  ChoiceWalletTypeCell.h
//  PWalletInterfaceSDk
//
//  Created by 郑晨 on 2022/9/5.
//  Copyright © 2022 fzm. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChoiceWalletTypeCell : UITableViewCell

@property (nonatomic, strong) UIView *contentsView;
@property (nonatomic, strong) UIImageView *bgImgView;
@property (nonatomic, strong) UIImageView *walletTypeImgView;
@property (nonatomic, strong) UIButton *confirBtn;

@end

NS_ASSUME_NONNULL_END
