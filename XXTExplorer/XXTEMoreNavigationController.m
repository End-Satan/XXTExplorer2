//
//  XXTEMoreNavigationController.m
//  XXTExplorer
//
//  Created by Zheng on 26/05/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#import "XXTEMoreNavigationController.h"

@interface XXTEMoreNavigationController ()

@end

@implementation XXTEMoreNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"More", nil) image:[UIImage imageNamed:@"XXTEMoreTabbarIcon"] tag:1];
}

@end
