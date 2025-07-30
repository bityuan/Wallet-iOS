//
//  PWSuggestionsCoinTool.m
//  PWallet
//  获取推荐币种 
//  Created by 陈健 on 2018/7/30.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import "PWSuggestionsCoinTool.h"
#import "PWNetworkingTool.h"
#import "PWDataBaseManager.h"

NSString *const PWSaveSuggestionsCoinIdentifier = @"PWSaveSuggestionsCoinIdentifier";

@implementation PWSuggestionsCoinTool
+ (void)loadSuggestionsCoin:(requestSuccessBlock)successBlock failureBlock:(requestFailureBlock)failureBlock;
{
    [self loadSuggestionsCoin:@"" successBlock:successBlock failureBlock:failureBlock];
}

+ (void)loadSuggestionsCoin:(NSString *)recommendId successBlock:(requestSuccessBlock)successBlock failureBlock:(requestFailureBlock)failureBlock {
    NSString *url = [NSString stringWithFormat:@"%@%@",WalletURL,RECOMCOIN];
    NSMutableDictionary *param = [NSMutableDictionary new];
    // 烧纵料  紧口涨  变全违  书喊捐  伟黑徒
    
    [param setObject:@"1" forKey:@"platform_id"];

    if (![recommendId isEqualToString:@""]) {
        if ([recommendId containsString:@"+"])
        {
            NSArray *array = [recommendId componentsSeparatedByString:@"+"];
            [param setObject:array[0] forKey:@"recommend"];
            [param setObject:array[1] forKey:@"chain"];
        }
        else
        {
            [param setObject:recommendId forKey:@"recommend"];
        }
        
    }
    
    [PWNetworkingTool postRequestWithUrl:url parameters:param successBlock:^(id object) {
        
        NSArray *coinArray = (NSArray *)object;
        if ([coinArray isEqual:[NSNull null]]) {
            if (successBlock) {
                successBlock([[NSArray alloc] init]);
            }
            return ;
        }
//        [[PWAppsettings instance] deleteHomeCoinInfo];
//        [[PWAppsettings instance] saveHomeCoinInfo:coinArray];
        for(int i = 0;i < coinArray.count; i++)
        {
            NSDictionary *dic = [coinArray objectAtIndex:i];
            CoinPrice *coinPrice = [[CoinPrice alloc] init];
            if (![dic[@"chain"] isKindOfClass:[NSNull class]])
            {
                coinPrice.coinprice_name = dic[@"name"];
                coinPrice.coinprice_price = [dic[@"rmb"] doubleValue]; //[CommonFunction handlePrice:priceStr];
                coinPrice.coinprice_dollarPrice = [dic[@"usd"] doubleValue];
                coinPrice.coinprice_icon = dic[@"icon"];
                coinPrice.coinprice_sid = dic[@"sid"];
                coinPrice.coinprice_nickname = dic[@"nickname"];
                coinPrice.coinprice_id = [dic[@"id"] integerValue];
                coinPrice.coinprice_chain = dic[@"chain"];
                coinPrice.coinprice_platform = dic[@"platform"];
                coinPrice.coin_sort = [dic[@"sort"] integerValue];
                coinPrice.treaty = [dic[@"treaty"] integerValue];
                coinPrice.coinprice_optional_name = dic[@"optional_name"];
                coinPrice.coinprice_chain_country_rate = [dic[@"rmb"] doubleValue];
                coinPrice.coinprice_country_rate = [dic[@"rmb"] doubleValue];
                coinPrice.rmb_country_rate = [dic[@"rmb"] doubleValue];
                coinPrice.lock = [dic[@"lock"] integerValue];
                [[PWDataBaseManager shared] addCoinPrice:coinPrice];
            }
            
        }
        NSMutableArray *nameArray = [NSMutableArray array];
        for (NSDictionary *coin in (NSArray*)object) {
            if (![coin[@"platform"] isKindOfClass:[NSNull class]])
            {
                if (![coin[@"platform"] isEqualToString:@"other"])
                {
                    [nameArray addObject:coin];
                }
            }
           
        }
        NSArray *array = [NSArray arrayWithArray:nameArray];
        
        if (successBlock) {
            successBlock(array);
        }
       
    } failureBlock:^(NSError *error) {
        if (failureBlock) {
            failureBlock(error);
        }
    }];
}



@end
