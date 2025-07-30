//
//  PWLanguageViewController.h
//  PWallet
//
//  Created by 郑晨 on 2019/6/3.
//  Copyright © 2019 陈健. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonViewController.h"
NS_ASSUME_NONNULL_BEGIN
typedef enum : NSUInteger {
    ChangeLang,
    ChangeMoney,
    ChangeIP,
} ChangeType;
@interface PWLanguageViewController :CommonViewController
- (instancetype)initWithChangeType:(ChangeType)type;

@end

NS_ASSUME_NONNULL_END
