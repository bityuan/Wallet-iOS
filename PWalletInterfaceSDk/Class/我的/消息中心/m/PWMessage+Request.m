//
//  PWMessage+Request.m
//  PWallet
//
//  Created by 陈健 on 2018/11/19.
//  Copyright © 2018 陈健. All rights reserved.
//

#import "PWMessage+Request.h"
#import "PWNetworkingTool.h"
#import <YYModel/YYModel.h>

@implementation PWMessage (Request)
+ (void)getMessage:(NSDictionary*)parameters success:(requestSuccessBlock)successBlock failure:(requestFailureBlock)failureBlock {
    NSString *url = [NSString stringWithFormat:@"%@%@",WalletURL,PW_NOTICE];
    [PWNetworkingTool postRequestWithUrl:url parameters:parameters successBlock:^(id object) {
        if (successBlock) {
            NSArray *array = [NSArray yy_modelArrayWithClass:[PWMessage class] json:object];
            successBlock(array);
        }
    } failureBlock:^(NSError *error) {
        if (failureBlock) {
            failureBlock(error);
        }
    }];
}

+ (void)getMessageViaGet:(NSDictionary*)parameters success:(requestSuccessBlock)successBlock failure:(requestFailureBlock)failureBlock {
    NSString *url = [NSString stringWithFormat:@"%@%@",WalletURL,PW_NOTICE];
    [PWNetworkingTool getRequestWithUrl:url parameters:parameters successBlock:^(id object) {
        if (successBlock) {
            NSArray *array = [NSArray yy_modelArrayWithClass:[PWMessage class] json:object[@"list"]];
            successBlock(array);
        }
    } failureBlock:^(NSError *error) {
        if (failureBlock) {
            failureBlock(error);
        }
    }];
}

+ (void)getMessageDetail:(NSDictionary*)parameters success:(requestSuccessBlock)successBlock failure:(requestFailureBlock)failureBlock {
    NSString *url = [NSString stringWithFormat:@"%@%@",WalletURL,PW_NOTICE_DETAIL];
    [PWNetworkingTool getRequestWithUrl:url parameters:parameters successBlock:^(id object) {
        if (successBlock) {
            successBlock(object);
        }
    } failureBlock:^(NSError *error) {
        if (failureBlock) {
            failureBlock(error);
        }
    }];
}
@end
