//
//  WebSheetView.h
//  PWalletInterfaceSDk
//
//  Created by 郑晨 on 2024/1/10.
//  Copyright © 2024 fzm. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef enum : NSUInteger {
    WebSheetTypeChangeAccount, // 切换账号
    WebSheetTypeRefresh, // 刷新
    WebSheetTypeCopyUrl, // 复制链接
    WebSheetTypeOpenUrl, // 在浏览器打开
    WebSheetTypeExit, // 退出
    WebSheetTypeLike, // 收藏
} WebSheetType;

typedef void(^WebSheetBlock)(WebSheetType sheetType);

@interface WebSheetView : UIView

@property (nonatomic) WebSheetBlock sheetBlock;
@property (nonatomic) WebSheetType sheetType;

- (void)showWithView:(UIView *)view;
- (instancetype)initWithFrame:(CGRect)frame isLiked:(BOOL)isLiked;
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
