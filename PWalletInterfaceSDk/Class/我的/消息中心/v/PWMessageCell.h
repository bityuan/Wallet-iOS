//
//  PWMessageCell.h
//  PWallet
//
//  Created by 陈健 on 2018/11/19.
//  Copyright © 2018 陈健. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PWMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface PWMessageCell : UITableViewCell
/**model*/
@property (nonatomic,strong) PWMessage *message;
-(void)hideContent:(BOOL)hide;
-(void)showBadge;
-(void)hideBadge;
@end

NS_ASSUME_NONNULL_END
