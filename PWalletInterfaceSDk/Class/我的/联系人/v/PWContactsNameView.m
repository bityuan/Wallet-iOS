//
//  PWContactsNameView.m
//  PWallet
//  显示 昵称 手机号 的view
//  Created by 陈健 on 2018/11/14.
//  Copyright © 2018 陈健. All rights reserved.
//

#import "PWContactsNameView.h"
#import "NSString+CommonUseTool.h"

@interface PWContactsNameView()<UITextFieldDelegate>
/**昵称TextField*/
@property (nonatomic,weak) UITextField *nameTextField;
/**手机号TextField*/
@property (nonatomic,weak) UITextField *phoneNumTextField;
/**昵称错误*/
@property (weak, nonatomic) UILabel *nameErrorLabel;
/**手机号错误*/
@property (weak, nonatomic) UILabel *phoneNumErrorLabel;
@end

@implementation PWContactsNameView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initViews];
    }
    return self;
}

- (void)initViews {
    UIImageView *imageView = [[UIImageView alloc]init];
    imageView.image = [UIImage imageNamed:@"Rectangle7"];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:imageView];
    imageView.userInteractionEnabled = true;
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.left.right.equalTo(self);
    }];
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = SGColorFromRGB(0xECECEC);
    [imageView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0.5);
        make.left.right.equalTo(imageView);
        make.centerY.equalTo(imageView);
    }];
    
    UILabel *label1 = [[UILabel alloc]init];
    [imageView addSubview:label1];
    label1.text = @"昵称".localized;
    label1.font = [UIFont systemFontOfSize:15];
    label1.textColor = SGColorFromRGB(0x333649);
    [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(line).offset(-15);
        make.left.equalTo(imageView).offset(20);
    }];
    
    UITextField *nameTextField = [[UITextField alloc]init];
    [imageView addSubview:nameTextField];
    self.nameTextField = nameTextField;
    nameTextField.delegate = self;
    nameTextField.userInteractionEnabled = false;
    nameTextField.font = [UIFont systemFontOfSize:16];
    nameTextField.textColor = SGColorFromRGB(0x333649);
    nameTextField.textAlignment = NSTextAlignmentRight;
    nameTextField.placeholder = @"昵称需小于16字符".localized;
    [nameTextField addTarget:self action:@selector(textFiledEditChanged:) forControlEvents:UIControlEventEditingChanged];
    [nameTextField setValue:[UIFont systemFontOfSize:14] forKeyPath:@"placeholderLabel.font"];
    [nameTextField setValue:SGColorFromRGB(0x8e92a3) forKeyPath:@"placeholderLabel.textColor"];
    if ([LocalizableService getAPPLanguage] == LanguageJapanese) {
        [nameTextField setValue:[UIFont systemFontOfSize:12.f] forKeyPath:@"placeholderLabel.font"];
    }
    [nameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(label1);
        if ([LocalizableService getAPPLanguage] == LanguageJapanese)
        {
             make.left.equalTo(label1.mas_right);
        }
        else
        {
             make.left.equalTo(label1.mas_right).offset(20);
        }
       
        make.right.equalTo(imageView).offset(-20);
        
    }];
    
   
    //展示错误的label
    UILabel *nameErrorLabel = [[UILabel alloc]init];
    [self addSubview:nameErrorLabel];
    self.nameErrorLabel = nameErrorLabel;
    nameErrorLabel.font = [UIFont systemFontOfSize:10];
    nameErrorLabel.textColor = SGColorRGBA(234, 37, 81, 1);
    [nameErrorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(line);
        make.right.equalTo(nameTextField);
    }];
    
    UILabel *label2 = [[UILabel alloc]init];
    [imageView addSubview:label2];
    label2.text = @"手机号".localized;
    label2.font = [UIFont systemFontOfSize:15];
    label2.textColor = SGColorFromRGB(0x333649);
    [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(line).offset(15);
        make.left.equalTo(label1);
    }];
    
    UITextField *phoneNumTextField = [[UITextField alloc]init];
    [imageView addSubview:phoneNumTextField];
    self.phoneNumTextField = phoneNumTextField;
    phoneNumTextField.delegate = self;
    phoneNumTextField.userInteractionEnabled = false;
    phoneNumTextField.textAlignment = NSTextAlignmentRight;
    phoneNumTextField.font = [UIFont systemFontOfSize:16];
    phoneNumTextField.textColor = SGColorFromRGB(0x333649);
    phoneNumTextField.placeholder = @"请输入11位手机号".localized;
    [phoneNumTextField setValue:[UIFont systemFontOfSize:14] forKeyPath:@"placeholderLabel.font"];
    [phoneNumTextField setValue:SGColorFromRGB(0x8e92a3) forKeyPath:@"placeholderLabel.textColor"];
    if ([LocalizableService getAPPLanguage] == LanguageJapanese) {
        [phoneNumTextField setValue:[UIFont systemFontOfSize:12] forKeyPath:@"placeholderLabel.font"];
    }
    [phoneNumTextField addTarget:self action:@selector(textFiledEditChanged:) forControlEvents:UIControlEventEditingChanged];
    phoneNumTextField.keyboardType = UIKeyboardTypeNumberPad;
    [phoneNumTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(label2);
        make.left.right.equalTo(nameTextField);
    }];
    
    //展示错误的label
    UILabel *phoneNumErrorLabel = [[UILabel alloc]init];
    [self addSubview:phoneNumErrorLabel];
    self.phoneNumErrorLabel = phoneNumErrorLabel;
    phoneNumErrorLabel.font = [UIFont systemFontOfSize:10];
    phoneNumErrorLabel.textColor = SGColorRGBA(234, 37, 81, 1);
    [phoneNumErrorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(imageView).offset(-5);
        make.right.equalTo(phoneNumTextField);
    }];

}

- (void)setName:(NSString *)name {
    _name = name;
    self.nameTextField.text = name;
}

- (void)setPhoneNumber:(NSString *)phoneNumber {
    _phoneNumber = phoneNumber;
    self.phoneNumTextField.text = phoneNumber;
}

- (void)setCanEdit:(BOOL)canEdit {
    _canEdit = canEdit;
    self.nameTextField.userInteractionEnabled = canEdit;
    self.phoneNumTextField.userInteractionEnabled = canEdit;
}

#pragma mark- 限制textField输入16个字符或11个数字
-(void)textFiledEditChanged:(UITextField *)textField{
    textField.textColor = SGColorFromRGB(0x333649);
    
    if (textField == self.nameTextField) {
        self.nameErrorLabel.text = @"";
        if (textField.text.length >= 16) {
            textField.text = [textField.text substringToIndex:16];
        }
    }
    if (textField == self.phoneNumTextField) {
        self.phoneNumErrorLabel.text = @"";
        if (textField.text.length >= 11) {
            textField.text = [textField.text substringToIndex:11];
        }
    }
}

#pragma mark- textFaild 代理方法

-(void)textFieldDidEndEditing:(UITextField *)textField {
    NSString *str = textField.text;
    PWEditContactsItem item = (textField == self.nameTextField ? PWEditContactsItemNickname : PWEditContactsItemPhoneNumber);
    if ((textField == self.nameTextField) && (textField.text.length == 0)) {
        //昵称不合法
        self.nameErrorLabel.text = @"昵称不能为空".localized;
        str = nil;
    }
    if (textField == self.phoneNumTextField) {
        //手机号不合法
        if ([str isEqualToString:@""]) {
            self.phoneNumErrorLabel.text = @"请输入正确的手机号".localized;
            self.phoneNumTextField.textColor = [UIColor redColor];
            str = nil;
            return;
        }
    }
    //回调
    if (self.completionBlock) {
        self.completionBlock(item,str);
    }
}

@end
