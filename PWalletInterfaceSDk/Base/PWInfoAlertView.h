//
//  PWInfoAlertView.h
//  PWallet
//
//  Created by 陈健 on 2018/9/7.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import "PWBaseAlertView.h"
/*
 
 使用方式
 PWInfoAlertView *view = [[PWInfoAlertView alloc]initWithTitle:@"提示" message:@"ZWGYBA剩余数量不足，请稍后购买！" buttonName:@"确定"];
 view.okBlock = ^(id obj) {
 NSLog(@"12312312312312312312");
 };
 [self.view addSubview:view];
 
 */

@interface PWInfoAlertView : PWBaseAlertView
/**
 初始化方法
 @param title title
 @param message message
 @param buttonName 确定按钮名字
 */
- (instancetype)initWithTitle:(NSString*)title message:(NSString*)message buttonName:(NSString*)buttonName;
@end
