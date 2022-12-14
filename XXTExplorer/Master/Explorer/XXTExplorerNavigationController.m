//
//  XXTExplorerNavigationController.m
//  XXTExplorer
//
//  Created by Zheng on 26/05/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#import "XXTExplorerNavigationController.h"
#import "XXTExplorerViewController.h"


#import "XXTExplorerViewController+SharedInstance.h"

@interface XXTExplorerNavigationController ()

@end

@implementation XXTExplorerNavigationController

- (instancetype)init {
    if (self = [super init]) {
        NSAssert(NO, @"XXTExplorerNavigationController must be initialized with a rootViewController.");
    }
    return self;
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    if (self = [super initWithRootViewController:rootViewController]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    
}

#pragma mark - Life Cycle

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationBar.translucent = YES;
    self.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"My Scripts", nil) image:[UIImage imageNamed:@"XXTExplorerTabbarIcon"] tag:0];
}

#pragma mark - Memory

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"- [%@ dealloc]", NSStringFromClass([self class]));
#endif
}

#pragma mark - Convinence Getters

- (XXTExplorerViewController *)topmostExplorerViewController {
    __block XXTExplorerViewController *topmostExplorerViewController = nil;
    [self.viewControllers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[XXTExplorerViewController class]]) {
            topmostExplorerViewController = (XXTExplorerViewController *)obj;
            *stop = YES;
        }
    }];
    return topmostExplorerViewController;
}

XXTE_START_IGNORE_PARTIAL
- (NSArray <id <UIPreviewActionItem>> *)previewActionItems {
    return [[self topmostExplorerViewController] previewActionItems];
}
XXTE_END_IGNORE_PARTIAL

@end
