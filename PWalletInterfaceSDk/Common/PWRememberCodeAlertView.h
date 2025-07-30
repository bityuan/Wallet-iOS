//
//  PWRememberCodeAlertView.h
//  PWallet
//
//  Created by 陈健 on 2018/11/15.
//  Copyright © 2018 陈健. All rights reserved.
//

#import "PWBaseAlertView.h"

/*
 
 使用方式
 //中文助记词格式 床前明 月光疑 是地上 霜举头 望明月
 //英文助记词格式 Please down the mnemonic word and we will check in carefully
 
 PWRememberCodeAlertView *view = [[PWRememberCodeAlertView alloc]initWithTitle:@"查看助记词" rememberCode:@"床前明 月光疑 是地上 霜举头 望明月" buttonName:@"知道了"];
 view.okBlock = ^(id obj) {
 NSLog(@"12312312312312312312");
 };
 [[UIApplication sharedApplication].keyWindow addSubview:view];
 
 */

NS_ASSUME_NONNULL_BEGIN

@interface PWRememberCodeAlertView : PWBaseAlertView
/**
 初始化方法
 @param title title
 @param rememberCode rememberCode
 @param buttonName 确定按钮名字
 */
- (instancetype)initWithTitle:(NSString*)title rememberCode:(NSString*)rememberCode buttonName:(NSString*)buttonName;

@property(nonatomic,copy)NSString *wallet_name;
@property(nonatomic,copy)NSString *rememberCode;

@property(nonatomic,copy)void (^ClickPastAction) (NSString *);
@end

NS_ASSUME_NONNULL_END
