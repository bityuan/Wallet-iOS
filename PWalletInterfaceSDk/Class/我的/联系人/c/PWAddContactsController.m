//
//  PWAddContactsController.m
//  PWallet
//  添加联系人 
//  Created by 陈健 on 2018/5/30.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import "PWAddContactsController.h"
#import "PWAddContactsTopCell.h"
#import "PWAddContactsAddressCell.h"
#import "PWPickerViewController.h"
#import "ScanViewController.h"
#import "PWContacts.h"
#import "PWContactsTool.h"
#import "NSString+CommonUseTool.h"
#import "ContactCoinViewController.h"
#import "PWContactsNameView.h"

@interface PWAddContactsController ()<UITableViewDelegate,UITableViewDataSource,PWAddContactsAddressCellDelegate>
//tableView
@property(nonatomic,weak) UITableView *tableView;
//保存按钮
@property(nonatomic,weak) UIButton *saveBtn;
//昵称
@property(nonatomic,strong)NSString *nickName;
//手机号
@property(nonatomic,strong)NSString *phoneNumber;
//虚拟币数组
@property(nonatomic,strong)NSMutableArray<PWContactsCoin*> *coinArray;

@end

@implementation PWAddContactsController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.showMaskLine = false;
    self.statusBarStyle = UIStatusBarStyleLightContent;
    self.view.backgroundColor = SGColorFromRGB(0xFCFCFF);
    if (@available(iOS 15, *))
    {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        appearance.backgroundColor = SGColorFromRGB(0x333649);

        appearance.backgroundEffect = nil;
        appearance.shadowColor = UIColor.clearColor;
        appearance.titleTextAttributes = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:18], NSForegroundColorAttributeName : [UIColor whiteColor]};
        self.navigationController.navigationBar.standardAppearance = appearance;
        self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
    }
    else
    {
        self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:18], NSForegroundColorAttributeName : [UIColor whiteColor]};
        [self.navigationController.navigationBar setBackgroundImage:[CommonFunction createImageWithColor:SGColorFromRGB(0x333649)] forBarMetrics:UIBarMetricsDefault];

         
    }
    self.navigationItem.title = @"添加联系人".localized;
    
    //顶部右侧"保存"按钮
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0,20, 40, 40)];
    [btn addTarget:self action:@selector(saveButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"保存".localized forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = rightItem;
    self.saveBtn = btn;
    [self setSaveButtonState];
    
    self.phoneNumber = @"";
    
    [self initViews];
    [self initValue];
    //  添加观察者，监听键盘收起
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardDidHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)keyBoardDidHide:(NSNotification*)notification {
    [self setSaveButtonState];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initValue{
    if (_coinType != nil && _address != nil) {
        if (!self.coinArray) {
            self.coinArray = [NSMutableArray array];
        }
        [self.coinArray addObject:[[PWContactsCoin alloc]init]];
        self.coinArray[0].coinName = _coinType;
        self.coinArray[0].coinAddress = _address;
        self.coinArray[0].optional_name = _optional_name;
        self.coinArray[0].coinPlatform = _coinPlatform;
        [self setSaveButtonState];
    }
}


#pragma mark - 初始化视图
- (void)initViews {
    UIImageView *blackView = [[UIImageView alloc]init];
    blackView.backgroundColor = SGColorFromRGB(0x333649);

    [self.view addSubview:blackView];
    [blackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.mas_equalTo(70);
    }];
    
    PWContactsNameView *namePhoneView = [[PWContactsNameView alloc]init];
    [self.view addSubview:namePhoneView];
    namePhoneView.canEdit = true;
    __weak typeof(self) weakSelf = self;
    //昵称 手机号 设置回调
    namePhoneView.completionBlock = ^(PWEditContactsItem item, NSString * _Nullable str) {
        if (item == PWEditContactsItemNickname) {
            weakSelf.nickName = str;
            [weakSelf setSaveButtonState];
        } else {
            weakSelf.phoneNumber = str;
            [weakSelf setSaveButtonState];
        }
    };
    
    [namePhoneView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(15);
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(110);
    }];
    
    //添加地址
    UIView *addAddress = [self addAddressButton];
    [self.view addSubview:addAddress];
    [addAddress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(44));
        make.bottom.equalTo(self.view).offset(-30 - kIphoneXBottomOffset);
    }];
    
    //UITableView
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    tableView.showsVerticalScrollIndicator = false;
    tableView.backgroundColor = SGColorFromRGB(0xFCFCFF);
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.showsVerticalScrollIndicator = false;
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(namePhoneView.mas_bottom);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(addAddress.mas_top).offset(-10);
    }];
    
}

#pragma mark - 保存按钮点击
- (void)saveButtonPress:(UIButton*)sender {
    [self.view endEditing:true];
    [self setSaveButtonState];
    if (!self.saveBtn.userInteractionEnabled) {
        return;
    }
    
    PWContacts *contacts = [[PWContacts alloc]init];
    contacts.nickName = self.nickName;
    contacts.phoneNumber = self.phoneNumber;
    contacts.coinArray = self.coinArray;
    
    //保存
    [[PWContactsTool shared] saveContacts:contacts];

    [self.navigationController popViewControllerAnimated:true];

    
}



//设置"保存"按钮是否可以点击
- (void)setSaveButtonState {
    if ((self.nickName == nil) || (self.phoneNumber == nil)) {
        self.saveBtn.userInteractionEnabled = false;
        self.saveBtn.alpha = 0.4;
        return;
    }
    
    if (self.coinArray.count == 0 || self.coinArray == nil) {
        self.saveBtn.userInteractionEnabled = false;
        self.saveBtn.alpha = 0.4;
        return;
    }
    
    for (PWContactsCoin *coin in self.coinArray) {
        if (([NSString isBlankString:coin.coinName]) || ([NSString isBlankString:coin.coinAddress])) {
            self.saveBtn.userInteractionEnabled = false;
            self.saveBtn.alpha = 0.4;
            return;
        }
    }
    
    self.saveBtn.userInteractionEnabled = true;
    self.saveBtn.alpha = 1;
}

#pragma mark - tableView 代理和数据源

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.coinArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PWAddContactsAddressCell *cell =  [[PWAddContactsAddressCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.coinNameText = self.coinArray[indexPath.row].optional_name;
    cell.addressText = self.coinArray[indexPath.row].coinAddress;
    cell.delegate = self;
    return cell;
}

#pragma mark - tableView 高度 header footer配置
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 34;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    YYLabel *label = [[YYLabel alloc]init];
    label.backgroundColor = tableView.backgroundColor;
    label.font = [UIFont boldSystemFontOfSize:14];
    label.textColor = SGColorFromRGB(0x333649);
    label.text = [NSString stringWithFormat:@"        %@",@"地址".localized];
    label.textVerticalAlignment = YYTextVerticalAlignmentBottom;
    //竖线
    UILabel *verticalLab = [[UILabel alloc]initWithFrame:CGRectMake(18, 17, 3, 14)];
    verticalLab.backgroundColor = SGColorFromRGB(0x7190FF);
    [label addSubview:verticalLab];
    return label;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc]init];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120.0;
}

#pragma mark - PWAddContactsAddressCell 代理方法
//地址textView完成编辑
- (void)addContactsAddressCell:(PWAddContactsAddressCell *)cell addressTextViewDidEndEditing:(UITextView *)textView {
    NSInteger row = [self.tableView indexPathForCell:cell].row;
    self.coinArray[row].coinAddress = [PWUtils removeSpaceAndNewline:textView.text];
    [self setSaveButtonState];
}

//主链(虚拟币名字)点击
- (void)addContactsAddressCell:(PWAddContactsAddressCell *)cell nameButtonPress:(UIButton *)button {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];//关闭键盘
    NSInteger row = [self.tableView indexPathForCell:cell].row;
    __weak typeof(self) weakSelf = self;
    ContactCoinViewController *vc = [[ContactCoinViewController alloc] init];
    self.definesPresentationContext = YES;
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:vc animated:NO completion:nil];
    vc.selectCoin = ^(NSString *optional_name,NSString *coinName, NSString *coinPlatform) {
        NSLog(@"__%@",coinName);
        [button setTitle:optional_name forState:UIControlStateNormal];
        weakSelf.coinArray[row].coinName = coinName;
        weakSelf.coinArray[row].optional_name = optional_name;
        weakSelf.coinArray[row].coinPlatform = coinPlatform;
        [weakSelf setSaveButtonState];
    };
}

//扫描button点击
- (void)addContactsAddressCell:(PWAddContactsAddressCell *)cell scanBtnPress:(UIButton *)button {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];//关闭键盘
    ScanViewController *scanVC = [[ScanViewController alloc]init];
    __weak typeof(self) weakSelf = self;
    [self.navigationController pushViewController:scanVC animated:true];
    scanVC.scanResult = ^(NSString *address) {
        NSArray *array = [address componentsSeparatedByString:@","];
        if (array.count == 3) {
            address = [NSString stringWithFormat:@"%@",array[2]];
        }
        else if (array.count == 2)
        {
           address = [NSString stringWithFormat:@"%@",array[1]];
        }
        
        cell.addressText = address;
        NSInteger row = [weakSelf.tableView indexPathForCell:cell].row;
        weakSelf.coinArray[row].coinAddress = address;
        [weakSelf setSaveButtonState];
    };
}

//删除按钮点击
- (void)addContactsAddressCell:(PWAddContactsAddressCell *)cell deleteBtnPress:(UIButton *)button {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if((indexPath != nil) && (indexPath.section == 0)) {
        [self.coinArray removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self setSaveButtonState];
    }
}

#pragma mark - 添加地址button和点击事件
- (UIView*)addAddressButton {
    UIImageView *imageView = [[UIImageView alloc]init];
    imageView.image = [UIImage imageNamed:@"Rectangle501"];
    imageView.userInteractionEnabled = true;
    imageView.layer.borderWidth = 1;
    imageView.layer.borderColor = [UIColor clearColor].CGColor;
    imageView.layer.cornerRadius = 6;
    imageView.contentMode = UIViewContentModeCenter;
    UIButton *addAddressBtn = [[UIButton alloc]init];
    [imageView addSubview:addAddressBtn];
    addAddressBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [addAddressBtn setTitle:@"添加地址".localized forState:UIControlStateNormal];
    [addAddressBtn setTitleColor:SGColorFromRGB(0x7190FF) forState:UIControlStateNormal];
    addAddressBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [addAddressBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [addAddressBtn addTarget:self action:@selector(addAddressBtnPress:) forControlEvents:UIControlEventTouchUpInside];
    [addAddressBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(imageView);
    }];
    return imageView;
}
- (void)addAddressBtnPress:(UIButton*)sender {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];//关闭键盘
    if (!self.coinArray) {
        self.coinArray = [NSMutableArray array];
    }
    [self.coinArray insertObject:[[PWContactsCoin alloc]init] atIndex:0];
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:0];
    [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationAutomatic];
    [self setSaveButtonState];
    
    //获取刚刚添加在tableview上的cell的indexPath
     NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    //获取刚刚添加在tableview上的cell
    PWAddContactsAddressCell *cell = (PWAddContactsAddressCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    //直接调用一次cell上主链按钮点击事件
    [self addContactsAddressCell:cell nameButtonPress:cell.nameBtn];
}

#pragma mark - 重写父类方法
- (UIBarButtonItem *)rt_customBackItemWithTarget:(id)target
                                          action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"返回箭头"] forState:UIControlStateNormal];
    
    if (@available(iOS 11.0, *)) {
        
    }else{
        button.imageEdgeInsets = UIEdgeInsetsMake(0,10, 0, -10);
    }
    
    //添加空格字符串 增加点击面积
    [button setTitle:@"    " forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:44];
    [button sizeToFit];
    [button addTarget:self
               action:@selector(backAction)
     forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

@end
