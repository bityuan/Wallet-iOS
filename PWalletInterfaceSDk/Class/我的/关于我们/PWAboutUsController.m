//
//  PWAboutUsController.m
//  PWallet
//  关于我们
//  Created by 陈健 on 2018/6/4.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import "PWAboutUsController.h"
#import "WebViewController.h"

@interface PWAboutUsController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong) NSMutableArray *dataArray;
@property(nonatomic,strong) UILabel *bottomTipLab;
@end

@implementation PWAboutUsController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"关于我们".localized;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initViews];
}

- (void)initViews {
    //UITableView
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:tableView];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tableFooterView = [[UIView alloc]init];
    tableView.backgroundColor = self.view.backgroundColor;
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(0.5);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - tableView 代理和数据源

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ContactsCellIdentifier = @"ContactsCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ContactsCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ContactsCellIdentifier];
    }
//    cell.imageView.image = indexPath.row == 0 ? [UIImage imageNamed:@"icon_protocol"] : [UIImage imageNamed:@"icon_suggest"];
    return cell;
}

#pragma mark - tableView 高度 header footer配置
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 220;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *topView = [[UIView alloc]init];
    topView.backgroundColor = SGColorFromRGB(0xF7F7FB);
    
    UIImageView *logoImageView = [[UIImageView alloc]init];
    [topView addSubview:logoImageView];
    [logoImageView setImage:[UIImage imageNamed:@"appiconcopy"]];
    [logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topView).offset(39);
        make.centerX.equalTo(topView);
        make.width.height.mas_equalTo(76);
    }];
    logoImageView.layer.cornerRadius = 12;
    logoImageView.layer.masksToBounds = true;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(inputAddress)];
    tap.numberOfTapsRequired = 8;
    [logoImageView addGestureRecognizer:tap];
    logoImageView.userInteractionEnabled = YES;
    UILabel *infoLabel = [[UILabel alloc]init];
    [topView addSubview:infoLabel];
    infoLabel.font = [UIFont systemFontOfSize:14];
    infoLabel.textColor = SGColorRGBA(153, 153, 153, 1);
    infoLabel.text = [NSString stringWithFormat:@"MyDao是一款移动端货币钱包App，旨在为用户提供安全，好用，功能强大数字资产管理工具。".localized];
    infoLabel.textAlignment = NSTextAlignmentLeft;
    infoLabel.numberOfLines = 0;
    NSMutableParagraphStyle *paraStyle01 = [[NSMutableParagraphStyle alloc] init];
    paraStyle01.alignment = NSTextAlignmentLeft;
    paraStyle01.headIndent = 0.0f;//行首缩
    //参数：（字体大小17号字乘以2，34f即首行空出两个字符）
    CGFloat emptylen = infoLabel.font.pointSize * 2;
    paraStyle01.firstLineHeadIndent = emptylen;//首行缩进
    paraStyle01.tailIndent = 0.0f;//行尾缩进
    paraStyle01.lineSpacing = 2.0f;//行间距
    NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:infoLabel.text attributes:@{NSParagraphStyleAttributeName:paraStyle01}];

    infoLabel.attributedText = attrText;
    [infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(logoImageView.mas_bottom).offset(27);
        make.left.equalTo(topView).offset(28);
        make.right.equalTo(topView).offset(-28);
    }];
    
    UIView *blankView = [[UIView alloc]init];
    blankView.backgroundColor = [UIColor whiteColor];
    
    return section == 0 ? topView : blankView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc]init];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)inputAddress
{
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示".localized
                                                                     message:@"请输入接口地址，以http或https开头，以/结尾".localized
                                                              preferredStyle:UIAlertControllerStyleAlert];
    
    [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入接口地址".localized;
        NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:@"textfieldText"];
        textField.text = str;
        textField.keyboardType = UIKeyboardTypeWebSearch;
    }];
    UIAlertAction *confirAction = [UIAlertAction actionWithTitle:@"确定".localized
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textfield = alertVC.textFields.firstObject;
        WebViewController *webVC = [[WebViewController alloc] init];
        webVC.webUrl = textfield.text;
        [[NSUserDefaults standardUserDefaults] setObject:textfield.text forKey:@"textfieldText"];
        [self.navigationController pushViewController:webVC animated:YES];
        
//        DappBroswerControlView *vc = [[DappBroswerControlView alloc] init];
//        vc.webUrl = texkjktfield.text;
//        if (isEscrowWallet) {
//            return;
//        }
//        NSArray *coinArray = [[PWDataBaseManager shared] queryCoinArrayBasedOnWallet:[[PWDataBaseManager shared] queryWalletIsSelected]];
//
//        for (LocalCoin *coin in coinArray) {
//            if ([coin.coin_chain isEqualToString:@"BTY"] && [coin.coin_chain isEqualToString:coin.coin_type]) {
//                vc.localCoin = coin;
//                break;
//            }
//        }
//
//        [[NSUserDefaults standardUserDefaults] setObject:textfield.text forKey:@"textfieldText"];
//        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    [alertVC addAction:cancelAction];
    [alertVC addAction:confirAction];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

@end
