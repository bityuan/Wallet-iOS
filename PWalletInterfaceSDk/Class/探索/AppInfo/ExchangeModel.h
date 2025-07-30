//
//  ExchangeModel.h
//  PWallet
//
//  Created by fzm on 2021/12/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ExchangeModel : NSObject

@property (nonatomic, strong) NSString *cointype;
@property (nonatomic, strong) NSString *tokenSymbol;
@property (nonatomic, strong) NSString *execer;
@property (nonatomic, assign) int decimal;
@property (nonatomic, assign) double amount;
@property (nonatomic, assign) double fee;
@property (nonatomic, assign) int chainID;
@property (nonatomic, strong) NSString *bridgeBankContractAddr;
@property (nonatomic, strong) NSString *coinTokenContractAddr;
@property (nonatomic, strong) NSString *xgoBridgeBankContractAddr;
@property (nonatomic, strong) NSString *xgoOracleAddr;
@property (nonatomic, strong) NSString *contractTokenAddr;
@property (nonatomic, strong) NSString *note;
@end

NS_ASSUME_NONNULL_END
