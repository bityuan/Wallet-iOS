//
//  SGPickView.m
//  PWallet
//
//  Created by 宋刚 on 2018/3/16.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import "SGPickView.h"

CGFloat backgroundViewHeight = 312;
CGFloat topBgViewHeight = 60;

@interface SGPickView()<UIGestureRecognizerDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,assign)NSInteger selectedIndex;
@property(nonatomic,strong) UIView *backgroundView;
@property(nonatomic,strong) UIButton *closeBtn;
@property(nonatomic,strong) UILabel *titleLab;
@property(nonatomic,strong) UITableView *tableView;

@end
@implementation SGPickView



- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cancelGesture)];
        ges.delegate = self;
        [self addGestureRecognizer:ges];
        [self createViewComponent];
    }
    return self;
}

// 手势  点击半透明背景
- (void)cancelGesture {
    [self hideAnimation:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(pickerViewDidCancel:)]) {
            [self.delegate pickerViewDidCancel:self];
        }
    }];
    
}


//动画展示分享视图
- (void)showAnimation {
    [self layoutIfNeeded];
    [UIView animateWithDuration:0.3 animations:^{
        self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.6];
        [self.backgroundView  mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_bottom).offset(-backgroundViewHeight - kIphoneXBottomOffset);
        }];
        [self layoutIfNeeded];
    }];
}


//动画隐藏分享视图
- (void)hideAnimation:(void(^)(void))completion {
    
    [UIView animateWithDuration:0.2 animations:^{
        self.backgroundColor = [UIColor clearColor];
        [self.backgroundView  mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_bottom);
        }];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        completion();
    }];
}

- (void)setDatasourceArray:(NSArray *)datasourceArray
{
    _datasourceArray = datasourceArray;
    [self.tableView reloadData];
    if (datasourceArray.count * 50 + topBgViewHeight > backgroundViewHeight) {
        self.tableView.scrollEnabled = true;
    }
}


#pragma mark -创建视图组件
- (void)createViewComponent {
    
    UIView *backgroundView = [[UIView alloc] init];
    backgroundView.backgroundColor = [UIColor whiteColor];
    [self addSubview:backgroundView];
    self.backgroundView = backgroundView;
    
    [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(backgroundViewHeight + kIphoneXBottomOffset);
        make.left.equalTo(self);
        make.width.mas_equalTo(kScreenWidth);
        make.top.equalTo(self.mas_bottom);
    }];
  
    UIView *topBgView = [[UIView alloc] init];
    topBgView.backgroundColor = SGColorRGBA(243, 243, 243, 1);
    [self.backgroundView addSubview:topBgView];
    [topBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backgroundView);
        make.right.equalTo(self.backgroundView);
        make.top.equalTo(self.backgroundView);
        make.height.mas_equalTo(topBgViewHeight);
    }];
    
    UIButton *closeBtn = [[UIButton alloc] init];
    [closeBtn setTitle:@"取消".localized forState:UIControlStateNormal];
    [closeBtn setTitleColor:SGColorRGBA(102, 102, 102, 1) forState:UIControlStateNormal];
    closeBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [closeBtn addTarget:self action:@selector(cancelGesture) forControlEvents:UIControlEventTouchUpInside];
    [topBgView addSubview:closeBtn];
    self.closeBtn = closeBtn;
    
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topBgView).offset(20);
        make.left.equalTo(topBgView).offset(15);
        make.height.mas_equalTo(21);
    }];
    
    UILabel *titleLab = [[UILabel alloc] init];
    titleLab.text = @"请选择币种".localized;
    titleLab.textColor = TextColor51;
    titleLab.font = [UIFont boldSystemFontOfSize:17];
    titleLab.textAlignment = NSTextAlignmentCenter;
    [topBgView addSubview:titleLab];
    self.titleLab = titleLab;
    CGRect rect = [titleLab.text boundingRectWithSize:CGSizeMake(kScreenWidth - 100, MAXFLOAT)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}
                                              context:nil];
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(24);
        make.width.mas_equalTo(rect.size.width + 10);
        make.centerX.equalTo(topBgView.mas_centerX);
        make.top.equalTo(topBgView).offset(18);
    }];
    
    //UITableView
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.backgroundView addSubview:tableView];
    self.tableView = tableView;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.layoutMargins = UIEdgeInsetsZero;
    tableView.backgroundColor = self.backgroundView.backgroundColor;
    tableView.tableFooterView = [[UIView alloc]init];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.showsVerticalScrollIndicator = false;
    self.tableView.scrollEnabled = false;
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topBgView.mas_bottom);
        make.left.right.equalTo(self.backgroundView);
        make.bottom.equalTo(self.backgroundView).offset(-kIphoneXBottomOffset);
    }];
}

#pragma mark -UIGestureRecognizerDelegate
//只让self响应手势  屏蔽掉子视图响应手势
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isEqual:self]) {
        return true;
    }
    return false;
}

#pragma mark - UITableView  datasource delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self hideAnimation:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(pickerView:didSelectRow:)]) {
            [self.delegate pickerView:self didSelectRow:indexPath.row];
        }
    }];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1 ;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datasourceArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.layoutMargins = UIEdgeInsetsZero;
        UILabel *label = [[UILabel alloc]init];
        [cell addSubview:label];
        label.tag = 1323;
        label.font = [UIFont systemFontOfSize:18];
        label.textColor = SGColorRGBA(51, 54, 73, 1);
        label.textAlignment = NSTextAlignmentCenter;
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(cell);
        }];
    }
    UILabel *label = (UILabel*)[cell viewWithTag:1323];
    label.text = self.datasourceArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}
@end
