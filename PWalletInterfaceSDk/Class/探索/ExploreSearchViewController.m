//
//  ExploreSearchViewController.m
//  PWalletInterfaceSDk
//
//  Created by 郑晨 on 2022/12/22.
//  Copyright © 2022 fzm. All rights reserved.
//

#import "ExploreSearchViewController.h"
#import "WebViewController.h"
#import "HistoryWebSiteCell.h"

@interface ExploreSearchViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSMutableArray *titleArray;
@property (nonatomic, strong) NSMutableArray *nameArrray;
@property (nonatomic, strong) UITextField *searchTextField;
@property (nonatomic) BOOL exitSearch; // 退出了搜索页面

@property (nonatomic, strong) NSMutableArray *websiteMarray;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ExploreSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    self.rt_disableInteractivePop = true;
   
    [self initTitleView];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.searchTextField endEditing:YES];
//    });
    
    if (@available(iOS 13.0, *)) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDarkContent;
    } else {
           // Fallback on earlier versions
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }
    self.websiteMarray = [[PWAppsettings instance] getEWebsite];
    if(self.websiteMarray == nil)
    {
        self.websiteMarray = [[NSMutableArray alloc] init];
    }
    
    [self.tableView reloadData];

}

//重写返回方法
- (void)backAction{
    [self.view endEditing:YES];
    [self.searchTextField endEditing:YES];
    [self cancel];
}

- (void)initTitleView
{
    _searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 257 * kScreenRatio, 36)];
    _searchTextField.placeholder = @"请输入网址".localized;
    _searchTextField.backgroundColor = SGColorFromRGB(0xf8f8fa);
    _searchTextField.font = [UIFont systemFontOfSize:16.f];
    _searchTextField.textColor = SGColorFromRGB(0x333649);
    _searchTextField.leftViewMode = UITextFieldViewModeAlways;
    _searchTextField.returnKeyType = UIReturnKeySearch;
    _searchTextField.delegate = self;
    [_searchTextField setValue:SGColorFromRGB(0x8a97a5) forKeyPath:@"placeholderLabel.textColor"];
//    [_searchTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_searchTextField becomeFirstResponder];
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(6, 9, 23, 23)];
    imageView.image = [UIImage imageNamed:@"APP搜索"];
    [leftView addSubview:imageView];
    
    _searchTextField.leftView = leftView;


    self.navigationItem.titleView = _searchTextField;
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"取消".localized style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    [rightItem setTintColor:SGColorFromRGB(0x8e92a3)];
    [rightItem setTitleTextAttributes:@{NSForegroundColorAttributeName:SGColorFromRGB(0x8e92a3)} forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)cancel
{
    if(self.dismissBlock)
    {
        self.dismissBlock();
    }
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - uitableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.websiteMarray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const identity = @"history";
    HistoryWebSiteCell *cell = [tableView dequeueReusableCellWithIdentifier:identity];
    if(!cell){
        cell = [[HistoryWebSiteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identity];
    }
    cell.titleLab.text = [NSString stringWithFormat:@"%@",self.websiteMarray[indexPath.row]];
    
    cell.deleteBlock = ^(UITableViewCell * _Nonnull cell) {
        NSIndexPath *indexPath = [tableView indexPathForCell:cell];
        [self.websiteMarray removeObjectAtIndex:indexPath.row];
        [[PWAppsettings instance] deleteEWebsite];
        [[PWAppsettings instance] saveEWebsite:self.websiteMarray];
        [self.tableView reloadData];
    };
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 25)];
    headView.backgroundColor = UIColor.whiteColor;
    UILabel *titLab = [UILabel getLabWithFont:[UIFont systemFontOfSize:12]
                                    textColor:SGColorFromRGB(0x8a97a5)
                                textAlignment:NSTextAlignmentLeft
                                         text:@"搜索历史".localized];
    [headView addSubview:titLab];
    
    UIButton *clearBtn = [[UIButton alloc] init];
    [clearBtn setTitle:@"清空".localized forState:UIControlStateNormal];
    [clearBtn setTitleColor:SGColorFromRGB(0x8a97a5) forState:UIControlStateNormal];
    [clearBtn addTarget:self action:@selector(clearHis:) forControlEvents:UIControlEventTouchUpInside];
    [clearBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    
    
    [headView addSubview:clearBtn];
    
    [titLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headView).offset(16);
        make.height.top.equalTo(headView);
    }];
    
    [clearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(headView).offset(-16);
        make.height.top.equalTo(headView);
    }];
    
    return self.websiteMarray.count == 0 ? nil : headView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return self.websiteMarray.count == 0 ? 0.1f : 25;

}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *website = self.websiteMarray[indexPath.row];
    WebViewController *vc = [[WebViewController alloc] init];
    vc.webUrl = [self getCompleteWebSite:website];
    vc.title = website;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)clearHis:(UIButton *)sender
{
    UIAlertController *alertvc = [UIAlertController alertControllerWithTitle:@"" message:@"是否清空搜索历史".localized preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *acYes = [UIAlertAction actionWithTitle:@"是".localized style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.websiteMarray removeAllObjects];
        [[PWAppsettings instance] deleteEWebsite];
        [[PWAppsettings instance] saveEWebsite:self.websiteMarray];
        [self.tableView reloadData];
    }];
    UIAlertAction *acNo = [UIAlertAction actionWithTitle:@"否".localized style:UIAlertActionStyleDestructive handler:nil];
    
    [alertvc addAction:acNo];
    [alertvc addAction:acYes];
    
    [self presentViewController:alertvc animated:YES completion:nil];
}

#pragma mark- textFieldDidChange

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(![self.websiteMarray containsObject:textField.text]){
        [self.websiteMarray addObject:textField.text];
        [[PWAppsettings instance] deleteEWebsite];
        [[PWAppsettings instance] saveEWebsite:self.websiteMarray];
    }
    
    
    WebViewController *vc = [[WebViewController alloc] init];
    vc.webUrl = [self getCompleteWebSite:textField.text];
    vc.title = textField.text;
    [self.navigationController pushViewController:vc animated:YES];
    return YES;
}

- (NSString *)getCompleteWebSite:(NSString *)urlStr
{
    NSString *returnUrlStr = nil;
    NSString *scheme = nil;
    assert(urlStr != nil);
    
    urlStr = [urlStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if(urlStr != nil && urlStr.length != 0){
        NSRange urlRange = [urlStr rangeOfString:@"://"];
        if(urlRange.location == NSNotFound){
            returnUrlStr = [NSString stringWithFormat:@"https://%@",urlStr];
        }else{
            scheme = [urlStr substringWithRange:NSMakeRange(0, urlRange.location)];
            assert(scheme != nil);
            
            if([scheme compare:@"http" options:NSCaseInsensitiveSearch] == NSOrderedSame
               || [scheme compare:@"https" options:NSCaseInsensitiveSearch] == NSOrderedSame){
                returnUrlStr = urlStr;
            }else{
                // 不支持的url
            }
        }
    }
    return returnUrlStr;
    
}

#pragma mark - getter and setter
- (UITableView *)tableView
{
    if(!_tableView){
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.backgroundColor = UIColor.whiteColor;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
//        _tableView.separatorColor = LineColor;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
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
