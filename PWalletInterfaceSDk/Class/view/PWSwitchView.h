//
//  PWSwitchView.h
//  PWallet
//
//  Created by 陈健 on 2018/11/1.
//  Copyright © 2018 陈健. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PWSwitchView : UIView

@property(nonatomic,getter=isOn) BOOL on;

- (void)addTarget:(nullable id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

@end

NS_ASSUME_NONNULL_END
