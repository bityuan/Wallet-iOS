//
//  ChineseCodeView.h
//  PWallet
//
//  Created by 宋刚 on 2018/5/23.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CodeTextField.h"

@interface ChineseCodeView : UIView

@property (nonatomic,copy,getter=getChineseCode)NSString * _Nullable chineseCode;
- (void)setKeyBoardInputView:(UIView *_Nonnull)inputView action:(SEL _Nonnull )operation;
@end
