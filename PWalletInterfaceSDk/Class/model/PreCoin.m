//
//  PreCoin.m
//  PWalletInterfaceSDk
//
//  Created by 郑晨 on 2023/7/18.
//  Copyright © 2023 fzm. All rights reserved.
//

#import "PreCoin.h"

@implementation PreCoin

+ (NSArray*)getPreCoinArr
{


    NSMutableDictionary *BTCDict = [NSMutableDictionary dictionary];
    [BTCDict setValue:@"BTC" forKey:@"chain"];
    [BTCDict setValue:@"http://bqbwallet.oss-cn-shanghai.aliyuncs.com/upload/application/9bbbd15fdaf37f85b224c3d96f4a457c.png" forKey:@"icon"];
    [BTCDict setValue:@"89" forKey:@"id"];
    [BTCDict setValue:@"比特币（BitCoin）的概念最初由中本聪在2009年提出，根据中本聪的思路设计发布的开源软件以及建构其上的P2P网络。比特币是一种P2P形式的数字货币。点对点的传输意味着一个去中心化的支付系统。与大多数货币不同，比特币不依靠特定货币机构发行，它依据特定算法，通过大量的计算产生，比特币经济使用整个P2P网络中众多节点构成的分布式数据库来确认并记录所有的交易行为，并使用密码学的设计来确保货币流通各个环节安全性。P2P的去中心化特性与算法本身可以确保无法通过大量制造比特币来人为操控币值。基于密码学的设计可以使比特币只能被真实的拥有者转移或支付。这同样确保了货币所有权与流通交易的匿名性。比特币与其他虚拟货币最大的不同，是其总数量非常有限，具有极强的稀缺性。该货币系统曾在4年内只有不超过1050万个，之后的总数量将被永久限制在2100万个。" forKey:@"introduce"];
    [BTCDict setValue:@"BTC" forKey:@"name"];
    [BTCDict setValue:@"比特币" forKey:@"nickname"];
    [BTCDict setValue:@"btc" forKey:@"platform"];
    [BTCDict setValue:@"1" forKey:@"treaty"];
    [BTCDict setValue:@"2" forKey:@"coin_type_nft"];
    
    NSMutableDictionary *edict = [NSMutableDictionary dictionary];
    [edict setValue:@"ETH" forKey:@"chain"];
    [edict setValue:@"http://bqbwallet.oss-cn-shanghai.aliyuncs.com/upload/257e6de32830fb16f54d20d658463ae3.png" forKey:@"icon"];
    [edict setValue:@"90" forKey:@"id"];
    [edict setValue:@"Ethereum（以太坊）是一个平台和一种编程语言，使开发人员能够建立和发布下一代分布式应用。 Ethereum可以用来编程，分散，担保和交易任何事物：投票，域名，金融交易所，众筹，公司管理， 合同和大部分的协议，知识产权，还有得益于硬件集成的智能资产。以太坊将使用混合型的安全协议，前期使用工作量证明机制（POW），用于分发以太币，然后会切换到权益证明机制（POS）。自上线时起，每年都将有0.26x，即每年有60102216 * 0.26 = 15626576个以太币被矿工挖出。转成POS后，每年产出的以太币将减少"forKey:@"introduce"];
    [edict setValue:@"ETH" forKey:@"name"];
    [edict setValue:@"以太坊" forKey:@"nickname"];
    [edict setValue:@"ethereum" forKey:@"platform"];
    [edict setValue:@"1" forKey:@"treaty"];
    [edict setValue:@"2" forKey:@"coin_type_nft"];
    
    NSMutableDictionary *udict = [NSMutableDictionary dictionary];
    [udict setValue:@"ETH" forKey:@"chain"];
    [udict setValue:@"http://bqbwallet.oss-cn-shanghai.aliyuncs.com/upload/5330b5a0ff892ee8e06049ec10391c0a.png" forKey:@"icon"];
    [udict setValue:@"288" forKey:@"id"];
    [udict setValue:@"USDT是Tether公司推出的基于稳定价值货币美元（USD）的代币Tether USD（下称USDT），1USDT=1美元，用户可以随时使用USDT与USD进行1:1兑换。Tether公司严格遵守1:1准备金保证，即每发行1个 USDT 代币，其银行账户都会有1美元的资金保障。用户可以在 Tether 平台进行资金查询，以保障透明度。用户可以通过SWIFT电汇美元至Tether公司提供的银行帐户，或通过交易所换取USDT。赎回美元时，反向操作即可。用户也可在交易所用比特币换取USDT。\n\n\n\nUSDT是在比特币区块链上发布的基于Omni Layer协议的数字资产。USDT最大的特点是，它与同数量的美元是等值的。USDT被设计为法币在数字网络上的复制品，使之成为波动剧烈的加密货币市场中良好的保值代币" forKey:@"introduce"];
    [udict setValue:@"USDT" forKey:@"name"];
    [udict setValue:@"ERC20" forKey:@"nickname"];
    [udict setValue:@"ethereum" forKey:@"platform"];
    [udict setValue:@"1" forKey:@"treaty"];
    [udict setValue:@"2" forKey:@"coin_type_nft"];
    
    NSMutableDictionary *bnbdict = [NSMutableDictionary dictionary];
    [bnbdict setValue:@"BNB" forKey:@"chain"];
    [bnbdict setValue:@"http://bqbwallet.oss-cn-shanghai.aliyuncs.com/upload/application/834b12284a6a5cee9ed5d1937e292b70.png" forKey:@"icon"];
    [bnbdict setValue:@"641" forKey:@"id"];
    [bnbdict setValue:@"bnbnbn" forKey:@"introduce"];
    [bnbdict setValue:@"BNB" forKey:@"name"];
    [bnbdict setValue:@"币安" forKey:@"nickname"];
    [bnbdict setValue:@"bnb" forKey:@"platform"];
    [bnbdict setValue:@"1" forKey:@"treaty"];
    [bnbdict setValue:@"2" forKey:@"coin_type_nft"];
    
//    NSMutableDictionary *ybdict = [NSMutableDictionary dictionary];
//    [ybdict setValue:@"BTC" forKey:@"chain"];
//    [ybdict setValue:@"http://wallet-33.oss-cn-shanghai.aliyuncs.com/upload/application/1f2d0329f1b8059a11917341e150cf1e.png" forKey:@"icon"];
//    [ybdict setValue:@"727" forKey:@"id"];
//    [ybdict setValue:@"原链YCC是新一代商用级基础公链。原链汲取了比特币、瑞波币、比特股、以太坊、超级账本各系统的优点，融入多项创新技术，形成一种全新的区块链网络架构，一方面公链的性能可以超过 万笔/秒，另一方面公链和许可链可以实现信息互联，价值互通。既具有公链的去中心化特征，又能兼顾许可链对性能和隐私的要求。原链YCC主要致力于搭建企业级区块链SaaS平台，可以应用于供应链，票据，积分，溯源等领域，大幅提高企业运营效率，降低成本，增强企业征信 ，解决中小企业融资难等问题。" forKey:@"introduce"];
//    [ybdict setValue:@"YCC" forKey:@"name"];
//    [ybdict setValue:@"原链BTC格式地址" forKey:@"nickname"];
//    [ybdict setValue:@"btc" forKey:@"platform"];
//    [ybdict setValue:@"1" forKey:@"treaty"];
//    [ybdict setValue:@"2" forKey:@"coin_type_nft"];
    
//        NSMutableDictionary *tdict = [NSMutableDictionary dictionary];
//        [tdict setValue:@"ETH" forKey:@"chain"];
//        [tdict setValue:@"http://bqbwallet.oss-cn-shanghai.aliyuncs.com/upload/5330b5a0ff892ee8e06049ec10391c0a.png" forKey:@"icon"];
//        [tdict setValue:@"725" forKey:@"id"];
//        [tdict setValue:@"这是nft-MEKA" forKey:@"introduce"];
//        [tdict setValue:@"MEKA" forKey:@"name"];
//        [tdict setValue:@"MekaVerse" forKey:@"nickname"];
//        [tdict setValue:@"ethereum" forKey:@"platform"];
//        [tdict setValue:@"1" forKey:@"treaty"];
//        [tdict setValue:@"1" forKey:@"coin_type_nft"];
    
    NSArray *array = @[BTCDict,edict,udict,bnbdict];
    
    return array;
}

@end
