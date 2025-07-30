//
//  MineTableViewCell.m
//  PWallet
//
//  Created by 宋刚 on 2018/5/25.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import "MineTableViewCell.h"

@implementation MineTableViewCell

- (void)layoutSubviews {
    
    [super layoutSubviews];
    CGRect rect = self.imageView.frame;

    self.imageView.frame = CGRectMake(16, rect.origin.y, rect.size.width, rect.size.height );
    
    
    CGRect tmpFrame = self.textLabel.frame;
    if (rect.size.width == 0 && rect.size.height == 0)
    {
        tmpFrame.origin.x = 16;
    }
    else
    {
        tmpFrame.origin.x = 46;
    }
    
    
    self.textLabel.frame = tmpFrame;
    
}

@end
