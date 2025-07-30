//
//  PWVersionView.h
//  PWallet
//
//  Created by 于优 on 2018/11/14.
//  Copyright © 2018 陈健. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PWVersionModel;
// gx类型
typedef NS_ENUM(NSUInteger, PWUpdateType) {
    PWUpdateTypeNormal = 0,     // 一般
    PWUpdateTypeMust            // 强制
};

@interface PWVersionView : UIView

+ (instancetype)shopView;
/** 内容 */
@property (nonatomic, strong) PWVersionModel *versionModel;
/** 类型 */
@property (nonatomic, assign) PWUpdateType updateType;

@end
