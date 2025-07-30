//
//  ChineseCodeBackUpView.h
//  PWallet
//
//  Created by 宋刚 on 2018/5/24.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^CancelSelectItem)(NSString *);

@interface ChineseCodeBackUpView : UIView
@property (nonatomic,copy)CancelSelectItem cancelSelectItem;
@property (nonatomic,copy,getter=getChineseCode)NSString *chineseCode;
@property (nonatomic,assign,getter=getChineseCodeCount)NSInteger chineseCodeCount;
- (void)addItem:(NSString *)itemStr;
@end
