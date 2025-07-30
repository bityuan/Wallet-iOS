//
//  PWMyWalletSetCell.h
//  PWallet
//
//  Created by 于优 on 2018/11/12.
//  Copyright © 2018 陈健. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PWMyWalletSetCellDelegate <NSObject>

- (void)switchPay:(UIButton *)sender;

@end

@interface PWMyWalletSetCell : UITableViewCell

/** title */
@property (nonatomic, strong) NSString *titleName;
@property (nonatomic, strong) UIButton *switchBtn;
@property (nonatomic, strong) UIImageView *nextImg;
@property (nonatomic, strong) UILabel *blueToothLabel;


@property (nonatomic) id<PWMyWalletSetCellDelegate> delegate;
@end
