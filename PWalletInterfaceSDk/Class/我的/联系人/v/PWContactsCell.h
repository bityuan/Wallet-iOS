//
//  PWContactsCell.h
//  PWallet
//
//  Created by 陈健 on 2018/11/13.
//  Copyright © 2018 陈健. All rights reserved.
//

#import <MGSwipeTableCell/MGSwipeTableCell.h>

NS_ASSUME_NONNULL_BEGIN

@interface PWContactsCell : MGSwipeTableCell

/**名字*/
@property (nonatomic,copy) NSString *text;
/**电话号码*/
@property (nonatomic,copy) NSString *detailText;
/**控制圆圈颜色*/
@property (nonatomic,assign) NSInteger index;
@end

NS_ASSUME_NONNULL_END
