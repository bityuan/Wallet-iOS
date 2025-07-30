//
//  PWAppsettings.m
//  PWallet
//
//  Created by 郑晨 on 2019/4/30.
//  Copyright © 2019 陈健. All rights reserved.
//

#import "PWAppsettings.h"


@implementation PWAppsettings
implementSingleton(PWAppsettings)
- (void)savecurrentCoinsName:(NSString *)name
{
    // app名称
    NSData *encodedPosts = [NSKeyedArchiver archivedDataWithRootObject:name requiringSecureCoding:true error:nil];
//    NSData *encodedPosts = [NSKeyedArchiver archivedDataWithRootObject:name];
    [[NSUserDefaults standardUserDefaults] setObject:encodedPosts forKey:kAppName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)getcurrentCoinsName
{
    NSData *encodedPosts = [[NSUserDefaults standardUserDefaults] objectForKey:kAppName];
    return [NSKeyedUnarchiver unarchivedObjectOfClass:[NSString class] fromData:encodedPosts error:nil];
//    return [NSKeyedUnarchiver unarchiveObjectWithData:encodedPosts];
}

- (void)deletecurrentCoinsName
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAppName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 判断是否上传过地址了
- (void)saveHaveUploadAddress:(NSArray *)address
{
   
    NSData *encodedPosts = [NSKeyedArchiver archivedDataWithRootObject:address];
    [[NSUserDefaults standardUserDefaults] setObject:encodedPosts forKey:[NSString stringWithFormat:@"%@%@",kAppName,@"1234"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (NSArray *)getAddress
{
    NSData *encodedPosts = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",kAppName,@"1234"]];
    return [NSKeyedUnarchiver unarchiveObjectWithData:encodedPosts];
}
- (void)deleteAddress
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@%@",kAppName,@"1234"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 缓存首页币种
- (void)saveHomeCoinPrice:(NSMutableArray *)array
{
    NSData *encodedPosts = [NSKeyedArchiver archivedDataWithRootObject:array];
    [[NSUserDefaults standardUserDefaults] setObject:encodedPosts forKey:[NSString stringWithFormat:@"%@%@",kAppName,@"2"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (NSMutableArray *)getHomeCoinPrice
{
    NSData *encodedPosts = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",kAppName,@"2"]];
    return [NSKeyedUnarchiver unarchiveObjectWithData:encodedPosts];
}
- (void)deleteHomeCoinPrice
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@%@",kAppName,@"2"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 缓存本地币种
- (void)saveHomeLocalCoin:(NSMutableArray *)array
{
    NSData *encodedPosts = [NSKeyedArchiver archivedDataWithRootObject:array];
    [[NSUserDefaults standardUserDefaults] setObject:encodedPosts forKey:[NSString stringWithFormat:@"%@%@",kAppName,@"7"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (NSMutableArray *)getHomeLocalCoin
{
    NSData *encodedPosts = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",kAppName,@"7"]];
    return [NSKeyedUnarchiver unarchiveObjectWithData:encodedPosts];
}
- (void)deleteHomeLocalCoin
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@%@",kAppName,@"7"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 缓存当前view的偏移量
- (void)saveCurrentY:(NSString *)y
{
    NSData *encodedPosts = [NSKeyedArchiver archivedDataWithRootObject:y];
    [[NSUserDefaults standardUserDefaults] setObject:encodedPosts forKey:[NSString stringWithFormat:@"%@%@",kAppName,@"10"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)getCurrentY
{
    NSData *encodedPosts = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",kAppName,@"10"]];
    return [NSKeyedUnarchiver unarchiveObjectWithData:encodedPosts];
}

- (void)deleteCurrentY
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@%@",kAppName,@"10"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 缓存托管账户首页资产和币种信息
- (void)saveEscrowInfo:(NSArray *)array
{
    NSData *encodedPosts = [NSKeyedArchiver archivedDataWithRootObject:array];
    [[NSUserDefaults standardUserDefaults] setObject:encodedPosts forKey:[NSString stringWithFormat:@"%@%@",kAppName,@"100"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (NSArray *)getEscrowInfo
{
    NSData *encodedPosts = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",kAppName,@"100"]];
    return [NSKeyedUnarchiver unarchiveObjectWithData:encodedPosts];
}
- (void)deleteEscrowInfo
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@%@",kAppName,@"100"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 缓存首页弹窗显示的公告id
- (void)saveHomeNoticeId:(NSMutableDictionary *)noticeIdMDict
{
    NSData *encodedPosts = [NSKeyedArchiver archivedDataWithRootObject:noticeIdMDict];
    [[NSUserDefaults standardUserDefaults] setObject:encodedPosts forKey:[NSString stringWithFormat:@"%@%@",kAppName,@"10002"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (NSMutableDictionary *)getHomeNoticeId
{
    NSData *encodedPosts = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",kAppName,@"10002"]];
    return [NSKeyedUnarchiver unarchiveObjectWithData:encodedPosts];
}
- (void)deleteHomeNoticeId
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@%@",kAppName,@"10002"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 缓存当前钱包信息
- (void)saveWalletInfo:(NSMutableDictionary *)walletInfo
{
    NSData *encodedPosts = [NSKeyedArchiver archivedDataWithRootObject:walletInfo];
    [[NSUserDefaults standardUserDefaults] setObject:encodedPosts forKey:[NSString stringWithFormat:@"%@%@",kAppName,@"100001"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (NSMutableDictionary *)getWalletInfo
{
    
    NSData *encodedPosts = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",kAppName,@"100001"]];
    return [NSKeyedUnarchiver unarchiveObjectWithData:encodedPosts];
}

- (void)deleteWalletInfo
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@%@",kAppName,@"100001"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 缓存托管账户信息
- (void)saveEscrowInfoWithPasswd:(NSMutableDictionary *)escrowInfo
{
    NSData *encodedPosts = [NSKeyedArchiver archivedDataWithRootObject:escrowInfo];
       [[NSUserDefaults standardUserDefaults] setObject:encodedPosts forKey:[NSString stringWithFormat:@"%@%@",kAppName,@"100004"]];
       [[NSUserDefaults standardUserDefaults] synchronize];
}
- (NSMutableDictionary *)getEscrowInfoWithPasswd
{
    NSData *encodedPosts = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",kAppName,@"100004"]];
    return [NSKeyedUnarchiver unarchiveObjectWithData:encodedPosts];
}
- (void)deleteEscrowInfoWithPasswd
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@%@",kAppName,@"100004"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 缓存引导页信息
- (void)saveBootPageInfo:(NSMutableArray *)marray
{
    NSData *encodedPosts = [NSKeyedArchiver archivedDataWithRootObject:marray];
    [[NSUserDefaults standardUserDefaults] setObject:encodedPosts forKey:[NSString stringWithFormat:@"%@%@",kAppName,@"100002"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (NSMutableArray *)getBootPageInfo
{
    NSData *encodedPosts = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",kAppName,@"100002"]];
    return [NSKeyedUnarchiver unarchiveObjectWithData:encodedPosts];
}
- (void)deleteBootPageInfo
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@%@",kAppName,@"100002"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 缓存币种管理页面引导页信息
- (void)saveSearchBootPageInfo:(NSString *)info
{
    NSData *encodedPosts = [NSKeyedArchiver archivedDataWithRootObject:info];
    [[NSUserDefaults standardUserDefaults] setObject:encodedPosts forKey:[NSString stringWithFormat:@"%@%@",kAppName,@"100003"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (NSString *)getSearchBootPageInfo
{
    NSData *encodedPosts = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",kAppName,@"100003"]];
    return [NSKeyedUnarchiver unarchiveObjectWithData:encodedPosts];
}
- (void)deleteSearchBootPageInfo
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@%@",kAppName,@"100003"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 缓存交易记录
- (void)saveTransLists:(NSMutableDictionary *)mudict
{
    NSData *encodedPosts = [NSKeyedArchiver archivedDataWithRootObject:mudict];
    [[NSUserDefaults standardUserDefaults] setObject:encodedPosts forKey:[NSString stringWithFormat:@"%@%@",kAppName,@"100004"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (NSMutableDictionary *)getTransLists
{
    NSData *encodedPosts = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",kAppName,@"100004"]];
    return [NSKeyedUnarchiver unarchiveObjectWithData:encodedPosts];
}

- (void)deleteTransLists
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@%@",kAppName,@"100004"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 缓存导入钱包和创建钱包时的时间
- (void)saveCrAndImTime:(NSString *)timestr
{
    NSData *encodedPosts = [NSKeyedArchiver archivedDataWithRootObject:timestr];
    [[NSUserDefaults standardUserDefaults] setObject:encodedPosts forKey:[NSString stringWithFormat:@"%@%@",kAppName,@"100005"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (NSString *)getCrAndImTime
{
    NSData *encodedPosts = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",kAppName,@"100005"]];
    return [NSKeyedUnarchiver unarchiveObjectWithData:encodedPosts];
}
- (void)deleteCrAndImTime
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@%@",kAppName,@"100005"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 缓存主页推荐币种信息
- (void)saveHomeCoinInfo:(NSArray *)coinInfoArray
{
    NSData *encodedPosts = [NSKeyedArchiver archivedDataWithRootObject:coinInfoArray];
    [[NSUserDefaults standardUserDefaults] setObject:encodedPosts forKey:[NSString stringWithFormat:@"%@%@",kAppName,@"coininfo"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (NSArray *)getHomeCoinInfo
{
    NSData *encodedPosts = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",kAppName,@"coininfo"]];
    return [NSKeyedUnarchiver unarchiveObjectWithData:encodedPosts];
}
- (void)deleteHomeCoinInfo
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@%@",kAppName,@"coininfo"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
// 缓存探索页面输入过的网址
- (void)saveEWebsite:(NSMutableArray *)websitrMarry
{
//    NSData *encodedPosts = [NSKeyedArchiver archivedDataWithRootObject:websitrMarry];
    NSData *encodedPosts = [NSKeyedArchiver archivedDataWithRootObject:websitrMarry requiringSecureCoding:true error:nil];
    [[NSUserDefaults standardUserDefaults] setObject:encodedPosts forKey:[NSString stringWithFormat:@"%@%@",kAppName,@"websitemarry"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (NSMutableArray *)getEWebsite
{
    NSData *encodedPosts = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",kAppName,@"websitemarry"]];
   
    return [NSKeyedUnarchiver unarchivedObjectOfClass:[NSMutableArray class] fromData:encodedPosts error:nil];
//    return [NSKeyedUnarchiver unarchiveObjectWithData:encodedPosts];
}
- (void)deleteEWebsite
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@%@",kAppName,@"websitemarry"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
