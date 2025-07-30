//
//  PWLanguageViewController.m
//  PWallet
//
//  Created by 郑晨 on 2019/6/3.
//  Copyright © 2019 陈健. All rights reserved.
//

#import "PWLanguageViewController.h"
#import <NSObject+YYModel.h>
#import "PWCountryCurrenyModel.h"

@interface PWLanguageViewController ()
<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSArray *showArray; // 显示的多语言组
@property (nonatomic, strong) UITableView *tableView;
@property(nonatomic,assign)ChangeType changeType;
@property (nonatomic, strong) NSArray *modelArray;
@end

@implementation PWLanguageViewController

- (instancetype)initWithChangeType:(ChangeType)type
{
    self = [super init];
    if (self) {
        self.changeType = type;
    }
    return self;
}

-(instancetype)init{
    self = [super init];
       if (self) {
           self.changeType = ChangeLang;
       }
       return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.bottom.equalTo(self.view);
    }];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    switch (self.changeType) {
        case ChangeMoney:
        {
        }

            break;
        case ChangeLang:
        {

            _showArray = @[@{@"name":@"简体中文",
                             @"type":@(LanguageChineseSimplified)},
                           @{@"name":@"English",
                             @"type":@(LanguageEnglish)}];
        }

            break;
        case ChangeIP:
        {
           
        }
            break;
            
        default:
            break;
    }
    
    
    [self.tableView reloadData];
    
}


#pragma mark - tableview delegate datasoruce

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"=========");
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _showArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identity = @"languagecell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identity];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identity];
    }
    
    cell.textLabel.text = [_showArray[indexPath.row] objectForKey:@"name"];
    cell.textLabel.textColor = SGColorFromRGB(0x333649);
    cell.backgroundColor = UIColor.whiteColor;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    switch (self.changeType) {
        case ChangeMoney:{
           
        }
            break;
        case ChangeLang:{
            Language language = [[_showArray[indexPath.row] objectForKey:@"type"] intValue];
            if (language == [LocalizableService getAPPLanguage])
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
            break;
        case ChangeIP:{

        }
            break;
        default:
            break;
    }
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.f;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (self.changeType) {
        case ChangeMoney:{
//            MoneyType type = [[_showArray[indexPath.row] objectForKey:@"type"] intValue];
//            [LocalizableService setAPPMoneyType:type];
        }
            break;
        case ChangeLang:
        {
            Language language = [[_showArray[indexPath.row] objectForKey:@"type"] intValue];
            [LocalizableService setAPPLanguage:language];
        }
            break;
        case ChangeIP:
        {
            IPCountry ip = [[_showArray[indexPath.row] objectForKey:@"type"] intValue];
            [LocalizableService setAPPIPCountry:ip];
        }
            break;
            
        default:
            break;
    }

    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:kChangeLanguageNotification object:nil];
}


#pragma mark - getter and setter
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _tableView.showsVerticalScrollIndicator = false;
        _tableView.backgroundColor = SGColorFromRGB(0xFCFCFF);
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = false;
        
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
