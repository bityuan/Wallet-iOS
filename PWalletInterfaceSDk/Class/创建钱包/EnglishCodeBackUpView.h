//
//  EnglishCodeBackUpView.h
//  PWallet
//
//  Created by 宋刚 on 2018/5/24.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^CancelSelectItem)(NSString *);
typedef void(^RemakeSelfHeight)(CGFloat );
@interface EnglishCodeBackUpView : UIView
@property (nonatomic,copy)CancelSelectItem cancelSelectItem;
@property (nonatomic,copy)RemakeSelfHeight remakeSelfHeight;
@property (nonatomic,copy,getter=getEnglishCode)NSString *englishCode;
@property (nonatomic,assign,getter=getEnglishCodeCount)NSInteger englishCodeCount;
- (void)addItem:(NSString *)itemStr;
@end
