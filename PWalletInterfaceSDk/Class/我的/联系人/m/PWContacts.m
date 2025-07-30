//
//  PWContacts.m
//  PWallet
//
//  Created by 陈健 on 2018/5/31.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import "PWContacts.h"
#import "NSString+CommonUseTool.h"
#import "PWContactsCoin.h"

@implementation PWContacts

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (BOOL)isRight {
    if (([NSString isBlankString:self.nickName]) || (![self.phoneNumber isPhoneNumber])) {
        return false;
    }
    for (PWContactsCoin *coin in self.coinArray) {
        if (([NSString isBlankString:coin.coinName]) || ([NSString isBlankString:coin.coinAddress])) {
            return false;
        }
    }
    return true;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return true;
    }
    if (![object isKindOfClass:[PWContacts class]]) {
        return false;
    }
    return [self isEqualToContacts:(PWContacts*)object];
}

- (BOOL)isEqualToContacts:(PWContacts*)contacts {
    if (!contacts) {
        return false;
    }
    BOOL isEqualNickName = (!self.nickName && !contacts.nickName) || [self.nickName isEqualToString:contacts.nickName];
    BOOL isEqualPhoneNumber = (!self.phoneNumber && !contacts.phoneNumber) || [self.phoneNumber isEqualToString:contacts.phoneNumber];
    BOOL isEqualCoinArray = (!self.coinArray && !contacts.coinArray) || [self.coinArray isEqualToArray:contacts.coinArray];
    return isEqualNickName && isEqualPhoneNumber && isEqualCoinArray;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeObject:_contcatId forKey:@"contactId"];
    [aCoder encodeObject:_nickName forKey:@"nickName"];
    [aCoder encodeObject:_phoneNumber forKey:@"phoneNumber"];
    [aCoder encodeObject:_coinArray forKey:@"coinArray"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    if (self = [super init]) {
        _contcatId   = [aDecoder decodeObjectForKey:@"cointactId"];
        _nickName    = [aDecoder decodeObjectForKey:@"nickName"];
        _phoneNumber = [aDecoder decodeObjectForKey:@"phoneNumber"];
        _coinArray   = [aDecoder decodeObjectForKey:@"coinArray"];
    }
    return self;
}

@end
