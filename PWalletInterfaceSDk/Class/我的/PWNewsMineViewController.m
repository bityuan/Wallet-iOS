//
//  PWNewsMineViewController.m
//  PWallet
//
//  Created by 郑晨 on 2019/12/13.
//  Copyright © 2019 陈健. All rights reserved.
//

#import "PWNewsMineViewController.h"
#import "MineTableViewCell.h"
#import "PWShareDownloadController.h"
#import "PWAboutUsController.h"
#import "PWLoginTool.h"
#import "PWVersionModel.h"
#import "PWLanguageViewController.h"
#import "PWMineHeadItemView.h"
#import "PWContactsController.h"
#import "PWMessageCenterController.h"

@interface PWNewsMineViewController ()
<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *headViewItemArray; // 顶部项目列表
@property (nonatomic, strong) NSArray *cellArray;

@property (nonatomic, strong) UIView *headBgView;
@property (nonatomic, strong) PWMineHeadItemView *headItemView;

@end

@implementation PWNewsMineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initData];
    [self.view addSubview:self.tableView];
//    [self createHeadView];
    self.title = @"我的".localized;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeLanguage)
                                                 name:kChangeLanguageNotification
                                               object:nil];

}

- (void)changeLanguage
{
    self.title = @"我的".localized;
    [self initData];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   

    if (@available(iOS 13.0, *)) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDarkContent;
    } else {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

- (void)initData
{
    
    _headViewItemArray = @[@{@"name":@"联系人".localized,
                             @"icon":@"mine_contact"},
                           @{@"name":@"消息中心".localized,
                             @"icon":@"mine_message"}];
    
    _cellArray =@[@{@"name":@"应用下载".localized,
                    @"icon":@"mine_download"},
                  @{@"name":@"检测更新".localized,
                    @"icon":@"mine_update"},
                  @{@"name":@"关于我们".localized,
                    @"icon":@"mine_aboutus"},
                  @{@"name":@"语言切换".localized,
                    @"icon":@"多语言"}];
    
}

#pragma mark - uiscrollviewdelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat height = 110;
    CGFloat y = scrollView.contentOffset.y;
    if (scrollView == _tableView) {
        if (y < -height) {
            CGRect frame = _headBgView.frame;
            frame.size.height = -y;
            frame.origin.y = y;
            _headBgView.frame = frame;
           
        }
    }
}

- (void)createHeadView
{
    CGFloat height = 110;
    
    _headBgView = [[UIView alloc] initWithFrame:CGRectMake(0, -height, kScreenWidth, height)];
    _headBgView.backgroundColor = SGColorFromRGB(0xf8f8fa);
    
    [self.tableView addSubview:_headBgView];
    self.tableView.contentInset = UIEdgeInsetsMake(height, 0, 0, 0);
    
    
    _headItemView = [[PWMineHeadItemView alloc] initWithFrame:CGRectMake(11, 10, kScreenWidth - 22, 100)];
    _headItemView.dataArray = _headViewItemArray;
    _headItemView.layer.cornerRadius = 10.f;
    [PWUtils addShadow:_headItemView];
    WEAKSELF
    _headItemView.mineHeadItemViewBlock = ^(NSString * _Nonnull item) {
        [weakSelf clickItem:item];
    };
    [_headBgView addSubview:_headItemView];
    
}

#pragma mark - 点击headviewitem的功能
- (void)clickItem:(NSString *)itemStr
{
    if ([itemStr isEqualToString:@"联系人".localized])
    {
        [self toContactView];
    }
    else if ([itemStr isEqualToString:@"消息中心".localized])
    {
        [self toMessageCenter];
    }
    
}

#pragma mark - 联系人
- (void)toContactView
{
    PWContactsController *contactsVC = [[PWContactsController alloc]init];
    contactsVC.parentController = ContactParentMine;
    [self.navigationController pushViewController:contactsVC animated:true];
}
    
- (void)toMessageCenter
{
    PWMessageCenterController *vc = [[PWMessageCenterController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    vc.title = @"消息中心".localized;
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - uitableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   
    return _cellArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    MineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[MineTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        UIImageView *accessoryImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessory"]];
        cell.accessoryView = accessoryImgView;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.separatorInset = UIEdgeInsetsMake(0,0, 0, cell.bounds.size.width-15);
    cell.imageView.image = [UIImage imageNamed:[self.cellArray[indexPath.row] objectForKey:@"icon"]];
    cell.textLabel.text = [self.cellArray[indexPath.row] objectForKey:@"name"];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = SGColorFromRGB(0x333649);
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.backgroundColor = UIColor.whiteColor;
    NSString *cellText = [self.cellArray[indexPath.row] objectForKey:@"name"];
    if ([cellText isEqualToString:@"检测更新".localized]) {
        NSString *currentVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"v%@",currentVersion];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:15.f];
        cell.detailTextLabel.textColor = SGColorFromRGB(0x333649);
    }
    else if ([cellText isEqualToString:@"语言切换".localized])
    {
        NSArray *languageShowArray = @[@{@"name":@"简体中文",
                                         @"language":@(LanguageChineseSimplified)},
                                       @{@"name":@"English",
                                         @"language":@(LanguageEnglish)}];
        NSString *languageStr = @"简体中文";
        for (NSDictionary *dict in languageShowArray) {
            NSString *name = [dict objectForKey:@"name"];
            Language language = [[dict objectForKey:@"language"] intValue];
            if (language == [LocalizableService getAPPLanguage])
            {
                languageStr = name;
            }
        }
        cell.detailTextLabel.font = [UIFont systemFontOfSize:15.f];
        cell.detailTextLabel.textColor = SGColorFromRGB(0x333649);
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",languageStr];
    }else {
        cell.detailTextLabel.text = @"";
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 100)];
    
    _headItemView = [[PWMineHeadItemView alloc] initWithFrame:CGRectMake(11, 10, kScreenWidth - 22, 100)];
    _headItemView.dataArray = _headViewItemArray;
    _headItemView.layer.cornerRadius = 10.f;
    [PWUtils addShadow:_headItemView];
    WEAKSELF
    _headItemView.mineHeadItemViewBlock = ^(NSString * _Nonnull item) {
        [weakSelf clickItem:item];
    };
    [view addSubview:_headItemView];
    
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section == 0 ? 120.f : 10.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return .1f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellText = [_cellArray[indexPath.row] objectForKey:@"name"];
    if ([cellText isEqualToString:@"应用下载".localized])
    {
        [self toDownloadVC];
    }
    else if ([cellText isEqualToString:@"检测更新".localized])
    {
        [self checkUpdate];
    }
    else if ([cellText isEqualToString:@"关于我们".localized])
    {
        [self toAboutUsVC];
    }
    else if ([cellText isEqualToString:@"语言切换".localized])
    {
        [self goToLanguageVC];
    }
}


#pragma mark - 功能事件
- (void)goToLanguageVC
{
    PWLanguageViewController *languageVC = [[PWLanguageViewController alloc] init];
    languageVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:languageVC animated:YES];
}
#pragma mark - 应用下载
- (void)toDownloadVC
{
    PWShareDownloadController *vc = [[PWShareDownloadController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - 检测更新
- (void)checkUpdate
{
    
    [self showCustomMessage:@"当前是最新版本".localized hideAfterDelay:2.f];
//    [self showProgressWithMessage:nil];
//    
//    NSString *htmlStr = [NSString stringWithContentsOfURL:[NSURL URLWithString:UPDATEJSON] encoding:NSUTF8StringEncoding error:nil];
//    NSData *jsonData = [htmlStr dataUsingEncoding:NSUTF8StringEncoding];
//    [self hideProgress];
//    if (jsonData == nil) {
//        return;
//    }
//    NSError *error;
//    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
//    if (!error) {
//        NSDictionary *updateDict = dict[@"data"];
//        
//        PWVersionModel *model = [PWVersionModel yy_modelWithDictionary:updateDict];
//        
//        NSString *versionInServer = model.version;
//        NSString *currentVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
//        NSArray *serverVersionArray = [versionInServer componentsSeparatedByString:@"."];
//        NSArray *currentVersionArray = [currentVersion componentsSeparatedByString:@"."];
//        NSInteger serverVersionValue = 0;
//        NSInteger currentVersionValue = 0;
//        for ( long i = (serverVersionArray.count - 1); i >= 0; i--) {
//            NSInteger value = [[serverVersionArray objectAtIndex:(serverVersionArray.count - 1 - i)] integerValue];
//            serverVersionValue = serverVersionValue + pow(10, i) * value;
//        }
//        
//        for ( long i = (currentVersionArray.count - 1); i >= 0; i--) {
//            NSInteger value = [[currentVersionArray objectAtIndex:(serverVersionArray.count - 1 - i)] integerValue];
//            currentVersionValue = currentVersionValue + pow(10, i) * value;
//        }
//        
//        if (currentVersionValue < serverVersionValue) {
//            if (model.status == 4) { // 4强制更新
//                [PWLoginTool forcedUpdate:self data:model];
//            }
//            else {
//                [PWLoginTool recommendUpdate:self data:model];
//            }
//        }else{
//            [self showCustomMessage:@"当前是最新版本".localized hideAfterDelay:2.f];
//        }
//    }
}
#pragma mark - 关于我们
- (void)toAboutUsVC
{
    PWAboutUsController *vc = [[PWAboutUsController alloc]init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:true];
}

#pragma mark - getter and setter
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 90) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.backgroundColor = SGColorFromRGB(0xf8f8fa);
        
    }
    return _tableView;
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
