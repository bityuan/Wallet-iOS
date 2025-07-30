//
//  PWShareDownloadController.m
//  PWallet
//  分享下载
//  Created by 陈健 on 2018/6/5.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import "PWShareDownloadController.h"
#import "UIViewController+ShowInfo.h"
#import "CommonFunction.h"

#define  downloadurl @"https://d.mydao.plus"

@interface PWShareDownloadController ()
/*地址地址**/
@property(nonatomic,copy)NSString *shareURL;
@property(nonatomic,copy)NSString *shareName;
@property(nonatomic,copy)NSString *shareIntroduce;
@property(nonatomic,strong)UIImageView *qrImageView;
@end

@implementation PWShareDownloadController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
//    self.shareURL = PW_SHARE_URL;

    [self initViews];
   
    self.title = @"分享下载".localized;

}

- (UIBarButtonItem *)setLeftBarButtonItem
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 20)];
    [btn setImage:[UIImage imageNamed:@"返回箭头"] forState:UIControlStateNormal];
    [btn setTitle:@"" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(clickBackBtn:) forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *bar = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    return bar;
}

- (void)clickBackBtn:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initViews {
    //背景
    
    UIImageView *bgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"背景"]];
    [self.view addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(30);
        make.centerX.equalTo(self.view);
    }];
    
    UIView *imageViewBg = [[UIView alloc]init];
    [self.view addSubview:imageViewBg];
    imageViewBg.backgroundColor = SGColorFromRGB(0x505363);
    [imageViewBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bgView).offset(40);
        make.width.height.mas_equalTo(220);
        make.centerX.equalTo(bgView);
    }];
    
    self.qrImageView = [[UIImageView alloc]init];
    [self.view addSubview:self.qrImageView];
    NSString *imageName = @"appiconcopy";
    [self.qrImageView setImage:[CommonFunction createImgQRCodeWithString:downloadurl centerImage:[UIImage imageNamed:imageName]]];
    [self.qrImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imageViewBg).offset(16);
        make.bottom.equalTo(imageViewBg).offset(-16);
        make.left.equalTo(imageViewBg).offset(16);
        make.right.equalTo(imageViewBg).offset(-16);
    }];
    
    
    //复制下载地址
    UIButton *copyBtn = [[UIButton alloc]init];
    [self.view addSubview:copyBtn];
    [copyBtn setTitle:@"复制下载链接".localized forState:UIControlStateNormal];
    copyBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [copyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [copyBtn setBackgroundColor:SGColorFromRGB(0x7190FF)];

    
    copyBtn.layer.cornerRadius = 7;
    copyBtn.layer.masksToBounds = true;
    
    [copyBtn addTarget:self action:@selector(copyButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    CGRect rect = [copyBtn.titleLabel.text boundingRectWithSize:CGSizeMake(kScreenWidth - 40, MAXFLOAT)
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.f]}
                                                        context:nil];
    [copyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(imageViewBg);
        make.height.mas_equalTo(32);
        make.width.mas_equalTo(rect.size.width + 10);
        make.top.equalTo(imageViewBg.mas_bottom).offset(25);
    }];
    

}

#pragma mark - button点击事件

//复制下载地址
- (void)copyButtonPress:(UIButton*)sender {
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = downloadurl;
    [self showCustomMessage:@"复制成功".localized hideAfterDelay:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
