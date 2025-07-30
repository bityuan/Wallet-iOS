//
//  PWCoin.h
//  PWallet
//  币信息
//  Created by 陈健 on 2018/6/20.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Quotation : NSObject
@property(nonatomic,copy) NSString *price;
@property(nonatomic,copy) NSString *dollar;
@property(nonatomic,copy) NSString *btc;
@property(nonatomic,copy) NSString *high;
@property(nonatomic,copy) NSString *low;
@property(nonatomic,copy) NSString *change;
@property(nonatomic,copy) NSString *rank;
@property(nonatomic,copy) NSString *circulate_value_rmb;
@property(nonatomic,copy) NSString *circulate_value_usd;
@property(nonatomic,copy) NSString *circulate_value_btc;
@property(nonatomic,copy) NSString *publish_count;
@property(nonatomic,copy) NSString *circulate_count;
@end

@interface Exchange : NSObject
@property(nonatomic,copy) NSString *count;
@property(nonatomic,copy) NSArray *data;
@end

@interface PWCoin : NSObject
@property(nonatomic,copy) NSString *coinID;
@property(nonatomic,copy) NSString *sid;
@property(nonatomic,copy) NSString *name;
@property(nonatomic,copy) NSString *nickname;
@property(nonatomic,copy) NSString *icon;
@property(nonatomic,copy) NSString *introduce;
@property(nonatomic,copy) NSString *official;
@property(nonatomic,copy) NSString *paper;
@property(nonatomic,copy) NSString *platform;
@property(nonatomic,copy) NSString *chain;
@property(nonatomic,copy) NSString *coinRelease;
@property(nonatomic,copy) NSString *price;
@property(nonatomic,copy) NSString *recomme;
@property(nonatomic,copy) NSString *area_search;
@property(nonatomic,copy) NSString *publish_count;
@property(nonatomic,copy) NSString *circulate_count;
@property (nonatomic,strong) Quotation *quotation;
@property (nonatomic,strong) Exchange *exchange;
@property(nonatomic,copy) NSString *optional_name;
@end


