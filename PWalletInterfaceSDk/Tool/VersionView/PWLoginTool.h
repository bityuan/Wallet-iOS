//
//  PWLoginTool.h
//  PWallet
//
//  Created by 于优 on 2018/10/25.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PWVersionModel.h"

@interface PWLoginTool : NSObject


/**
 *   获取当前显示Vc
 */
+ (UIViewController *)getCurrentVC;

/**
 *
 */
+ (NSString *)generateTradeNO;

/**
 *
 */
+ (NSString *)md5:(NSString *)str;

/**
 *   获取设备UUID
 */
+ (NSString *)getUUID;

/**
 *   保存设备UUID
 */
+ (void)saveUUID:(NSString *)uuid;

/**
 *   日期对比
 * 
 */
+ (NSInteger)compareOneDay:(NSDate *)currentDay withAnotherDay:(NSDate *)BaseDay;

/**
 *   检查gengxin
 *
 */
+ (void)checkUpdate:(UIViewController *)Vc data:(NSDictionary *)data;
+ (void)recommendUpdate:(UIViewController *)Vc data:(PWVersionModel *)data;
+ (void)forcedUpdate:(UIViewController *)Vc data:(PWVersionModel *)data;
/**
 *   弹出登录界面
 *
 */
+ (void)presentLoginViewController:(UIViewController *)superVc wihtNavVc:(UINavigationController *)navVc;

@end
