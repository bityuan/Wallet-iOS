//
//  PWChoiceChainViewController.h
//  PWallet
//
//  Created by 郑晨 on 2019/10/21.
//  Copyright © 2019 陈健. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    ChoiceTypPri,
    ChoiceTypeAdd,
} ChoiceType;

NS_ASSUME_NONNULL_BEGIN

typedef void(^ChoiceChainBlock)(NSString *chainName,NSString *chainImageName, NSString *coinName);

@interface PWChoiceChainViewController : CommonViewController

@property (nonatomic, strong) NSString *chainStr;

@property (nonatomic) ChoiceChainBlock choiceChainBlock;

@property (nonatomic) ChoiceType choiceType;// 选择类型
@end

NS_ASSUME_NONNULL_END
