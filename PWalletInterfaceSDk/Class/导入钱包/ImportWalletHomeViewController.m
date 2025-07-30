//
//  ImportWalletHomeViewController.m
//  PWallet
//
//  Created by 郑晨 on 2019/10/23.
//  Copyright © 2019 陈健. All rights reserved.
//

#import "ImportWalletHomeViewController.h"
#import "ImportPriKeyViewController.h"
#import "CAPSPageMenu.h"
#import "ScanViewController.h"
#import "PWImportWalletViewController.h"
#import "PWRecoverWalletViewController.h"
#define MAS_SHORTHAND_GLOBALS



@interface ImportWalletHomeViewController ()
<CAPSPageMenuDelegate>
@property (nonatomic, strong) CAPSPageMenu *pageMenu;
@property (nonatomic, strong) UIViewController *viewController;
@end

@implementation ImportWalletHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"导入钱包".localized ;
    self.showMaskLine = false;
    [self initView];
    self.navigationItem.rightBarButtonItem = [self rightNavigationItem];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (@available(iOS 13.0, *)) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDarkContent;
    } else {
           // Fallback on earlier versions
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }
}


- (void)initView
{

    NSArray *titleArray = @[@"导入助记词".localized,@"导入私钥".localized,@"导入找回钱包".localized];
    NSMutableArray *childVC = [[NSMutableArray alloc] init];
    
    PWImportWalletViewController *walletVC = [[PWImportWalletViewController alloc] init];
    walletVC.title = titleArray[0];
    [childVC addObject:walletVC];

    ImportPriKeyViewController *prikeyVC = [[ImportPriKeyViewController alloc] init];
    prikeyVC.title = titleArray[1];
    [childVC addObject:prikeyVC];

    PWRecoverWalletViewController *recoverVC = [[PWRecoverWalletViewController alloc] init];
    recoverVC.title = titleArray[2];
    [childVC addObject:recoverVC];
    
    CGFloat width = (kScreenWidth - 32) / 3;

    NSDictionary *parameters = @{
                                    CAPSPageMenuOptionBottomMenuHairlineColor: SGColorFromRGB(0xececec),
                                    CAPSPageMenuOptionScrollMenuBackgroundColor: [UIColor whiteColor],
                                    CAPSPageMenuOptionSelectionIndicatorHeight: @(3),
                                    CAPSPageMenuOptionMenuHeight:@(40),
                                    CAPSPageMenuOptionMenuItemWidth:@(width),
                                    CAPSPageMenuOptionUnselectedMenuItemLabelColor: SGColorFromRGB(0x8e92a3),
                                    CAPSPageMenuOptionSelectedMenuItemLabelColor: SGColorFromRGB(0x333649),
                                    CAPSPageMenuOptionSelectionIndicatorColor: SGColorFromRGB(0x333649),
                                    CAPSPageMenuOptionMenuItemFont:[UIFont boldSystemFontOfSize:16],
                                    CAPSPageMenuOptionMenuSelectedItemFont:[UIFont boldSystemFontOfSize:16],
                                    CAPSPageMenuOptionAddBottomMenuHairline:@(YES),
                                    CAPSPageMenuOptionMenuMargin:@(8),
                                    CAPSPageMenuOptionMenuItemWidthBasedOnTitleTextWidth:@(NO)
                                    };
       
       self.pageMenu = [[CAPSPageMenu alloc] initWithViewControllers:childVC frame:CGRectMake(0,0, kScreenWidth, kScreenHeight) options:parameters];
       self.pageMenu.delegate = self;
       [self addChildViewController:self.pageMenu];
       
       [self.view addSubview:self.pageMenu.view];
    _viewController = walletVC;
}

#pragma mark -- CAPSPageMenuDelegate
- (void)didMoveToPage:(UIViewController *)controller index:(NSInteger)index
{
    NSLog(@"did move index  %li",(long)index);
    _viewController = controller;
    if(index == 2){
        self.navigationItem.rightBarButtonItem = nil;
    }else{
        self.navigationItem.rightBarButtonItem = [self rightNavigationItem];
    }
   
}

- (void)willMoveToPage:(UIViewController *)controller index:(NSInteger)index
{
    NSLog(@"will move index  %li",(long)index);
    _viewController = controller;
//    if(index == 2){
//        self.navigationItem.rightBarButtonItem = nil;
//    }else{
//        self.navigationItem.rightBarButtonItem = [self rightNavigationItem];
//    }
}

- (UIBarButtonItem *)rightNavigationItem
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(-10, 0, 60, 60)];
    [btn setImage:[UIImage imageNamed:@"import_scan"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"import_scan"] forState:UIControlStateHighlighted];
    [btn setContentMode:UIViewContentModeScaleAspectFit];
    [btn addTarget:self action:@selector(importScan:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    return item;
}

- (void)importScan:(UIButton *)sender
{
    ScanViewController *vc = [[ScanViewController alloc] init];
    WEAKSELF
    vc.scanResult = ^(NSString *address) {
           NSLog(@"address is %@",address);
        if ([weakSelf.viewController isKindOfClass:[ImportPriKeyViewController class]])
        {
            ImportPriKeyViewController *vc = (ImportPriKeyViewController *)weakSelf.viewController;
            vc.addressTextView.text = address;
            
            vc.palceHoldLab.hidden = YES;
        }
        else if ([weakSelf.viewController isKindOfClass:[PWImportWalletViewController class]])
        {
            PWImportWalletViewController *vc = (PWImportWalletViewController *)weakSelf.viewController;
            vc.addressTextView.text = address;
            vc.palceHoldLab.hidden = YES;
        }
    };
       
    [self.navigationController pushViewController:vc animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
