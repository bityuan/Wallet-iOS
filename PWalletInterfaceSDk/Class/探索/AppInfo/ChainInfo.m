//
//  ChainInfo.m
//  PWalletInterfaceSDk
//
//  Created by 郑晨 on 2025/2/18.
//  Copyright © 2025 fzm. All rights reserved.
//

#import "ChainInfo.h"

@implementation ChainInfo
//let server = RPCServer.custom(CustomRPC(chainID: 2999,
//                                        nativeCryptoTokenName: "BTY",
//                                        chainName: "BitYuan Mainnet",
//                                        symbol: "BTY",
//                                        rpcEndpoint: "https://mainnet.bityuan.com/eth",
//                                        explorerEndpoint: "https://www.bityuan.com",
//                                        etherscanCompatibleType: RPCServer.EtherscanCompatibleType.blockscout,
//                                        isTestnet: false))


- (NSArray *)defaultChainInfoArr
{
    NSMutableArray *chainInfoMarry = [[NSMutableArray alloc] init];
    NSDictionary *bty = @{@"chainId":@2999,
                          @"nativeCryptoTokenName":@"BTY",
                          @"symbol":@"BTY",
                          @"rpcUrl":@"https://mainnet.bityuan.com/eth",
                          @"exploreUrl":@"https://mainnet.bityuan.com",
                          @"isTestNet":@0};
    [chainInfoMarry addObject:bty];
    NSDictionary *eth = @{@"chainId":@2999,
                          @"nativeCryptoTokenName":@"BTY",
                          @"symbol":@"BTY",
                          @"rpcUrl":@"https://mainnet.bityuan.com/eth",
                          @"exploreUrl":@"https://mainnet.bityuan.com",
                          @"isTestNet":@0};
    [chainInfoMarry addObject:eth];
    NSDictionary *bnb = @{@"chainId":@2999,
                          @"nativeCryptoTokenName":@"BTY",
                          @"symbol":@"BTY",
                          @"rpcUrl":@"https://mainnet.bityuan.com/eth",
                          @"exploreUrl":@"https://mainnet.bityuan.com",
                          @"isTestNet":@0};
    [chainInfoMarry addObject:bnb];
    
    
    return [NSArray arrayWithArray:chainInfoMarry];
}

@end
