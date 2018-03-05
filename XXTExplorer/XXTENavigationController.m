//
//  XXTENavigationController.m
//  XXTExplorer
//
//  Created by Zheng on 25/05/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#import "XXTENavigationController.h"

@interface XXTENavigationController ()

@end

@implementation XXTENavigationController

- (instancetype)init {
    if (self = [super init]) {
        [self setupAppearance];
    }
    return self;
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    if (self = [super initWithRootViewController:rootViewController]) {
        [self setupAppearance];
    }
    return self;
}

- (void)setupAppearance {
    UINavigationBar *barAppearance = [UINavigationBar appearance];
    [barAppearance setTintColor:[UIColor whiteColor]];
    [barAppearance setBarTintColor:XXTColorDefault()];
    [barAppearance setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont boldSystemFontOfSize:18.f] }];
    if (@available(iOS 11.0, *)) {
        [barAppearance setLargeTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont boldSystemFontOfSize:24.f] }];
        [barAppearance setPrefersLargeTitles:YES];
    }

    UINavigationBar *navigationBarAppearance = [UINavigationBar appearanceWhenContainedIn:[self class], nil];
    [navigationBarAppearance setTintColor:[UIColor whiteColor]];
    [navigationBarAppearance setBarTintColor:XXTColorDefault()];
    [navigationBarAppearance setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont boldSystemFontOfSize:18.f]}];
    if (@available(iOS 11.0, *)) {
        [navigationBarAppearance setTranslucent:YES];
    } else if (@available(iOS 8.0, *)) {
        [navigationBarAppearance setTranslucent:NO];
    }

    UIBarButtonItem *barButtonItemAppearance = [UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil];
    [barButtonItemAppearance setTintColor:[UIColor whiteColor]];
    [barButtonItemAppearance setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont systemFontOfSize:17.0] } forState:UIControlStateNormal];
    [barButtonItemAppearance setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.3], NSFontAttributeName: [UIFont systemFontOfSize:17.0] } forState:UIControlStateDisabled];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.topViewController.preferredStatusBarStyle;
}

- (BOOL)prefersStatusBarHidden {
    return self.topViewController.prefersStatusBarHidden;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.topViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(iOS 11.0, *)) {
        self.navigationBar.translucent = YES;
    } else {
        self.navigationBar.translucent = NO;
    }
}

@end
