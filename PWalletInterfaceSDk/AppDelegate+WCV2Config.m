//
//  AppDelegate+WCV2Config.m
//  PWalletInterfaceSDk
//
//  Created by 郑晨 on 2023/7/21.
//  Copyright © 2023 fzm. All rights reserved.
//

#import "AppDelegate+WCV2Config.h"
#import "PWalletInterfaceSDk-Swift.h"
@implementation AppDelegate (WCV2Config)

- (void)configV2
{
    V2Config *config = [[V2Config alloc] init];
    [config conifgures];
}

@end
