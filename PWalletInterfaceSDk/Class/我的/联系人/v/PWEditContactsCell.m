//
//  PWEditContactsCell.m
//  PWallet
//  添加联系人 cell
//  Created by 陈健 on 2018/5/31.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import "PWEditContactsCell.h"
#import "NSString+CommonUseTool.h"

@interface PWEditContactsCell()<UITextFieldDelegate>
@property (weak, nonatomic) UILabel *nameLabel;
@property (weak, nonatomic) UILabel *errorLabel;
@end

@implementation PWEditContactsCell

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

//初始化views
- (void)initViews {
    UILabel *nameLabel = [[UILabel alloc]init];
    [self.contentView addSubview:nameLabel];
    self.nameLabel = nameLabel;
    nameLabel.font = [UIFont systemFontOfSize:15];
    nameLabel.textColor = TextColor51;
    
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(50);
        make.top.equalTo(self.contentView).offset(15);
        make.left.equalTo(self.contentView).offset(18);
    }];
    
    UITextField *infoTextField = [[UITextField alloc]init];
    [self.contentView addSubview:infoTextField];
    self.infoTextField = infoTextField;
    infoTextField.delegate = self;
    infoTextField.textColor = TextColor51;
    infoTextField.font = [UIFont systemFontOfSize:15];
    [infoTextField addTarget:self action:@selector(textFiledEditChanged:) forControlEvents:UIControlEventEditingChanged];
    
    [infoTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nameLabel);
        make.left.equalTo(nameLabel.mas_right).offset(10);
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

- (void)setStyle:(PWEditContactsCellStyle)style {
    _style = style;
    switch (style) {
        case PWEditContactsCellStyleNickname:
            self.nameLabel.text = @"昵称".localized;
            self.infoTextField.placeholder = @"昵称需小于16字符".localized;
            break;
        case PWEditContactsCellStylePhoneNumber:
            self.nameLabel.text = @"手机号".localized;
            self.infoTextField.placeholder = @"请输入11位手机号".localized;
            self.infoTextField.keyboardType = UIKeyboardTypeNumberPad;
            break;
        default:
            break;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}

#pragma mark- 限制textField输入16个字符或11个数字
-(void)textFiledEditChanged:(UITextField *)textField{
    self.errorLabel.text = @"";
    textField.textColor = TextColor51;
    if (self.style == PWEditContactsCellStyleNickname) {
        if (textField.text.length >= 16) {
            textField.text = [textField.text substringToIndex:16];
        }
    }
    if (self.style == PWEditContactsCellStylePhoneNumber) {
        if (textField.text.length >= 11) {
            textField.text = [textField.text substringToIndex:11];
        }
    }
}


#pragma mark- textFaild 代理方法

-(void)textFieldDidEndEditing:(UITextField *)textField {
    NSString *str = textField.text;
    if ((self.style == PWEditContactsCellStyleNickname) && (textField.text.length == 0)) {
        //昵称不合法
        self.errorLabel.text = @"昵称不能为空".localized;
        str = nil;
    }
    if ((self.style == PWEditContactsCellStylePhoneNumber) && (![str isPhoneNumber])) {
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
