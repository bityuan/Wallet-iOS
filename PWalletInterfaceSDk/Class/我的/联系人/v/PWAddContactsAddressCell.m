//
//  PWAddContactsAddressCell.m
//  PWallet
//  添加联系人 地址cell
//  Created by 陈健 on 2018/5/30.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import "PWAddContactsAddressCell.h"
#import "UITextView+ZWPlaceHolder.h"
@interface PWAddContactsAddressCell()<UITextViewDelegate>
@property (nonatomic,weak) UITextView *addressTextView;

@end


@implementation PWAddContactsAddressCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self initViews];
        return self;
    }
    return nil;
}

- (void)setKeyBoardInputView:(UIView *)inputView action:(SEL)operation {
    [self.addressTextView setKeyBoardInputView:inputView action:operation];
}

- (void)setAddressText:(NSString *)addressText {
    if (addressText) {
        _addressText = addressText;
        self.addressTextView.text = addressText;
        [self contentSizeToFit];
    }
}

- (void)setCoinNameText:(NSString *)coinNameText {
    if (coinNameText) {
        _coinNameText = coinNameText;
        [self.nameBtn setTitle:coinNameText forState:UIControlStateNormal];
    }
}

- (void)initViews {
    
    UIImageView *imageView = [[UIImageView alloc]init];
    imageView.image = [UIImage imageNamed:@"Mask"];
    imageView.userInteractionEnabled = true;
    imageView.layer.borderWidth = 1;
    imageView.layer.borderColor = [UIColor clearColor].CGColor;
    imageView.layer.cornerRadius = 6;
    [self.contentView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView);
        make.centerX.equalTo(self.contentView);
    }];
    
    //主链btn
    UIButton *nameBtn = [[UIButton alloc]init];
    [imageView addSubview:nameBtn];
    [nameBtn setTitle:@"主链".localized forState:UIControlStateNormal];
    nameBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [nameBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nameBtn setBackgroundColor:SGColorFromRGB(0x7190FF)];
    [nameBtn addTarget:self action:@selector(nameBtnPress:) forControlEvents:UIControlEventTouchUpInside];
    nameBtn.layer.cornerRadius = 3;
    nameBtn.layer.masksToBounds = true;
    self.nameBtn = nameBtn;
    [nameBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(nameBtn.titleLabel.textWidth+20);
        make.height.mas_equalTo(26);
        make.top.equalTo(imageView).offset(26);
        make.left.equalTo(imageView).offset(20);
    }];

    //删除button
    UIButton *deleteBtn = [[UIButton alloc]init];
    [imageView addSubview:deleteBtn];
    [deleteBtn setImage:[UIImage imageNamed:@"删除"] forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(deleteBtnPress:) forControlEvents:UIControlEventTouchUpInside];

    [deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.with.mas_equalTo(26);
        make.centerY.equalTo(nameBtn);
        make.right.equalTo(imageView).offset(-20);
    }];

    //扫描button
    UIButton *scanBtn = [[UIButton alloc]init];
    [imageView addSubview:scanBtn];
    [scanBtn setImage:[UIImage imageNamed:@"扫描"] forState:UIControlStateNormal];
    [scanBtn addTarget:self action:@selector(scanBtnPress:) forControlEvents:UIControlEventTouchUpInside];
    [scanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.with.equalTo(deleteBtn);
        make.centerY.equalTo(deleteBtn);
        make.right.equalTo(deleteBtn.mas_left).offset(-20);
    }];


    //地址textView
    UITextView *addressTextView = [[UITextView alloc]init];
    self.addressTextView = addressTextView;
    [imageView addSubview:addressTextView];
    addressTextView.font = [UIFont systemFontOfSize:14];
    addressTextView.textColor = SGColorFromRGB(0x333649);
    addressTextView.delegate = self;
    addressTextView.textAlignment = NSTextAlignmentLeft;
    addressTextView.placeholder = @"扫描二维码或输入地址".localized;
    addressTextView.backgroundColor = UIColor.clearColor;
    addressTextView.keyboardType = UIKeyboardTypeEmailAddress;
    [addressTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(nameBtn.mas_left);
        make.right.equalTo(deleteBtn.mas_right);
        make.top.equalTo(nameBtn.mas_bottom);
        make.bottom.equalTo(imageView).offset(-6);
    }];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self contentSizeToFit];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark: button点击事件
//左边主链button点击
- (void)nameBtnPress:(UIButton*)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(addContactsAddressCell:nameButtonPress:)]) {
        [self.delegate addContactsAddressCell:self nameButtonPress:sender];
    }
}

//扫描button点击
- (void)scanBtnPress:(UIButton*)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(addContactsAddressCell:scanBtnPress:)]) {
        [self.delegate addContactsAddressCell:self scanBtnPress:sender];
    }
}

//删除按钮点击
- (void)deleteBtnPress:(UIButton*)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(addContactsAddressCell:deleteBtnPress:)]) {
        [self.delegate addContactsAddressCell:self deleteBtnPress:sender];
    }
}

#pragma mark UITextView 代理方法
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return false;
    }
    return true;
}
-(void)textViewDidChange:(UITextView *)textView {
    [self contentSizeToFit];
}
- (void)textViewDidEndEditing:(UITextView *)textView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(addContactsAddressCell:addressTextViewDidEndEditing:)]) {
        [self.delegate addContactsAddressCell:self addressTextViewDidEndEditing:textView];
    }
}

//保持textView文字居中
- (void)contentSizeToFit {
    //textView的contentSize属性
    CGSize contentSize = self.addressTextView.contentSize;
    //textView的内边距属性
    UIEdgeInsets offset;

    //如果文字内容高度没有超过textView的高度
    if(contentSize.height <= self.addressTextView.frame.size.height)
    {
        //textView的高度减去文字高度除以2就是Y方向的偏移量，也就是textView的上内边距
        CGFloat offsetY = (self.addressTextView.frame.size.height - contentSize.height) / 2;
        offset = UIEdgeInsetsMake(offsetY, 0, 0, 0);
        [self.addressTextView setContentInset:offset];
    }
    else {
        offset = UIEdgeInsetsMake(0, 0, 0, 0);
        [self.addressTextView setContentInset:offset];
        CGSize newContensize = CGSizeMake(contentSize.width, self.addressTextView.frame.size.height);
        [self.addressTextView setContentSize: newContensize];
    }
}
@end
