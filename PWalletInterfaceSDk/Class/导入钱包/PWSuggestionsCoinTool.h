//
//  PWSuggestionsCoinTool.h
//  PWallet
//  获取推荐币种 
//  Created by 陈健 on 2018/7/30.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PWSuggestionsCoinTool : NSObject
/**
 从取推荐币种
 @param successBlock 成功回调
 @param failureBlock 失败回调
 */
+ (void)loadSuggestionsCoin:(requestSuccessBlock)successBlock failureBlock:(requestFailureBlock)failureBlock;
+ (void)loadSuggestionsCoin:(NSString *)recommendId successBlock:(requestSuccessBlock)successBlock failureBlock:(requestFailureBlock)failureBlock;
@end
