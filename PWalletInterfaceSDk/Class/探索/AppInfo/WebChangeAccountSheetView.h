//
//  WebChangeAccountSheetView.h
//  PWalletInterfaceSDk
//
//  Created by 郑晨 on 2024/1/11.
//  Copyright © 2024 fzm. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^WebChangeAccountSheetViewBlock)(LocalWallet *wallet);

@interface WebChangeAccountSheetView : UIView

@property (nonatomic) WebChangeAccountSheetViewBlock changeBlock;

- (void)showWithView:(UIView *)view;
- (void)dismiss;
@end

NS_ASSUME_NONNULL_END
