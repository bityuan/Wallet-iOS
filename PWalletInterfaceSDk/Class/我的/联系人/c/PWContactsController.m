//
//  PWContactsController.m
//  PWallet
//  联系人主界面
//  Created by 陈健 on 2018/5/28.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import "PWContactsController.h"
#import "Masonry.h"
//#import "MGSwipeTableCell.h"
#import "PWSearchContactsController.h"
#import "PWAddContactsController.h"
#import "ContactCoinViewController.h"
#import "PWContactsDetailController.h"
#import "PWContactsTool.h"
#import "PWContacts.h"
#import "PWNavigationController.h"
#import "PWContactsCell.h"
#import "PWalletInterfaceSDk-Swift.h"


NSString * const DeleteStr = @"删除";
NSString * const ConfirmStr = @"确认删除";

@interface PWContactsController ()<UITableViewDelegate,UITableViewDataSource,MGSwipeTableCellDelegate,SectionIndexViewDelegate,SectionIndexViewDataSource>

//tableView
@property(nonatomic,weak) UITableView *tableView;
@property(nonatomic,weak) SectionIndexView *indexView;
//无联系人展示
@property(nonatomic,strong) UIView *noContactsCoverView;
@property(nonatomic,strong) NSMutableArray<NSMutableArray<PWContacts*>*> *dataArray;
@property(nonatomic,strong) NSMutableArray<NSString*> *keys;
@property(nonatomic,strong) NSArray<NSString*> *indexKeys;
//搜索
@property(nonatomic,strong) UISearchController *searchVC;
@property (nonatomic,assign) BOOL disableScrollSelect;


@end

@implementation PWContactsController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"联系人".localized;
    self.view.backgroundColor = [UIColor whiteColor];
    self.disableScrollSelect = false;
    self.indexKeys =  @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"#"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadData];
    if (!self.tableView) {
        [self initViews];
    }
    [self.tableView reloadData];
    if (self.dataArray.count == 0)
    {
        [self.view addSubview:self.noContactsCoverView];
    }
    else
    {
        [self.noContactsCoverView removeFromSuperview];
    }

    
    
}

- (void)loadData {
  

    NSArray *array = [[PWContactsTool shared] getContactsGroupByFirstCharactorOfNicknamewithArray:[[PWContactsTool shared] getAllContacts]];
    self.dataArray = [NSMutableArray array];
    self.keys = [NSMutableArray array];
    for (NSDictionary *dic in array) {
        [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [self.keys addObject:key];
            [self.dataArray addObject:[NSMutableArray arrayWithArray:obj]];
        }];
    }
    [self.tableView reloadData];
}


- (void)initViews {
    
    //顶部右侧➕按钮
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 18, 18)];
    [btn addTarget:self action:@selector(addContacts) forControlEvents:UIControlEventTouchUpInside];
    [btn setImage:[UIImage imageNamed:@"Rectangle43"] forState:UIControlStateNormal];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    //UITableView
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.tableFooterView = [[UIView alloc]init];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.showsVerticalScrollIndicator = false;
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(10);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view).offset(-23);
        make.bottom.equalTo(self.view);
    }];
    
    SectionIndexView *indexView = [[SectionIndexView alloc]initWithFrame:CGRectMake(kScreenWidth - 23, (kScreenHeight - kTopOffset - 486) * 0.5, 23, 486)];
    indexView.dataSource = self;
    indexView.delegate = self;
    indexView.isShowItemPreview = false;
    [self.view addSubview:indexView];
    [indexView reloadData];
    self.indexView = indexView;
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 48)];
    headerView.backgroundColor = [UIColor whiteColor];
    UIButton *searchButton = [[UIButton alloc]init];
    [headerView addSubview:searchButton];
    [searchButton setImage:[UIImage imageNamed:@"搜索"] forState:UIControlStateNormal];
    [searchButton setImage:[UIImage imageNamed:@"搜索"] forState:UIControlStateHighlighted];
    [searchButton setTitle:@"搜索".localized forState:UIControlStateNormal];
    searchButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [searchButton setTitleColor:SGColorFromRGB(0x8E92A3) forState:UIControlStateNormal];
    searchButton.backgroundColor = SGColorRGBA(248, 248, 250, 1);
    searchButton.layer.cornerRadius = 3;
    searchButton.layer.masksToBounds = true;
    [searchButton addTarget:self action:@selector(searchButtonPress) forControlEvents:UIControlEventTouchUpInside];
    [searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headerView);
        make.bottom.equalTo(headerView).offset(-9);
        make.left.equalTo(headerView).offset(23);
        make.right.equalTo(headerView).priorityHigh();
    }];
    tableView.tableHeaderView = headerView;
    
}

-(UIView *)noContactsCoverView {
    if (!_noContactsCoverView) {
        UIView *view = [[UIView alloc]initWithFrame:self.view.frame];
        view.backgroundColor = CMColorFromRGB(0xFFFFFF);
        UIButton *btn = [[UIButton alloc]init];
        [view addSubview:btn];
        btn.enabled = false;
        [btn setImage:[UIImage imageNamed:@"noContacts"] forState:UIControlStateNormal];
        [btn setTitle:@"您还没有添加联系人".localized forState:UIControlStateNormal];
        [btn setContentMode:UIViewContentModeScaleAspectFit];
        [btn setTitleColor:SGColorRGBA(153, 153, 153, 1) forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        CGRect rect = [btn.titleLabel.text boundingRectWithSize:CGSizeMake(kScreenWidth - 20, MAXFLOAT)
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15.f]}
                                                        context:nil];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(rect.size.width + 10);
            make.height.mas_equalTo(125);
            make.center.equalTo(view);
        }];
        
        CGFloat offset = 30;
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, -btn.imageView.frame.size.width, -btn.imageView.frame.size.height -  (offset / 2), 0);
        btn.imageEdgeInsets = UIEdgeInsetsMake(-btn.titleLabel.intrinsicContentSize.height - offset / 2, 0, 0, -btn.titleLabel.intrinsicContentSize.width);
        _noContactsCoverView = view;
    }
    return _noContactsCoverView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableView 代理和数据源

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_parentController == ContactParentMine) {
        PWContactsDetailController *detailVC = [[PWContactsDetailController alloc]init];
        detailVC.contacts = self.dataArray[indexPath.section][indexPath.row];
        [self.navigationController pushViewController:detailVC animated:true];
    }else if (_parentController == ContactParentTransfer)
    {
        PWContacts *contacts = self.dataArray[indexPath.section][indexPath.row];

        NSArray *addressArray = contacts.coinArray;
        for (int i = 0; i < addressArray.count; i ++) {
            PWContactsCoin *coin = [addressArray objectAtIndex:i];
            if ([coin.coinName isEqualToString:_transferCoinType]) {
                self.selectContact(contacts);
                [self.navigationController popViewControllerAnimated:YES];
                return;
            }
        }
        NSString *tipStr = [NSString stringWithFormat:@"联系人不存在%@地址".localized,_transferCoinType];
        [self showCustomMessage:tipStr hideAfterDelay:2.0];
        
       
    }
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray[section].count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ContactsCellIdentifier = @"ContactsCellIdentifier";
    PWContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:ContactsCellIdentifier];
    if (!cell) {
        cell = [[PWContactsCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ContactsCellIdentifier];
    }
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.text = self.dataArray[indexPath.section][indexPath.row].nickName;
    cell.detailText = self.dataArray[indexPath.section][indexPath.row].phoneNumber;
    cell.index = indexPath.row;
    
    return cell;
}


//Section Header view
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    YYLabel *headerLabel = [[YYLabel alloc]init];
    headerLabel.backgroundColor = [UIColor whiteColor];
    headerLabel.textColor = SGColorFromRGB(0x8E92A3);
    headerLabel.font = [UIFont boldSystemFontOfSize:16];
    headerLabel.textContainerInset = UIEdgeInsetsMake(0, 23, 0, 0);
    headerLabel.text = self.keys[section];
    headerLabel.textVerticalAlignment = YYTextVerticalAlignmentBottom;
    return headerLabel;
}
//Section Header 高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}
//cell 高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}
#pragma mark- MGSwipeTableCellDelegate
// 左滑删除按钮及点击
-(NSArray<UIView *> *)swipeTableCell:(MGSwipeTableCell *)cell swipeButtonsForDirection:(MGSwipeDirection)direction swipeSettings:(MGSwipeSettings *)swipeSettings expansionSettings:(MGSwipeExpansionSettings *)expansionSettings {
    if (direction == MGSwipeDirectionRightToLeft) {
        MGSwipeButton * button = [[MGSwipeButton alloc]init];
        button.buttonWidth = 91;
        button.backgroundColor = SGColorRGBA(153, 153, 153, 1);
        [button setTitle:DeleteStr.localized forState:UIControlStateNormal];
        __weak typeof(self) weakSelf = self;
        button.callback = ^BOOL(MGSwipeTableCell * _Nonnull insideCell) {
            MGSwipeButton *btn = (MGSwipeButton*)insideCell.rightButtons.firstObject;
            //"删除" ---> "确认删除"
            if ([[btn titleForState:UIControlStateNormal]  isEqual: DeleteStr.localized]) {
                [btn setTitle:ConfirmStr.localized forState:UIControlStateNormal];
                [UIView animateWithDuration:0.2 animations:^{
                    btn.backgroundColor = [UIColor redColor];
                }];
                return false;
            }
            else {
                //确认删除

                NSIndexPath *indexPath = [weakSelf.tableView indexPathForCell:insideCell];
                [[PWContactsTool shared] deleteContacts:weakSelf.dataArray[indexPath.section][indexPath.row]];
                //删除数据源中的数据
                [weakSelf.dataArray[indexPath.section] removeObjectAtIndex:indexPath.row];
                if (weakSelf.dataArray[indexPath.section].count == 0) {
                    //数组中的数组的个数为0 删除响应的数组和key
                    [weakSelf.dataArray removeObjectAtIndex:indexPath.section];
                    [weakSelf.keys removeObjectAtIndex:indexPath.section];
                    [weakSelf.tableView deleteSections:[[NSIndexSet alloc]initWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationLeft];
                }else {
                    [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                }

               
                
                
                
                
                return true;
            }
        };
        
        return @[button];
    }
    return nil;
}

//想右滑动后 将 "确认删除" 设置为 "删除"
-(void)swipeTableCellWillEndSwiping:(MGSwipeTableCell *)cell {
    MGSwipeButton *btn = (MGSwipeButton*)cell.rightButtons.firstObject;
    if ([[btn titleForState:UIControlStateNormal]  isEqual: ConfirmStr.localized]) {
        [btn setTitle:DeleteStr.localized forState:UIControlStateNormal];
         btn.backgroundColor = SGColorRGBA(153, 153, 153, 1);
    }
}

#pragma mark- 顶部右侧➕按钮点击 添加联系人
- (void)addContacts {
    PWAddContactsController *addContactsVC = [[PWAddContactsController alloc]init];
    [self.navigationController pushViewController:addContactsVC animated:true];
}
#pragma mark- 搜索联系人
- (void)searchButtonPress {
    PWSearchContactsController *vc = [[PWSearchContactsController alloc]init];
    vc.dataArray = [self.dataArray mutableCopy];
    [self.navigationController pushViewController:vc animated:true];
}

#pragma mark - ScrollViewDidScroll

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.disableScrollSelect) {
        return;
    }
    NSInteger section = self.tableView.indexPathsForVisibleRows.firstObject.section;
    if (self.indexView.currentItem != [self.indexView itemAt:section]) {
        [self.indexView selectItemAt:section];
    }
}

#pragma mark - SectionIndexView delegate datasource
- (NSInteger)numberOfItemViewsIn:(SectionIndexView *)sectionIndexView {
    return self.indexKeys.count;
}

- (SectionIndexViewItem *)sectionIndexView:(SectionIndexView *)sectionIndexView itemViewAt:(NSInteger)section {
    SectionIndexViewItem *item = [[SectionIndexViewItem alloc]init];
    item.title = self.indexKeys[section];
    item.titleFont = [UIFont boldSystemFontOfSize:11];
    item.titleColor = SGColorFromRGB(0x8E92A3);
    item.titleSelectedColor = SGColorFromRGB(0x7190FF);
    item.selectedColor = [UIColor whiteColor];
    return item;
}

- (void)sectionIndexView:(SectionIndexView *)sectionIndexView didSelect:(NSInteger)section {
    if (![self.keys containsObject:self.indexKeys[section]]) {
        return;
    }
    [sectionIndexView selectItemAt:section];
    NSInteger index = [self.keys indexOfObject:self.indexKeys[section]];
    self.disableScrollSelect = true;
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index] atScrollPosition:UITableViewScrollPositionTop animated:false];
    self.disableScrollSelect = false;
}


- (void)sectionIndexView:(SectionIndexView *)sectionIndexView toucheMoved:(NSInteger)section {
    if (![self.keys containsObject:self.indexKeys[section]]) {
        return;
    }
    [sectionIndexView selectItemAt:section];
    NSInteger index = [self.keys indexOfObject:self.indexKeys[section]];
    self.disableScrollSelect = true;
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index] atScrollPosition:UITableViewScrollPositionTop animated:false];
    self.disableScrollSelect = false;
}

@end












