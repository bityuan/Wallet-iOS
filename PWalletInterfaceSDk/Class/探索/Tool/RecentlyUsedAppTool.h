//
//  RecentlyUsedAppTool.h
//  PWallet
//
//  Created by fzm on 2021/12/7.
//
//  保存和获取最近使用的app的id

#import <Foundation/Foundation.h>
#import "PWApplication.h"
NS_ASSUME_NONNULL_BEGIN

@interface RecentlyUsedAppTool : NSObject
+(void)setAppID:(NSString *)appID;
+(NSArray *)getAppIDArray;

+ (void)setLikeApp:(NSDictionary*)app;
+ (NSArray *)getLikeAppArray;
+ (void)deleteLikeApp:(NSDictionary *)app;
@end

NS_ASSUME_NONNULL_END
