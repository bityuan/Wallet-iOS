//
//  PWMessage.h
//  PWallet
//
//  Created by 陈健 on 2018/11/19.
//  Copyright © 2018 陈健. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PWMessage : NSObject
@property (nonatomic,copy) NSString  *id;
@property (nonatomic,copy) NSString  *title;
@property (nonatomic,copy) NSString  *content;
@property (nonatomic,copy) NSString  *author;
@property (nonatomic,copy) NSString  *status;
@property (nonatomic,copy) NSString  *create_time;
@property (nonatomic,copy) NSString  *update_at;
@property (nonatomic,assign) BOOL  readed;
@end

NS_ASSUME_NONNULL_END
