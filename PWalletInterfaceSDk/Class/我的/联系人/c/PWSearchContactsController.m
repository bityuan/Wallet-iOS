//
//  PWSearchContactsController.m
//  PWallet
//  搜索联系展示控制器
//  Created by 陈健 on 2018/5/29.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import "PWSearchContactsController.h"
#import "PWContactsCell.h"
#import "PWContactsDetailController.h"
#import "UISearchBar+SearchBarPlaceholder.h"

@interface PWSearchContactsController ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>

//tableView
@property(nonatomic,weak) UITableView *tableView;
@property(nonatomic,weak)UISearchController *searchController;
@property(nonatomic,strong) NSMutableArray<PWContacts*> *filtrateArray;
/**cover*/
@property (nonatomic,strong) UIImageView *coverImageView;
/** searchTextField */
@property (nonatomic,weak) UITextField *searchTextField;
@end

@implementation PWSearchContactsController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [NSString stringWithFormat:@"%@%@",@"搜索".localized,@"联系人".localized];
    self.filtrateArray = [NSMutableArray array];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initViews];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.searchTextField becomeFirstResponder];
}

- (void)initViews {
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"取消".localized style:UIBarButtonItemStylePlain target:self action:@selector(cancelBtnAction)];
    self.navigationItem.rightBarButtonItem = rightItem;
    [self.navigationController.navigationBar setTintColor:TextColor51];
    
    UIView *searchView = [[UIView alloc]init];
    [self.view addSubview:searchView];
    [searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(68);
    }];
    
    UITextField *searchTextField = [[UITextField alloc]init];
    [searchView addSubview:searchTextField];
    self.searchTextField = searchTextField;
    searchTextField.textColor = SGColorFromRGB(0x333649);
    searchTextField.font = [UIFont systemFontOfSize:16];
    searchTextField.backgroundColor = SGColorFromRGB(0xF8F8FA);
    searchTextField.layer.cornerRadius = 3;
    searchTextField.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 44, 39)];
    searchTextField.leftView.backgroundColor = SGColorFromRGB(0xF8F8FA);
    searchTextField.leftViewMode = UITextFieldViewModeAlways;
    searchTextField.returnKeyType = UIReturnKeyDone;
    searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [searchTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [searchTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(searchView).offset(10);
        make.left.equalTo(searchView).offset(23);
        make.right.equalTo(searchView).offset(-23);
        make.height.mas_equalTo(39);
    }];
    
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"APP搜索"]];
    imageView.frame = CGRectMake(13, 9, 20, 20);
    [searchTextField.leftView addSubview:imageView];
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:tableView];
    tableView.backgroundColor = self.view.backgroundColor;
    tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tableFooterView = [[UIView alloc]init];
    self.tableView = tableView;
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.right.equalTo(self.view).offset(-23);
        make.top.equalTo(searchView.mas_bottom);
        make.bottom.equalTo(self.view);
    }];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancelBtnAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)textFieldDidChange:(UITextField*)textField {
    [self.filtrateArray removeAllObjects];

    for (NSArray<PWContacts*> *contactsArr in self.dataArray) {
        for (PWContacts *contacts in contactsArr) {
            if ([contacts.nickName containsString:textField.text]) {
                [self.filtrateArray addObject:contacts];
            }
        }
    }
    if (self.filtrateArray.count == 0) {
        //搜索不到联系人
        self.coverImageView.alpha = 1;
    } else {
        self.coverImageView.alpha = 0;
        [self.tableView reloadData];
    }

}

#pragma mark - tableView 代理和数据源

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PWContactsDetailController *detailVC = [[PWContactsDetailController alloc]init];
    detailVC.contacts = self.filtrateArray[indexPath.row];
    [self.navigationController pushViewController:detailVC animated:true];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filtrateArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ContactsCellIdentifier = @"ContactsCellIdentifier";
    PWContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:ContactsCellIdentifier];
    if (!cell) {
        cell = [[PWContactsCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ContactsCellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.text = self.filtrateArray[indexPath.row].nickName;
    cell.detailText = self.filtrateArray[indexPath.row].phoneNumber;
    cell.index = indexPath.row;
    return cell;
}

//cell 高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}


#pragma mark - getter

- (UIImageView *)coverImageView {
    if (!_coverImageView) {
        _coverImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"noContacts"]];
        _coverImageView.frame = CGRectMake(0, kTopOffset, kScreenWidth, kScreenHeight - kTopOffset);
        _coverImageView.contentMode = UIViewContentModeCenter;
        _coverImageView.backgroundColor = self.view.backgroundColor;
        [self.view addSubview:_coverImageView];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, kScreenHeight * 0.5 + 50, kScreenWidth, 20)];
        label.text = @"搜索不到联系人".localized;
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = SGColorRGBA(153, 153, 153, 1);
        label.font = [UIFont systemFontOfSize:15];
        [_coverImageView addSubview:label];
        _coverImageView.alpha = 0;
        [self.view addSubview:_coverImageView];
    }
    return _coverImageView;
}
@end
