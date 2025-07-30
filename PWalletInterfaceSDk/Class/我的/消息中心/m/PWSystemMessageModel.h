//
//  PWSystemMessageModel.h
//  PWallet
//
//  Created by 杨威 on 2019/12/11.
//  Copyright © 2019 陈健. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PWMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface PWSystemMessageModel : NSObject
+ (instancetype)sharedManager;

-(void)addMessage:(PWMessage*)message;

-(void)updateMessage:(PWMessage*)message;

-(void)deleteMessage:(PWMessage*)message;

-(BOOL)existMessage:(PWMessage*)message;

-(void)compareMessage:(NSArray*)array;
@end

NS_ASSUME_NONNULL_END
