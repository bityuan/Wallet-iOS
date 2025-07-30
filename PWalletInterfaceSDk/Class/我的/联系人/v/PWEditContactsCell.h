//
//  PWEditContactsCell.h
//  PWallet
//  添加联系人 cell
//  Created by 陈健 on 2018/5/31.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, PWEditContactsCellStyle) {
    PWEditContactsCellStyleNickname       = 0,  //显示昵称
    PWEditContactsCellStylePhoneNumber    = 1,  //显示手机号
};

typedef void(^CompletionBlock)(NSString*);
@interface PWEditContactsCell : UITableViewCell
@property (nonatomic, assign)PWEditContactsCellStyle style;
/*用户输入昵称或手机号后 判断为合法后进行回调 如果不合法 回调的字符串为nil**/
@property (nonatomic, copy)CompletionBlock completionBlock;
@property (weak, nonatomic) UITextField *infoTextField;
@end
