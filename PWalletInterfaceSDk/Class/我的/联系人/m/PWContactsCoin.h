//
//  PWContactsCoin.h
//  PWallet
//  联系人中的币名字和地址
//  Created by 陈健 on 2018/5/31.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PWContactsCoin : NSObject<NSCoding>
/*虚拟币id*/
@property (nonatomic) NSNumber *coinId;
/*虚拟币名字**/
@property(nonatomic,copy) NSString *coinName;
//可选名 AT2  AT
@property(nonatomic,copy) NSString *optional_name;
/*虚拟币地址**/
@property(nonatomic,copy) NSString *coinAddress;
/*虚拟币平台*/
@property (nonatomic, copy) NSString *coinPlatform;

@end
