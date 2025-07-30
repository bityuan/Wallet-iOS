//
//  EnglishCodeBackUpView.m
//  PWallet
//
//  Created by 宋刚 on 2018/5/24.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import "EnglishCodeBackUpView.h"
#import "EnglishCodeBackUpViewLayout.h"

@interface EnglishCodeBackUpView()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
/**collectionView*/
@property (nonatomic,strong) UICollectionView *collectionView;
/**数据源*/
@property (nonatomic,strong) NSMutableArray *dataArray;

@end

NSString *const EnglishBackUpViewReuseIdentifier = @"EnglishBackUpViewReuseIdentifier";

@implementation EnglishCodeBackUpView

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dataArray = [NSMutableArray array];
        self.backgroundColor = CodeBgColor;
        [self initCollectionView];
    }
    return self;
}

#pragma mark - 初始化 collectionView
- (void)initCollectionView {
    UICollectionViewFlowLayout *layout = [[EnglishCodeBackUpViewLayout alloc]init];
    layout.minimumLineSpacing = 9;
    layout.minimumInteritemSpacing = 10;
    
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.contentInset = UIEdgeInsetsMake(16, 17, 16, 17);
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.scrollEnabled = false;
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:EnglishBackUpViewReuseIdentifier];
    self.collectionView = collectionView;
    [self addSubview:collectionView];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    //添加长按手势
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(lonePressMoving:)];
    longPress.minimumPressDuration = 0.2;
    [self.collectionView addGestureRecognizer:longPress];
    
}

#pragma mark - 长按移动手势
- (void)lonePressMoving:(UILongPressGestureRecognizer *)longPress
{
    if (@available(iOS 9.0, *)) {
        switch (longPress.state) {
            case UIGestureRecognizerStateBegan: {
                {
                    NSIndexPath *selectIndexPath = [self.collectionView indexPathForItemAtPoint:[longPress locationInView:self.collectionView]];
                    [self.collectionView beginInteractiveMovementForItemAtIndexPath:selectIndexPath];
                }
                break;
            }
            case UIGestureRecognizerStateChanged: {
                [self.collectionView updateInteractiveMovementTargetPosition:[longPress locationInView:longPress.view]];
                break;
            }
            case UIGestureRecognizerStateEnded: {
                [self.collectionView endInteractiveMovement];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    //直接使用  [self.collectionView reloadData];会存在bug 
                    //所以选择移除后再重新initCollectionView
                    [self.collectionView removeFromSuperview];
                    [self initCollectionView];
                });
                break;
            }
            default: [self.collectionView cancelInteractiveMovement];
                break;
        }
    }
}

#pragma mark - 增加和删除
- (void)addItem:(NSString *)itemStr
{
    [self.dataArray addObject:itemStr];
    [self.collectionView reloadData];
}

/**
 * 删除Item
 */
- (void)deleteItem:(NSInteger)index {
    if (index >= self.dataArray.count) {
        return;
    }
    if (self.cancelSelectItem) {
        self.cancelSelectItem(self.dataArray[index]);
        [self.dataArray removeObjectAtIndex:index];
        [self.collectionView reloadData];
    }
}

- (NSString *)getEnglishCode
{
    NSMutableString *str = [@"" mutableCopy];
    for (int i = 0; i < self.dataArray.count; i ++) {
        NSString *item = [self.dataArray objectAtIndex:i];
        [str appendString:item];
        if (i != self.dataArray.count - 1) {
            [str appendString:@" "];
        }
    }
    return str;
}

- (NSInteger)getEnglishCodeCount
{
    return self.dataArray.count;
}


#pragma mark - UICollectionView 代理方法

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self deleteItem:indexPath.row];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:EnglishBackUpViewReuseIdentifier forIndexPath:indexPath];
    for (UIView *view in cell.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            [view removeFromSuperview];
        }
    }
    UILabel *label = [[UILabel alloc]initWithFrame:cell.bounds];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = CMColorFromRGB(0x4E5370);
    label.textColor = CMColorFromRGB(0xFFFFFF);
    label.layer.cornerRadius = 3;
//    label.layer.borderColor = LineColor.CGColor;
//    label.layer.borderWidth = 1;
    label.layer.masksToBounds = true;
    label.font = CMTextFont18;
    [cell addSubview:label];
    label.text = self.dataArray[indexPath.row];

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *attributes = @{NSFontAttributeName:CMTextFont18};
    CGSize itemSize = [self.dataArray[indexPath.row] boundingRectWithSize:CGSizeMake(MAXFLOAT, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    CGSize size = CGSizeMake(itemSize.width + 20, itemSize.height + 15);
    return size;
}

// 移动
- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    return true;
}
- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSString *str = self.dataArray[sourceIndexPath.row];
    [self.dataArray removeObjectAtIndex:sourceIndexPath.row];
    [self.dataArray insertObject:str atIndex:destinationIndexPath.row];
}
@end
