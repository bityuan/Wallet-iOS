//
//  PWSearchContactsController.h
//  PWallet
//  搜索联系展示控制器
//  Created by 陈健 on 2018/5/29.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PWContacts.h"

@interface PWSearchContactsController : CommonViewController
@property(nonatomic,strong) NSMutableArray<NSMutableArray<PWContacts*>*> *dataArray;
typedef void(^DidSelectedBlock)(PWContacts*);
@property(nonatomic,copy)DidSelectedBlock didSelectedBlock;
@end
