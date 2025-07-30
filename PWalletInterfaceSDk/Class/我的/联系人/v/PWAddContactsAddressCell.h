//
//  PWAddContactsAddressCell.h
//  PWallet
//  添加联系人 地址cell
//  Created by 陈健 on 2018/5/30.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PWAddContactsAddressCell;

@protocol PWAddContactsAddressCellDelegate <NSObject>
//主链(虚拟币名字)点击代理
-(void)addContactsAddressCell:(PWAddContactsAddressCell*)cell nameButtonPress:(UIButton *)button;
//删除按钮点击代理
-(void)addContactsAddressCell:(PWAddContactsAddressCell*)cell deleteBtnPress:(UIButton *)button;
//扫描按钮点击代理
-(void)addContactsAddressCell:(PWAddContactsAddressCell*)cell scanBtnPress:(UIButton *)button;
//地址textView完成编辑
-(void)addContactsAddressCell:(PWAddContactsAddressCell*)cell addressTextViewDidEndEditing:(UITextView *)textView;
@end


@interface PWAddContactsAddressCell : UITableViewCell
@property(nonatomic,weak) id<PWAddContactsAddressCellDelegate> delegate;
/*地址**/
@property (nonatomic,copy) NSString *addressText;
/*主链(虚拟币名字)**/
@property (nonatomic,copy) NSString *coinNameText;

/*主链(虚拟币名字)button**/
@property (nonatomic,weak) UIButton *nameBtn;

/**UITextView 用于将按钮添加到键盘上*/
- (void)setKeyBoardInputView:(UIView *)inputView action:(SEL)operation;

@end
