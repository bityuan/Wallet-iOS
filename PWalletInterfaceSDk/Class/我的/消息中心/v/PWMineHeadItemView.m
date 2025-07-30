//
//  PWMineHeadItemView.m
//  PWallet
//
//  Created by 郑晨 on 2019/12/13.
//  Copyright © 2019 陈健. All rights reserved.
//

#import "PWMineHeadItemView.h"
#import "PWMineHeadItemCell.h"


#define identity @"mineheaditemcell"

@interface PWMineHeadItemView()
<UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation PWMineHeadItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self createView];
        
    }
    
    return self;
}


- (void)createView
{
    [self addSubview:self.collectionView];
}

#pragma mark - UICollectionView Delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PWMineHeadItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identity forIndexPath:indexPath];
    if (!cell) {
        cell = [[PWMineHeadItemCell alloc] init];
    }
    cell.itemImageView.image = [UIImage imageNamed: [_dataArray[indexPath.item] objectForKey:@"icon"]];
    cell.titleLab.text = [NSString stringWithFormat:@"%@",[_dataArray[indexPath.item] objectForKey:@"name"]];
    cell.hotImageView.hidden = YES;
    if ([cell.titleLab.text isEqualToString:@"邀请有礼".localized]) {
        cell.hotImageView.hidden = NO;
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(((kScreenWidth - 30) / _dataArray.count), 100);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *itemStr = [_dataArray[indexPath.item] objectForKey:@"name"];
    if (_mineHeadItemViewBlock) {
        _mineHeadItemViewBlock(itemStr);
    }
}



#pragma mark - getter and setter

- (void)setDataArray:(NSArray *)dataArray
{
    _dataArray = dataArray;
    
    [self.collectionView reloadData];
}

- (UICollectionView *)collectionView
{
    if (!_collectionView)
    {
        UICollectionViewFlowLayout *flowlayout = [[UICollectionViewFlowLayout alloc] init];
        flowlayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowlayout.minimumLineSpacing = 0;
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth - 30, 100) collectionViewLayout:flowlayout];
        collectionView.backgroundColor = UIColor.whiteColor;
        collectionView.delegate = self;
        collectionView.dataSource = self;
        _collectionView = collectionView;
        _collectionView.alwaysBounceHorizontal = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.scrollEnabled = NO;
        _collectionView.layer.cornerRadius = 8.f;
        
        [_collectionView registerClass:[PWMineHeadItemCell class] forCellWithReuseIdentifier:identity];
    }
    return _collectionView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
