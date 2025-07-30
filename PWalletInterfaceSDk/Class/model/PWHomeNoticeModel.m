//
//  PWHomeNoticeModel.m
//  PWallet
//
//  Created by 郑晨 on 2019/12/2.
//  Copyright © 2019 陈健. All rights reserved.
//

#import "PWHomeNoticeModel.h"
#import <NSObject+YYModel.h>
@implementation PWHomeNoticeModel

+ (nullable NSDictionary<NSString *, id>  *)modelCustomPropertyMapper
{
    return @{@"notice_id":@"id"};
}

@end
