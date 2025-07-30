//
//  EnglishCodeView.m
//  PWallet
//
//  Created by 宋刚 on 2018/5/23.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import "EnglishCodeView.h"

@interface EnglishCodeView()<UITextViewDelegate>
@property (nonatomic,strong) UITextView *textView;
@property (nonatomic,strong) UILabel *placeholderLab;
@end

@implementation EnglishCodeView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = CodeBgColor;
        [self createViewComponent];
    }
    return self;
}

/**
 * 创建组件视图
 */
- (void)createViewComponent {
    
    self.backgroundColor = CMColorFromRGB(0x333649);
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 3.f;
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = CMColorFromRGB(0x8E92A3).CGColor;
    
    UITextView *textView = [[UITextView alloc] init];
    textView.keyboardType = UIKeyboardTypeEmailAddress;
    textView.delegate = self;
    textView.font = CMTextFont16;
    textView.textColor = CMColorFromRGB(0xFFFFFF);
    textView.backgroundColor = CMColorFromRGB(0x333649);
    textView.showsVerticalScrollIndicator = NO;
    [self addSubview:textView];
    self.textView = textView;
    
    UILabel *placeholderLab = [[UILabel alloc] init];
//    placeholderLab.text = @"请输入英文助记词，用空格隔开".localized;
    placeholderLab.font = CMTextFont15;
    placeholderLab.textColor = CMColorFromRGB(0x8E92A3);
    placeholderLab.textAlignment = NSTextAlignmentLeft;
    placeholderLab.numberOfLines = 0;
    [self addSubview:placeholderLab];
    self.placeholderLab = placeholderLab;
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(15);
        make.top.equalTo(self).with.offset(5);
        make.bottom.equalTo(self).with.offset(-5);
        make.right.equalTo(self).with.offset(-15);
    }];
    
    [self.placeholderLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(15);
        make.top.bottom.right.equalTo(self);
    }];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self.placeholderLab setHidden:YES];
}

- (void)textViewDidEndEditing:(UITextField *)textField {
    
    if (IS_BLANK(textField.text)) {
        [self.placeholderLab setHidden:NO];
    }
}

- (NSString *)getEnglishCode
{
    return self.textView.text;
}

- (void)setKeyBoardInputView:(UIView *)inputView action:(SEL)operation
{
    [self.textView setKeyBoardInputView:inputView action:operation];
}
@end
