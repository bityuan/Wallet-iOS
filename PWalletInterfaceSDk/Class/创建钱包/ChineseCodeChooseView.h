//
//  ChineseCodeChooseView.h
//  PWallet
//
//  Created by 宋刚 on 2018/5/24.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^PressItem) (NSString *);
@interface ChineseCodeChooseView : UIView
@property (nonatomic,copy) NSArray *items;
@property (nonatomic,copy) PressItem pressItem;
- (void)cancelPressedState:(NSString *)itemStr;
@end
