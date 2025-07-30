//
//  PWCoin.m
//  PWallet
//  联系人中的币名字和地址
//  Created by 陈健 on 2018/5/31.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import "PWContactsCoin.h"

@implementation PWContactsCoin

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return true;
    }
    if (![object isKindOfClass:[PWContactsCoin class]]) {
        return false;
    }
    return [self isEqualToCoin:(PWContactsCoin*)object];
}

- (BOOL)isEqualToCoin:(PWContactsCoin*)coin {
    if (!coin) {
        return false;
    }
    BOOL isEqualCoinName = (!self.coinName && !coin.coinName) || [self.coinName isEqualToString:coin.coinName];
    BOOL isEqualCoinAddress = (!self.coinAddress && !coin.coinAddress) || [self.coinAddress isEqualToString:coin.coinAddress];
    return isEqualCoinName && isEqualCoinAddress;
}


- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeObject:_coinId forKey:@"coinId"];
    [aCoder encodeObject:_coinName forKey:@"coinName"];
    [aCoder encodeObject:_coinAddress forKey:@"coinAddress"];
    [aCoder encodeObject:_optional_name forKey:@"optional_name"];
    [aCoder encodeObject:_coinPlatform forKey:@"coinPlatform"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    if (self = [super init]) {
        _coinId        = [aDecoder decodeObjectForKey:@"coinId"];
        _coinName      = [aDecoder decodeObjectForKey:@"coinName"];
        _coinAddress   = [aDecoder decodeObjectForKey:@"coinAddress"];
        _optional_name = [aDecoder decodeObjectForKey:@"optional_name"];
        _coinPlatform  = [aDecoder decodeObjectForKey:@"coinPlatform"];
    }
    return self;
}

@end
