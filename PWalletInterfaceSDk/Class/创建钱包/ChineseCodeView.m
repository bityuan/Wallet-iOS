//
//  ChineseCodeView.m
//  PWallet
//
//  Created by 宋刚 on 2018/5/23.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import "ChineseCodeView.h"
//#import "UITextField+Delete.h"
@interface ChineseCodeView()<UITextFieldDelegate>
/**提示 请输入中文助记词*/
@property (nonatomic,strong) UILabel *placeholderLab;
/** 输入框 */
@property (nonatomic,strong) UITextField *rememberCodeText1;
@property (nonatomic,strong) UITextField *rememberCodeText2;
@property (nonatomic,strong) UITextField *rememberCodeText3;
@property (nonatomic,strong) UITextField *rememberCodeText4;
@property (nonatomic,strong) UITextField *rememberCodeText5;
/** 下划线 */
@property (nonatomic, strong) UIView *bottomLine1;
@property (nonatomic, strong) UIView *bottomLine2;
@property (nonatomic, strong) UIView *bottomLine3;
@property (nonatomic, strong) UIView *bottomLine4;
@property (nonatomic, strong) UIView *bottomLine5;

@end
@implementation ChineseCodeView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self createViewComponent];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledEditChanged:) name:UITextFieldTextDidChangeNotification object:self.rememberCodeText1];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledEditChanged:) name:UITextFieldTextDidChangeNotification object:self.rememberCodeText2];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledEditChanged:) name:UITextFieldTextDidChangeNotification object:self.rememberCodeText3];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledEditChanged:) name:UITextFieldTextDidChangeNotification object:self.rememberCodeText4];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledEditChanged:) name:UITextFieldTextDidChangeNotification object:self.rememberCodeText5];
        
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]  removeObserver:self];
}
/**
 * 创建组件视图
 */
- (void)createViewComponent{
    
    self.backgroundColor = CMColorFromRGB(0x333649);

    self.clipsToBounds = YES;
    self.layer.cornerRadius = 3.f;
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = CMColorFromRGB(0x8E92A3).CGColor;
    
    for (int i = 0; i < 5; i ++) {
        
        UITextField *rememberCodeText = [[UITextField alloc] init];
        rememberCodeText.textColor = CMColorFromRGB(0xFFFFFF);
        rememberCodeText.font = [UIFont systemFontOfSize:17];//CMTextFont17;
        rememberCodeText.delegate = self;
        rememberCodeText.textAlignment = NSTextAlignmentLeft;
        rememberCodeText.tag = i + 1;
        [self addSubview:rememberCodeText];
        
        UIView *bottomLine = [UIView new];
        bottomLine.backgroundColor = CMColorFromRGB(0xFFFFFF);
        [self addSubview:bottomLine];
        CGFloat font = 17;
        
        if (i == 0) {
            self.rememberCodeText1 = rememberCodeText;
            rememberCodeText.placeholder = @"请输入".localized;
            [rememberCodeText setValue:[UIFont systemFontOfSize:font] forKeyPath:@"placeholderLabel.font"];
            [rememberCodeText setValue:CMColorFromRGB(0x8E92A3) forKeyPath:@"placeholderLabel.textColor"];
            self.bottomLine1 = bottomLine;
        }
        else if (i == 1){
            self.rememberCodeText2 = rememberCodeText;
            rememberCodeText.placeholder = @"助记词".localized;
            [rememberCodeText setValue:[UIFont systemFontOfSize:font] forKeyPath:@"placeholderLabel.font"];
            [rememberCodeText setValue:CMColorFromRGB(0x8E92A3) forKeyPath:@"placeholderLabel.textColor"];
            self.bottomLine2 = bottomLine;
        }
        else if (i == 2){
            self.rememberCodeText3 = rememberCodeText;
            self.bottomLine3 = bottomLine;
        }
        else if (i == 3){
            self.rememberCodeText4 = rememberCodeText;
            self.bottomLine4 = bottomLine;
        }
        else if (i == 4){
            self.rememberCodeText5 = rememberCodeText;
            self.bottomLine5 = bottomLine;
        }
    }
  
}

/**
 * 布局
 */
- (void)layoutSubviews {
    
    CGFloat margin = 8;
    CGFloat textWidth = ((kScreenWidth - 30) - 6 * margin)/5;
 
    [self.rememberCodeText1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(textWidth);
        make.height.mas_equalTo(25);
        make.left.equalTo(self).with.offset(margin);
        make.centerY.equalTo(self);
    }];
    [self.bottomLine1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(textWidth);
        make.height.mas_equalTo(2);
        make.left.mas_equalTo(self.rememberCodeText1.mas_left);
        make.top.equalTo(self.rememberCodeText1.mas_bottom).offset(0);
    }];
    
    [self.rememberCodeText2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(textWidth);
        make.height.mas_equalTo(25);
        make.left.equalTo(self.rememberCodeText1.mas_right).with.offset(margin);
        make.centerY.equalTo(self);
    }];
    [self.bottomLine2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(textWidth);
        make.height.mas_equalTo(2);
        make.left.mas_equalTo(self.rememberCodeText2.mas_left);
        make.top.equalTo(self.rememberCodeText2.mas_bottom).offset(0);
    }];
    
    [self.rememberCodeText3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(textWidth);
        make.height.mas_equalTo(25);
        make.left.equalTo(self.rememberCodeText2.mas_right).with.offset(margin);
        make.centerY.equalTo(self);
    }];
    [self.bottomLine3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(textWidth);
        make.height.mas_equalTo(2);
        make.left.mas_equalTo(self.rememberCodeText3.mas_left);
        make.top.equalTo(self.rememberCodeText3.mas_bottom).offset(0);
    }];
    
    [self.rememberCodeText4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(textWidth);
        make.height.mas_equalTo(25);
        make.left.equalTo(self.rememberCodeText3.mas_right).with.offset(margin);
        make.centerY.equalTo(self);
    }];
    [self.bottomLine4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(textWidth);
        make.height.mas_equalTo(2);
        make.left.mas_equalTo(self.rememberCodeText4.mas_left);
        make.top.equalTo(self.rememberCodeText4.mas_bottom).offset(0);
    }];
    
    [self.rememberCodeText5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(textWidth);
        make.height.mas_equalTo(25);
        make.left.equalTo(self.rememberCodeText4.mas_right).with.offset(margin);
        make.centerY.equalTo(self);
    }];
    [self.bottomLine5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(textWidth);
        make.height.mas_equalTo(2);
        make.left.mas_equalTo(self.rememberCodeText5.mas_left);
        make.top.equalTo(self.rememberCodeText5.mas_bottom).offset(0);
    }];
    

}

#pragma mark - UITextField Delegate
/*
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([textField.text isEqualToString:@""] && [string isEqualToString:@""]) {
        //前移
        NSUInteger tag = textField.tag;
        if (tag > 1) {
            UITextField * beforeTextField = [self viewWithTag:tag - 1];
            [textField resignFirstResponder];
            [beforeTextField becomeFirstResponder];
        }
    }
    return YES;
}
*/

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.placeholderLab.hidden = true;
    UIColor *hightLineColor = CMColorFromRGB(0x7190ff);

    if (textField.tag == 1) {
        self.bottomLine1.backgroundColor = hightLineColor;
    }
    else if (textField.tag == 2) {
        self.bottomLine2.backgroundColor = hightLineColor;
    }
    else if (textField.tag == 3) {
        self.bottomLine3.backgroundColor = hightLineColor;
    }
    else if (textField.tag == 4) {
        self.bottomLine4.backgroundColor = hightLineColor;
    }
    else if (textField.tag == 5) {
        self.bottomLine5.backgroundColor = hightLineColor;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (IS_BLANK(self.rememberCodeText1.text) &&
        IS_BLANK(self.rememberCodeText2.text) &&
        IS_BLANK(self.rememberCodeText3.text) &&
        IS_BLANK(self.rememberCodeText4.text) &&
        IS_BLANK(self.rememberCodeText5.text)) {
        self.placeholderLab.hidden = false;
    }
    UIColor *backColor = CMColorFromRGB(0x333649);

    if (textField.tag == 1) {
        if (textField.text.length == 3) {
            self.bottomLine1.backgroundColor = backColor;
        } else {
            self.bottomLine1.backgroundColor = CMColorFromRGB(0xEBEDF8);
        }
    }
    else if (textField.tag == 2) {
        if (textField.text.length == 3) {
            self.bottomLine2.backgroundColor = backColor;
        } else {
            self.bottomLine2.backgroundColor = CMColorFromRGB(0xEBEDF8);
        }
    }
    else if (textField.tag == 3) {
        if (textField.text.length == 3) {
            self.bottomLine3.backgroundColor = backColor;
        } else {
            self.bottomLine3.backgroundColor = CMColorFromRGB(0xEBEDF8);
        }
    }
    else if (textField.tag == 4) {
        if (textField.text.length == 3) {
            self.bottomLine4.backgroundColor = backColor;
        } else {
            self.bottomLine4.backgroundColor = CMColorFromRGB(0xEBEDF8);
        }
    }
    else if (textField.tag == 5) {
        if (textField.text.length == 3) {
            self.bottomLine5.backgroundColor = backColor;
        } else {
            self.bottomLine5.backgroundColor = CMColorFromRGB(0xEBEDF8);
        }
    }
}

- (NSString *)rememberStr
{
    NSString *text1 = self.rememberCodeText1.text;
    NSString *text2 = self.rememberCodeText2.text;
    NSString *text3 = self.rememberCodeText3.text;
    NSString *text4 = self.rememberCodeText4.text;
    NSString *text5 = self.rememberCodeText5.text;
    return [NSString stringWithFormat:@"%@%@%@%@%@",text1,text2,text3,text4,text5];
}

/**
 *  键盘缩回
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField;{
    [textField resignFirstResponder];
    return YES;
}



/**
 *  键盘缩回
 */
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self resignAllText];
}

/**
 * textfield值变化的对应操作
 */
- (void)textFiledEditChanged:(id)notification{
    NSNotification *noti = (NSNotification *)notification;
    UITextField *textField = (UITextField *)noti.object;
    UITextRange *selectedRange = textField.markedTextRange;
    UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
    
    //显示或隐藏提示文字
    
    if (!position) { //// 没有高亮选择的字
        //过滤非汉字字符
        textField.text = [self filterCharactor:textField.text withRegex:@"[^\u4e00-\u9fa5]"];
        
        if (textField.text.length >= 3) {
            textField.text = [textField.text substringToIndex:3];
            if(textField == self.rememberCodeText1)
            {
                [self.rememberCodeText2 becomeFirstResponder];
            }else if(textField == self.rememberCodeText2)
            {
                [self.rememberCodeText3 becomeFirstResponder];
            }else if(textField == self.rememberCodeText3)
            {
                [self.rememberCodeText4 becomeFirstResponder];
            }else if(textField == self.rememberCodeText4)
            {
                [self.rememberCodeText5 becomeFirstResponder];
            }else if(textField == self.rememberCodeText5)
            {
                
            }
        } else if (textField.text.length <= 0) {

        }
    }else { //有高亮文字
        
    }
}

- (void)textFieldDidDeleteBackward:(UITextField *)textField {
    if (textField.text.length == 0) {
        if(textField == self.rememberCodeText5) {
            [self.rememberCodeText4 becomeFirstResponder];
        }
        else if(textField == self.rememberCodeText4) {
            [self.rememberCodeText3 becomeFirstResponder];
        }
        else if(textField == self.rememberCodeText3) {
            [self.rememberCodeText2 becomeFirstResponder];
        }
        else if(textField == self.rememberCodeText2) {
            [self.rememberCodeText1 becomeFirstResponder];
        }
    }
}

/**
 * 根据正则，过滤特殊字符
 */
- (NSString *)filterCharactor:(NSString *)string withRegex:(NSString *)regexStr{
    NSString *searchText = string;
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexStr options:NSRegularExpressionCaseInsensitive error:&error];
    NSString *result = [regex stringByReplacingMatchesInString:searchText options:NSMatchingReportCompletion range:NSMakeRange(0, searchText.length) withTemplate:@""];
    return result;
}

/**
 * 释放所有的Text
 */
- (void)resignAllText
{
    [self.rememberCodeText1 resignFirstResponder];
    [self.rememberCodeText2 resignFirstResponder];
    [self.rememberCodeText3 resignFirstResponder];
    [self.rememberCodeText4 resignFirstResponder];
    [self.rememberCodeText5 resignFirstResponder];
}

- (NSString *)getChineseCode
{
    NSString *codeStr = [NSString stringWithFormat:@"%@%@%@%@%@",self.rememberCodeText1.text,self.rememberCodeText2.text,self.rememberCodeText3.text,self.rememberCodeText4.text,self.rememberCodeText5.text];
    NSMutableString *str = [NSMutableString new];
    for (int i = 0; i < codeStr.length; i ++) {
        [str appendString:[codeStr substringWithRange:NSMakeRange(i, 1)]];
        if (i != codeStr.length - 1) {
            [str appendString:@" "];
        }
    }
    return str;
}

- (void)setKeyBoardInputView:(UIView *)inputView action:(SEL)operation
{
    [self.rememberCodeText1 setKeyBoardInputView:inputView action:operation];
    [self.rememberCodeText2 setKeyBoardInputView:inputView action:operation];
    [self.rememberCodeText3 setKeyBoardInputView:inputView action:operation];
    [self.rememberCodeText4 setKeyBoardInputView:inputView action:operation];
    [self.rememberCodeText5 setKeyBoardInputView:inputView action:operation];
}
@end
