//
//  PWAddContactsNicknameCell.m
//  PWallet
//  添加联系人 昵称 和 手机号 cell
//  Created by 陈健 on 2018/5/30.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import "PWAddContactsTopCell.h"
#import "NSString+CommonUseTool.h"

@interface PWAddContactsTopCell()<UITextFieldDelegate>
@property (weak, nonatomic) UILabel *nameLabel;
@property (weak, nonatomic) UILabel *errorLabel;
@property (weak, nonatomic) UITextField *infoTextField;
@end

@implementation PWAddContactsTopCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initViews];
        return self;
    }
    return nil;
}

- (void)setInforText:(NSString *)inforText {
    if (inforText) {
        _inforText = inforText;
        self.infoTextField.text = inforText;
    }
}


- (void)setKeyBoardInputView:(UIView *)inputView action:(SEL)operation {
    [self.infoTextField setKeyBoardInputView:inputView action:operation];
}

//初始化views
- (void)initViews {
    UILabel *nameLabel = [[UILabel alloc]init];
    [self.contentView addSubview:nameLabel];
    self.nameLabel = nameLabel;
    nameLabel.font = [UIFont systemFontOfSize:14];
    nameLabel.textColor = TextColor51;
    
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(11);
        make.left.equalTo(self.contentView).offset(14);
    }];
    
    UITextField *infoTextField = [[UITextField alloc]init];
    [self.contentView addSubview:infoTextField];
    self.infoTextField = infoTextField;
    infoTextField.delegate = self;
    infoTextField.textColor = TextColor51;
    infoTextField.font = [UIFont systemFontOfSize:16];
    [infoTextField addTarget:self action:@selector(textFiledEditChanged:) forControlEvents:UIControlEventEditingChanged];
    
    [infoTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(20);
        make.width.equalTo(self.contentView);
        make.leading.equalTo(nameLabel);
        make.top.equalTo(nameLabel.mas_bottom).offset(7);
    }];
    
    //展示错误的label
    UILabel *errorLabel = [[UILabel alloc]init];
    [self.contentView addSubview:errorLabel];
    self.errorLabel = errorLabel;
    errorLabel.font = [UIFont systemFontOfSize:13];
    errorLabel.textColor = [UIColor redColor];
    
    [errorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(infoTextField);
        make.right.equalTo(self.contentView).offset(-14);
    }];
}

- (void)setStyle:(PWAddContactsTopCellStyle)style {
    _style = style;
    NSString *holderText = @"";
    switch (style) {
        case PWAddContactsTopCellStyleNickname:
            self.nameLabel.text = @"昵称".localized;
            holderText = @"昵称需小于16字符".localized;
            break;
        case PWAddContactsTopCellStylePhoneNumber:
            self.nameLabel.text = @"手机号".localized;
            holderText = @"请输入11位手机号".localized;
            self.infoTextField.keyboardType = UIKeyboardTypeNumberPad;
            break;
        default:
            break;
    }
    NSMutableAttributedString *placeholder = [[NSMutableAttributedString alloc] initWithString:holderText];
    [placeholder addAttribute:NSFontAttributeName
                        value:[UIFont systemFontOfSize:14]
                        range:NSMakeRange(0, holderText.length)];
    self.infoTextField.attributedPlaceholder = placeholder;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}

#pragma mark- 限制textField输入16个字符或11个数字
-(void)textFiledEditChanged:(UITextField *)textField{
    self.errorLabel.text = @"";
    self.infoTextField.textColor = TextColor51;
    if (self.style == PWAddContactsTopCellStyleNickname) {
        if (textField.text.length >= 16) {
            textField.text = [textField.text substringToIndex:16];
        }
    }
    if (self.style == PWAddContactsTopCellStylePhoneNumber) {
        if (textField.text.length >= 11) {
            textField.text = [textField.text substringToIndex:11];
        }
    }
}


#pragma mark- textFaild 代理方法

-(void)textFieldDidEndEditing:(UITextField *)textField {
    NSString *str = textField.text;
    if ((self.style == PWAddContactsTopCellStyleNickname) && ([NSString isBlankString:textField.text])) {
        //昵称不合法
        self.errorLabel.text = @"昵称不能为空".localized;
        str = nil;
    }
    if ((self.style == PWAddContactsTopCellStylePhoneNumber) && (![str isPhoneNumber])) {
        //手机号不合法
        if (![str isEqual: @""]) {
            self.errorLabel.text = @"请输入正确的手机号".localized;
            self.infoTextField.textColor = [UIColor redColor];
            str = nil;
        }
    }
    //回调
    if (self.completionBlock) {
        self.completionBlock(str);
    }
}








@end
