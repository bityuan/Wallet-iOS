//
//  PWVersionModel.h
//  PWallet
//
//  Created by 于优 on 2018/11/14.
//  Copyright © 2018 陈健. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PWVersionModel : NSObject


/** 内容 */
@property (nonatomic, strong) NSString *log;
/** 状态 */
@property (nonatomic, assign) NSInteger version_code;
/** 状态 */
@property (nonatomic, assign) NSInteger status;
/** 版本 */
@property (nonatomic, copy) NSString *version;
/** url */
@property (nonatomic, copy) NSString *download_url;

@property (nonatomic, copy) NSString *md5;

@end
