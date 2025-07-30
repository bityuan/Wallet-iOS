//
//  PWContactsNameView.h
//  PWallet
//  显示 昵称 手机号 的view
//  Created by 陈健 on 2018/11/14.
//  Copyright © 2018 陈健. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PWEditContactsItem) {
    PWEditContactsItemNickname       = 0,  //显示昵称
    PWEditContactsItemPhoneNumber    = 1,  //显示手机号
};

typedef void(^PWEditContactsCompletionBlock)(PWEditContactsItem,NSString* _Nullable );

@interface PWContactsNameView : UIView
/**昵称*/
@property (nonatomic,copy) NSString *name;
/**手机号*/
@property (nonatomic,copy) NSString *phoneNumber;
/**昵称和手机号是否可以进行编辑 默认否*/
@property (nonatomic,assign) BOOL canEdit;
/*用户输入昵称或手机号后 判断为合法后进行回调 如果不合法 回调的字符串为nil**/
@property (nonatomic, copy)PWEditContactsCompletionBlock completionBlock;
@end

NS_ASSUME_NONNULL_END
