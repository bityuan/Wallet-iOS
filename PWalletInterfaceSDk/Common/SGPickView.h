//
//  SGPickView.h
//  PWallet
//
//  Created by 宋刚 on 2018/3/16.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SGPickView;
@protocol SGPickViewDelegate <NSObject>
//取消事件代理
- (void)pickerViewDidCancel:(SGPickView*)pickerView;
//确定事件代理
- (void)pickerView:(SGPickView*)pickerView didSelectRow:(NSInteger)row;
@end

@interface SGPickView : UIView

@property (nonatomic,copy)NSArray *datasourceArray;
@property (nonatomic, weak) id <SGPickViewDelegate> delegate;
- (void)showAnimation;
@end
