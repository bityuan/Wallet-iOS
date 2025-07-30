//
//  PWHomeNoticeModel.h
//  PWallet
//
//  Created by 郑晨 on 2019/12/2.
//  Copyright © 2019 陈健. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PWHomeNoticeModel : NSObject

@property (nonatomic, strong) NSString *author; // 作者
@property (nonatomic, strong) NSString *create_time; // 创建时间
@property (nonatomic, strong) NSString *notice_id; // id
@property (nonatomic, strong) NSString *title; // 标题
@property (nonatomic, strong) NSString *type; // 类型
@property (nonatomic, strong) NSString *is_top;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *update_time;


@end

NS_ASSUME_NONNULL_END
