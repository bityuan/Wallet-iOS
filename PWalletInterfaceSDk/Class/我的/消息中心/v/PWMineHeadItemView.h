//
//  PWMineHeadItemView.h
//  PWallet
//
//  Created by 郑晨 on 2019/12/13.
//  Copyright © 2019 陈健. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^PWMineHeadItemViewBlock)(NSString *item);

@interface PWMineHeadItemView : UIView

- (instancetype)initWithFrame:(CGRect)frame;

@property (nonatomic) PWMineHeadItemViewBlock mineHeadItemViewBlock;
@property (nonatomic, strong) NSArray *dataArray;

@end

NS_ASSUME_NONNULL_END
