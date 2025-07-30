//
//  PWCoin.m
//  PWallet
//  币信息
//  Created by 陈健 on 2018/6/20.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import "PWCoin.h"
#import "YYModel.h"

@implementation PWCoin
+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper{
    
    return @{@"coinID":@"id",
             @"coinRelease":@"release",
             };
}
@end



@implementation Quotation

- (NSString *)price {
    //解决精度问题
    if ([_price doubleValue]) {
        NSString *numString = [NSString stringWithFormat:@"%lf", [_price doubleValue]];
        _price =  [[NSDecimalNumber decimalNumberWithString:numString] stringValue];
    }
    return _price ? _price : @"0";
}
- (NSString *)dollar {
    if ([_dollar doubleValue]) {
        NSString *numString = [NSString stringWithFormat:@"%lf", [_dollar doubleValue]];
        _dollar =  [[NSDecimalNumber decimalNumberWithString:numString] stringValue];
    }
    return _dollar ? _dollar : @"0";
}

@end


@implementation Exchange

@end

