//
//  PWContacts.h
//  PWallet
//
//  Created by 陈健 on 2018/5/31.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PWContactsCoin;
@interface PWContacts : NSObject<NSCoding>
@property (nonatomic, strong) NSNumber *contcatId;
/*昵称**/
@property(nonatomic,strong) NSString *nickName;
/*电话**/
@property(nonatomic,strong) NSString *phoneNumber;
/*虚拟币地址数组**/
@property(nonatomic,copy) NSArray<PWContactsCoin*> *coinArray;
//联系人所有信息是否都是完整的
- (BOOL)isRight;
@end
