//
//  RecentlyUsedAppTool.m
//  PWallet
//
//  Created by fzm on 2021/12/7.
//

#import "RecentlyUsedAppTool.h"


static NSString *const RecentlyUsedApp = @"RecentlyUsedApp";
static NSString *const LikeUsedApp = @"LikedApps";

@implementation RecentlyUsedAppTool
+ (void)setAppID:(NSString *)appID{
    NSMutableArray *idArr = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:RecentlyUsedApp]];
    if ([idArr containsObject:appID]) {
        [idArr removeObject:appID];
    }
    [idArr insertObject:appID atIndex:0];
    [[NSUserDefaults standardUserDefaults] setObject:idArr forKey:RecentlyUsedApp];
}

+ (NSArray *)getAppIDArray{
    return  [[NSUserDefaults standardUserDefaults] objectForKey:RecentlyUsedApp];
}

+ (void)setLikeApp:(NSDictionary*)app{
    NSMutableArray *idArr = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:LikeUsedApp]];
    NSMutableArray *urlArr = [NSMutableArray array];
    for (NSDictionary *dict in idArr) {
        [urlArr addObject:dict[@"url"]];
    }
    if ([urlArr containsObject:app[@"url"]]) {
        [idArr removeObject:app];
    }
    [idArr insertObject:app atIndex:0];
    [[NSUserDefaults standardUserDefaults] setObject:idArr forKey:LikeUsedApp];
}

+ (NSArray *)getLikeAppArray{
    return  [[NSUserDefaults standardUserDefaults] objectForKey:LikeUsedApp];
}

+(void)deleteLikeApp:(NSDictionary *)app{
    NSMutableArray *idArr = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:LikeUsedApp]];
    NSMutableArray *urlArr = [NSMutableArray arrayWithArray:idArr];
    NSString *url = app[@"url"];
    for (int i = 0; i < urlArr.count; i++) {
        NSDictionary *apps = urlArr[i];
        NSString *likeUrl = apps[@"url"];
        if ([url isEqualToString:likeUrl]) {
            [urlArr removeObject:apps];
            break;
        }
    }
    idArr = [NSMutableArray arrayWithArray:urlArr];
    
    [[NSUserDefaults standardUserDefaults] setObject:idArr forKey:LikeUsedApp];
}

@end
