//
//  PWContactsDetailCell.h
//  PWallet
//  联系人详情 地址cell
//  Created by 陈健 on 2018/5/31.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^CopyAddressBlock)(NSString*);
@interface PWContactsDetailCell : UITableViewCell
/*地址**/
@property (nonatomic,strong) NSString *addressText;
/*主链(虚拟币名字)**/
@property (nonatomic,strong) NSString *coinNameText;
/*复制地址回调**/
@property (nonatomic, copy)CopyAddressBlock copyAddressBlock;
/*取消选中状态**/
-(void)deselectCell;
/** 设置选中状态 **/
-(void)setselectCell;
@end

