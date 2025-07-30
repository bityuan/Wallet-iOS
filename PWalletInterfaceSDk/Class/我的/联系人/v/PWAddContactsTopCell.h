//
//  PWAddContactsTopCell.h
//  PWallet
//  添加联系人 昵称 和 手机号 cell
//  Created by 陈健 on 2018/5/30.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, PWAddContactsTopCellStyle) {
    PWAddContactsTopCellStyleNickname       = 0,  //显示昵称
    PWAddContactsTopCellStylePhoneNumber    = 1,  //显示手机号
};

typedef void(^CompletionBlock)(NSString*);
@interface PWAddContactsTopCell : UITableViewCell
@property (nonatomic, assign)PWAddContactsTopCellStyle style;
/*用户输入昵称或手机号后 判断为合法后进行回调 如果不合法 回调的字符串为nil**/
@property (nonatomic, copy)CompletionBlock completionBlock;
@property (nonatomic,copy) NSString *inforText;
/**textField 用于将按钮添加到键盘上*/
- (void)setKeyBoardInputView:(UIView *)inputView action:(SEL)operation;
@end
