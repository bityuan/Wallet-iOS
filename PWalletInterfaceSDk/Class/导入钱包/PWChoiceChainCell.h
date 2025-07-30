//
//  PWChoiceChainCell.h
//  PWallet
//
//  Created by 郑晨 on 2019/10/24.
//  Copyright © 2019 陈健. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@protocol PWChoiceChainCellDelegate <NSObject>

- (void)choiceChain:(UIButton *)sender cell:(UITableViewCell *)cell;

@end

@interface PWChoiceChainCell : UITableViewCell

@property (nonatomic, strong) UIView *contentsView;
@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UILabel *coinLab;
@property (nonatomic, strong) UIButton *choiceBtn;

@property (nonatomic) id <PWChoiceChainCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
