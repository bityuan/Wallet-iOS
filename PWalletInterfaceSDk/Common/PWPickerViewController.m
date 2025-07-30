//
//  PWPickerViewController.m
//  PWallet
//
//  Created by fzm on 2018/5/31.
//  Copyright © 2018年 fzm. All rights reserved.
//

#import "PWPickerViewController.h"
#import "SGPickView.h"

/*
 如要透明 在presentViewController前 需
 VC.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
 */

@interface PWPickerViewController ()<SGPickViewDelegate>
@property (nonatomic,weak)SGPickView *pickerView;
@end

@implementation PWPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    SGPickView *pickerView = [[SGPickView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:pickerView];
    pickerView.delegate = self;
    pickerView.datasourceArray = self.datasourceArray;
   
    self.pickerView = pickerView;
    [pickerView showAnimation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SGPickViewDelegate
//取消事件代理
- (void)pickerViewDidCancel:(SGPickView*)pickerView {
     [self dismissViewControllerAnimated:false completion:nil];
}
//确定事件代理
- (void)pickerView:(SGPickView*)pickerView didSelectRow:(NSInteger)row {
    [self dismissViewControllerAnimated:false completion:^{
        if (self.didSelectRowBlock && !IS_BLANK(self.datasourceArray)) {
            self.didSelectRowBlock(row);
        }
    }];
}


@end
