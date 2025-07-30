//
//  ContactCoinTableViewCell.h
//  PWallet
//
//  Created by 宋刚 on 2018/6/15.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoinPrice.h"

@interface ContactCoinTableViewCell : UITableViewCell
@property (nonatomic,copy)NSDictionary *searchDic;
@property (nonatomic,copy)CoinPrice *coinPrice;
@end
