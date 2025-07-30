//
//  PWOtherMessageModel.h
//  PWallet
//
//  Created by 杨威 on 2019/11/14.
//  Copyright © 2019 陈健. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PWMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface PWOtherMessageModel : NSObject
+ (instancetype)sharedManager;

-(void)addMessage:(id)userInfo;

-(NSArray*)loadData;

-(void)updateMessage:(PWMessage*)message;
@end

NS_ASSUME_NONNULL_END
