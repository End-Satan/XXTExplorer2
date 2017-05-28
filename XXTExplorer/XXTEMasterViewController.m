//
//  XXTEMasterViewController.m
//  XXTExplorer
//
//  Created by Zheng on 25/05/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#import "XXTEMasterViewController.h"

@interface XXTEMasterViewController ()

@end

@implementation XXTEMasterViewController

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.selectedViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.selectedViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UITabBar appearanceWhenContainedIn:[self class], nil] setTintColor:XXTE_COLOR];
}

@end
