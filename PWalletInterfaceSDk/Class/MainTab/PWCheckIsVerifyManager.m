//
//  PWCheckIsVerifyManager.m
//  PWallet
//
//  Created by fzm on 2021/5/18.
//  Copyright © 2021 陈健. All rights reserved.
//

#import "PWCheckIsVerifyManager.h"

#define isVerify @"https://gitlab.33.cn/morningcat/1234/raw/master/MYDAOisVerify136.json"

@implementation PWCheckIsVerifyManager

+ (BOOL)checkIsVerify{
   
    BOOL isChecked = [[[NSUserDefaults standardUserDefaults] objectForKey:isVerify] boolValue];
    if (isChecked) {
        return YES;
    }
    NSString *htmlStr = [NSString stringWithContentsOfURL:[NSURL URLWithString:isVerify] encoding:NSUTF8StringEncoding error:nil];
   
    if ([htmlStr containsString:@"0"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:isVerify];
        return NO;
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:isVerify];
        return YES;
    }
}

@end
