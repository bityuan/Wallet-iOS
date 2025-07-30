//
//  PWPickerViewController.h
//  PWallet
//
//  Created by 陈健 on 2018/5/31.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^DidSelectRowBlock)(NSInteger);
@interface PWPickerViewController : UIViewController
/*pickerView所需的数据源**/
@property (nonatomic,copy)NSArray *datasourceArray;
/*
 pickerView选择完成后的回调 只有点击"完成"按钮后才会进行回调
 点击背景或"取消"按钮不会进行此回调
**/
@property (nonatomic,copy)DidSelectRowBlock didSelectRowBlock;
@end
