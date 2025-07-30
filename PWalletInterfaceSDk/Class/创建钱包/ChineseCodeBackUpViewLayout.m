//
//  EnglishCodeBackUpViewLayout.m
//  PWallet
//
//  Created by 陈健 on 2018/8/1.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import "ChineseCodeBackUpViewLayout.h"

@implementation ChineseCodeBackUpViewLayout

- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSArray * layoutAttributes_t = [super layoutAttributesForElementsInRect:rect];
    NSArray * layoutAttributes = [[NSArray alloc]initWithArray:layoutAttributes_t copyItems:YES];
    //用来临时存放一行的Cell数组
    NSMutableArray * layoutAttributesTemp = [[NSMutableArray alloc]init];
    for (NSUInteger index = 0; index < layoutAttributes.count ; index++) {
        
        UICollectionViewLayoutAttributes *currentAttr = layoutAttributes[index]; // 当前cell的位置信息
        UICollectionViewLayoutAttributes *previousAttr = index == 0 ? nil : layoutAttributes[index-1]; // 上一个cell 的位置信
        UICollectionViewLayoutAttributes *nextAttr = index + 1 == layoutAttributes.count ?
        nil : layoutAttributes[index+1];//下一个cell 位置信息
        
        //加入临时数组
        [layoutAttributesTemp addObject:currentAttr];
        
        CGFloat previousY = previousAttr == nil ? 0 : CGRectGetMaxY(previousAttr.frame);
        CGFloat currentY = CGRectGetMaxY(currentAttr.frame);
        CGFloat nextY = nextAttr == nil ? 0 : CGRectGetMaxY(nextAttr.frame);
        //如果当前cell是单独一行
        if (currentY != previousY && currentY != nextY){
            if ([currentAttr.representedElementKind isEqualToString:UICollectionElementKindSectionHeader] || [currentAttr.representedElementKind isEqualToString:UICollectionElementKindSectionFooter]) {
                [layoutAttributesTemp removeAllObjects];
            }else{
                [self setCellFrameWith:layoutAttributesTemp];
            }
        }
        //如果下一个cell在本行，这开始调整Frame位置
        else if( currentY != nextY) {
            [self setCellFrameWith:layoutAttributesTemp];
        }
    }
    return layoutAttributes;
}

//调整属于同一行的cell的位置frame
-(void)setCellFrameWith:(NSMutableArray*)layoutAttributes{

    CGFloat space = 14; //每个item之间的间距
    CGFloat itemWidth = (SCREENBOUNDS.size.width - 74 - 4 * 14) / 6;
    for (int i =0 ; i < layoutAttributes.count; i ++) {
        UICollectionViewLayoutAttributes * attributes = layoutAttributes[i];
        CGRect nowFrame = attributes.frame;

        nowFrame.size.width = itemWidth;
        nowFrame.size.height = itemWidth;
        
        if (i / 3 == 0 ) {
            nowFrame.origin.x = (itemWidth + space) * (i % 3);
        }else if (i / 3 == 1)
        {
            nowFrame.origin.x = (itemWidth + space) * (i % 3) + 40 + itemWidth * 3 + space * 2;
        }else if (i / 3 == 2)
        {
            nowFrame.origin.x = (itemWidth + space) * (i % 3);
        }else if (i / 3 == 3)
        {
            nowFrame.origin.x = (itemWidth + space) * (i % 3) + 40 + itemWidth * 3 + space * 2;

        }else if (i / 3 == 4)
        {
            nowFrame.origin.x = (itemWidth + space) * (i % 3);
        }

        attributes.frame = nowFrame;
    }
    [layoutAttributes removeAllObjects];
    
}

@end
