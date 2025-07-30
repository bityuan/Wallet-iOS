//
//  NSString+Localized.m
//  PWallet
//
//  Created by 陈健 on 2018/9/21.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import "NSString+Localized.h"
#import "LocalizableService.h"

@implementation NSString (Localized)
- (NSString *)localized {
    return [LocalizableService localizedString:self];
}
@end
