//
//  ChineseCodeChooseView.m
//  PWallet
//
//  Created by 宋刚 on 2018/5/24.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import "ChineseCodeChooseView.h"

@interface ChineseCodeChooseView()
@property (nonatomic,strong) NSMutableArray *buttonArray;
@end

@implementation ChineseCodeChooseView
- (instancetype)init
{
    self = [super init];
    if (self) {
        _buttonArray = [[NSMutableArray alloc] init];
        [self createView];
    }
    return self;
}

- (void)createView
{
    
}

- (void)setItems:(NSArray *)items
{
    _items = items;
    
    NSArray *randomArray = [self getRandomArrFrome:items];
    for (int i = 0; i < randomArray.count; i ++) {
        NSString *itemStr = [randomArray objectAtIndex:i];
        [self addItem:itemStr];
    }
}

- (void)addItem:(NSString *)itemStr
{
    UIButton *item = [[UIButton alloc] init];
    item.tag = self.subviews.count;
    [item setTitle:itemStr forState:UIControlStateNormal];
    [item setTitleColor:CMColorFromRGB(0x8E92A3) forState:UIControlStateNormal];
    item.layer.cornerRadius = 3;
    item.layer.borderColor = CMColorFromRGB(0x8E92A3).CGColor;
    item.layer.borderWidth = 0.5;
    item.titleLabel.font = [UIFont systemFontOfSize:18];
    [item setSelected:NO];
    [item addTarget:self action:@selector(itemBtnClickAction:) forControlEvents:UIControlEventTouchUpInside];

    CGFloat itemX = 18;
    CGFloat itemY = 10;
    CGFloat lastBtnRight = 0;
    CGFloat lastBtnBottom = 0;
    CGFloat itemWidth = (SCREENBOUNDS.size.width - 36 - 5 * 22) / 6;
    CGFloat itemHeight = itemWidth;
    
    for (int i = 0;i < self.subviews.count;i ++) {
        UIButton *button = (UIButton *)[self.subviews objectAtIndex:i];
        if (button.tag == self.subviews.count - 1) {
            lastBtnRight = button.frame.origin.x + button.frame.size.width;
            lastBtnBottom = button.frame.origin.y + button.frame.size.height;
            break;
        }
    }
    
    if(self.subviews.count != 0)
    {
        if (lastBtnRight + 18 + itemWidth > SCREENBOUNDS.size.width - 18) {
            itemX = 18;
            itemY = lastBtnBottom + 11;
        }else
        {
            itemX = lastBtnRight + 22;
            itemY = lastBtnBottom - itemHeight;
        }
    }
    item.frame = CGRectMake(itemX, itemY, itemWidth, itemHeight);
    [self addSubview:item];
    [_buttonArray addObject:item];
}

/**
 * 按钮点击事件
 */
- (void)itemBtnClickAction:(UIButton *)sender
{
    if (![sender isSelected]) {
        [sender setSelected:YES];
        self.pressItem(sender.titleLabel.text);
        [self cancelPressedState:@""];
    }
}

/**
 * 取消选择
 */
- (void)cancelPressedState:(NSString *)itemStr
{
    for (int i = 0; i < _buttonArray.count; i ++) {
        UIButton *itemBtn = (UIButton *)[_buttonArray objectAtIndex:i];
        if ([itemStr isEqualToString:itemBtn.titleLabel.text] && [itemBtn isSelected]) {
            [itemBtn setSelected:NO];
            [itemBtn setBackgroundColor:CMColorFromRGB(0x2B292F)];
            [itemBtn setTitleColor:CMColorFromRGB(0x8E92A3) forState:UIControlStateNormal];
            itemBtn.layer.borderColor = CMColorFromRGB(0x8E92A3).CGColor;
            break;
        }
    }
    
    for (id object in self.subviews) {
        UIButton *itemBtn = (UIButton *)object;
        [itemBtn removeFromSuperview];
    }
    
    for (id object in _buttonArray) {
        UIButton *itemBtn = (UIButton *)object;
        [self reAddItem:itemBtn];
    }
}

- (void)reAddItem:(UIButton *)item
{
    NSString *itemStr = item.titleLabel.text;
    item.tag = self.subviews.count;
    [item setTitle:itemStr forState:UIControlStateNormal];
    
    if (item.selected) {
        [item setBackgroundColor:CMColorFromRGB(0x4E5370)];
        [item setTitleColor:CMColorFromRGB(0xFFFFFF) forState:UIControlStateNormal];
        item.layer.borderColor = [UIColor clearColor].CGColor;
    }
    
    [item addTarget:self action:@selector(itemBtnClickAction:) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat itemX = 18;
    CGFloat itemY = 10;
    CGFloat lastBtnRight = 0;
    CGFloat lastBtnBottom = 0;
    CGFloat itemWidth = (SCREENBOUNDS.size.width - 36 - 5 * 22) / 6;
    CGFloat itemHeight = itemWidth;
    
    for (int i = 0;i < self.subviews.count;i ++) {
        UIButton *button = (UIButton *)[self.subviews objectAtIndex:i];
        if (button.tag == self.subviews.count - 1) {
            lastBtnRight = button.frame.origin.x + button.frame.size.width;
            lastBtnBottom = button.frame.origin.y + button.frame.size.height;
            break;
        }
    }
    
    if(self.subviews.count != 0)
    {
        if (lastBtnRight + 18 + itemWidth > SCREENBOUNDS.size.width - 18) {
            itemX = 18;
            itemY = lastBtnBottom + 11;
        }else
        {
            itemX = lastBtnRight + 22;
            itemY = lastBtnBottom - itemHeight;
        }
    }
    item.frame = CGRectMake(itemX, itemY, itemWidth, itemHeight);
    [self addSubview:item];
}

-(NSMutableArray*)getRandomArrFrome:(NSArray*)arr
{
    NSMutableArray *newArr = [NSMutableArray new];
    while (newArr.count != arr.count) {
        //生成随机数
        int x =arc4random() % arr.count;
        id object = arr[x];
        int count = 0;
        int newCount = 0;
        for(int i = 0;i < arr.count;i++)
        {
            if ([object isEqual:[arr objectAtIndex:i]]) {
                count++;
            }
        }
        
        for(int i = 0;i < newArr.count;i++)
        {
            if ([object isEqual:[newArr objectAtIndex:i]]) {
                newCount++;
            }
        }
        
        if (newCount < count) {
            [newArr addObject:object];
        }
    }
    return newArr;
}

@end
