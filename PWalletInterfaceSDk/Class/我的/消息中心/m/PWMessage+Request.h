//
//  PWMessage+Request.h
//  PWallet
//
//  Created by 陈健 on 2018/11/19.
//  Copyright © 2018 陈健. All rights reserved.
//

#import "PWMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface PWMessage (Request)
/**
 获取消息
 @param parameters 参数
 @param successBlock 成功回调
 @param failureBlock 失败回调
 */
+ (void)getMessage:(NSDictionary*)parameters success:(requestSuccessBlock)successBlock failure:(requestFailureBlock)failureBlock;
+ (void)getMessageViaGet:(NSDictionary*)parameters success:(requestSuccessBlock)successBlock failure:(requestFailureBlock)failureBlock;
+ (void)getMessageDetail:(NSDictionary*)parameters success:(requestSuccessBlock)successBlock failure:(requestFailureBlock)failureBlock;
@end

NS_ASSUME_NONNULL_END
