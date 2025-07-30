//
//  CodeTextField.m
//  PWallet
//
//  Created by 宋刚 on 2018/5/23.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import "CodeTextField.h"

@implementation CodeTextField

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, CMColorFromRGB(0xFFFFFF).CGColor);
    CGContextFillRect(context, CGRectMake(0, CGRectGetHeight(self.frame) - 1, CGRectGetWidth(self.frame), 1));
}

@end
