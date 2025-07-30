//
//  PWMessageCenterController.m
//  PWallet
//
//  Created by 陈健 on 2018/11/16.
//  Copyright © 2018 陈健. All rights reserved.
//

#import "PWMessageCenterController.h"
#import "PWSystemMessageController.h"
#import "PWOtherMessageController.h"
#import "PWReadSystemMessageController.h"
#import "CAPSPageMenu.h"
#import <UIViewController+RTRootNavigationController.h>

@interface PWMessageCenterController ()
@property (nonatomic,strong) CAPSPageMenu *pageMenu;
@end

@implementation PWMessageCenterController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 禁止左滑返回
    self.rt_disableInteractivePop = YES;
    self.view.backgroundColor = SGColorRGBA(247, 247, 251, 1);
    self.title = @"消息中心".localized;
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0,20, 40, 40)];
    [btn addTarget:self action:@selector(readAll) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"全部已读".localized forState:UIControlStateNormal];
    [btn setTitleColor:SGColorRGBA(51, 54, 73, 1) forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    
    PWSystemMessageController *systemMessageVC = [[PWSystemMessageController alloc]init];
    systemMessageVC.title = @"系统消息".localized;
 
//#if ShangLianTong || ZHAOBI || COCWallet || Hitoken || BUW || LSW || VBW || RHC || LELE || ZYW || SNOW || HDCW  || BMSW || LHG || LJZ || MCW || GWA || DPT || GE || CSLA || FLSU || GCGL
    [self addChildViewController:systemMessageVC];
    [self.view addSubview:systemMessageVC.view];
//#else
//    PWOtherMessageController *otherMessageVC = [[PWOtherMessageController alloc]init];
//    otherMessageVC.title = @"转账收款消息".localized;
//    NSArray *vcArray = [NSArray arrayWithObjects:otherMessageVC,systemMessageVC, nil];
//    UIFont *fnt=[UIFont systemFontOfSize:15.0f];
//    CGSize size1 = [@"系统消息".localized sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:fnt,NSFontAttributeName,nil]];
//    CGSize size2 = [@"转账收款消息".localized sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:fnt,NSFontAttributeName,nil]];
//    CGFloat itWidth=(size1.width>size2.width)?size1.width:size2.width;
//    NSDictionary *parameters = @{
//                                 CAPSPageMenuOptionBottomMenuHairlineColor: SGColorRGBA(246, 248, 250, 1),
//                                 CAPSPageMenuOptionScrollMenuBackgroundColor: [UIColor whiteColor],
//                                 CAPSPageMenuOptionMenuHeight:@(44),
//                                 CAPSPageMenuOptionMenuMargin:@((kScreenWidth - itWidth*2) / 3),
//                                 CAPSPageMenuOptionMenuItemWidth : @(itWidth),
//                                 CAPSPageMenuOptionSelectionIndicatorLength: @"centerHalf",
//                                 CAPSPageMenuOptionSelectionIndicatorHeight: @(3),
//                                 CAPSPageMenuOptionEnableHorizontalBounce: @false,
//                                 CAPSPageMenuOptionMenuItemFont: [UIFont systemFontOfSize:15],
//                                 CAPSPageMenuOptionMenuSelectedItemFont:[UIFont systemFontOfSize:15],
//                                 CAPSPageMenuOptionUnselectedMenuItemLabelColor: SGColorRGBA(153, 153, 153, 1),
//                                 CAPSPageMenuOptionSelectedMenuItemLabelColor: SGColorRGBA(113, 144, 255, 1),
//                                 CAPSPageMenuOptionSelectionIndicatorColor: SGColorRGBA(113, 144, 255, 1),
//                                 };
//     CAPSPageMenu *pageMenu = [[CAPSPageMenu alloc] initWithViewControllers:vcArray frame:CGRectMake(0,0, kScreenWidth, kScreenHeight) options:parameters];
//    self.pageMenu = pageMenu;
//    [self addChildViewController:pageMenu];
//    [self.view addSubview:pageMenu.view];
//    [self.pageMenu moveToPage:1 object:nil];
////    [self.pageMenu moveToPage:0 object:nil];
//    if (_index == 0) {
//        [self.pageMenu moveToPage:0 object:nil];
//    }
//#endif
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // 允许左滑返回
    self.rt_disableInteractivePop = NO;
}

- (void)readAll {
    NSNotificationName const readAllNotification = @"readAllNotification";
    [[NSNotificationCenter defaultCenter] postNotificationName:readAllNotification object:nil];
}

- (void)backAction
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
