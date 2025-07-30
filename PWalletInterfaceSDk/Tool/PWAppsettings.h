//
//  PWAppsettings.h
//  PWallet
//
//  Created by 郑晨 on 2019/4/30.
//  Copyright © 2019 陈健. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define declareSingleton(ClassName)\
+(ClassName*)instance;

#define implementSingleton(ClassName)\
static ClassName* instance;\
+(ClassName*)instance\
{\
@synchronized (self)\
{\
if (! instance)\
instance = [[ClassName alloc] init];\
}\
return instance;\
}

@interface PWAppsettings : NSObject
declareSingleton(PWAppsettings)

// 存储当前地址是创建的还是导入的
- (void)savecurrentCoinsName:(NSString *)name;
- (NSString *)getcurrentCoinsName;
- (void)deletecurrentCoinsName;

// 判断是否上传过地址了
- (void)saveHaveUploadAddress:(NSArray *)address;
- (NSArray *)getAddress;
- (void)deleteAddress;

// 缓存推荐币种
- (void)saveHomeCoinPrice:(NSMutableArray *)array;
- (NSMutableArray *)getHomeCoinPrice;
- (void)deleteHomeCoinPrice;

// 缓存本地币种
- (void)saveHomeLocalCoin:(NSMutableArray *)array;
- (NSMutableArray *)getHomeLocalCoin;
- (void)deleteHomeLocalCoin;


// 缓存当前view的偏移量
- (void)saveCurrentY:(NSString *)y;
- (NSString *)getCurrentY;
- (void)deleteCurrentY;

// 缓存托管账户首页资产和币种信息
- (void)saveEscrowInfo:(NSArray *)array;
- (NSArray *)getEscrowInfo;
- (void)deleteEscrowInfo;

// 缓存首页弹窗显示的公告id
- (void)saveHomeNoticeId:(NSMutableDictionary *)noticeIdMDict;
- (NSMutableDictionary *)getHomeNoticeId;
- (void)deleteHomeNoticeId;

//// 缓存当前计价货币
//- (void)saveCurrencyPrice:(PWCountryCurrenyModel *)model;
//- (PWCountryCurrenyModel *)getCurrencyPrice;
//- (void)deleteCurrencyPrice;

// 缓存当前钱包信息
- (void)saveWalletInfo:(NSMutableDictionary *)walletInfo;
- (NSMutableDictionary *)getWalletInfo;
- (void)deleteWalletInfo;

// 缓存托管账户信息
- (void)saveEscrowInfoWithPasswd:(NSMutableDictionary *)escrowInfo;
- (NSMutableDictionary *)getEscrowInfoWithPasswd;
- (void)deleteEscrowInfoWithPasswd;

// 缓存引导页信息
- (void)saveBootPageInfo:(NSMutableArray *)marray;
- (NSMutableArray *)getBootPageInfo;
- (void)deleteBootPageInfo;

// 缓存币种管理页面引导页信息
- (void)saveSearchBootPageInfo:(NSString *)info;
- (NSString *)getSearchBootPageInfo;
- (void)deleteSearchBootPageInfo;

// 缓存交易记录
- (void)saveTransLists:(NSMutableDictionary *)mudict;
- (NSMutableDictionary *)getTransLists;
- (void)deleteTransLists;

// 缓存导入钱包和创建钱包时的时间
- (void)saveCrAndImTime:(NSString *)timestr;
- (NSString *)getCrAndImTime;
- (void)deleteCrAndImTime;


// 缓存主页推荐币种信息
- (void)saveHomeCoinInfo:(NSArray *)coinInfoArray;
- (NSArray *)getHomeCoinInfo;
- (void)deleteHomeCoinInfo; 

// 缓存探索页面输入过的网址
- (void)saveEWebsite:(NSMutableArray *)websitrMarry;
- (NSMutableArray *)getEWebsite;
- (void)deleteEWebsite;

@end

NS_ASSUME_NONNULL_END
