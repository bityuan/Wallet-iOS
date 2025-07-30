//
//  PWNavigationController.m
//  PWallet
//
//  Created by 陈健 on 2018/5/29.
//  Copyright © 2018年 陈健. All rights reserved.
//

#import "PWNavigationController.h"

@interface PWNavigationController ()

@end

@implementation PWNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
}

@end
