//
//  XXTPickerNavigationController.m
//  XXTPickerCollection
//
//  Created by Zheng on 29/04/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#import "XXTPickerNavigationController.h"
#import "XXTBasePicker.h"
#import "XXTPickerFactory.h"

static CGFloat const XXTPickerNavigationPreviewBarHeight = 44.f;

@interface XXTPickerNavigationController () <UINavigationControllerDelegate>

@end

@implementation XXTPickerNavigationController {
    BOOL isFirstLoaded;
}

- (UIEdgeInsets)safeAreaInsets {
    if (@available(iOS 11.0, *)) {
        return self.view.safeAreaInsets;
    } else {
        return UIEdgeInsetsZero;
    }
}

- (instancetype)init {
    if (self = [super init]) {
        [self setupAppearance];
    }
    return self;
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    if (self = [super initWithRootViewController:rootViewController]) {
        self.delegate = self;
        rootViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss)];
        [self setupAppearance];
    }
    return self;
}

- (void)setupAppearance {
    UINavigationBar *barAppearance = [UINavigationBar appearance];
    [barAppearance setTintColor:[UIColor whiteColor]];
    [barAppearance setBarTintColor:XXTE_COLOR];
    [barAppearance setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont boldSystemFontOfSize:18.f]}];
    
    UINavigationBar *navigationBarAppearance = [UINavigationBar appearanceWhenContainedIn:[self class], nil];
    [navigationBarAppearance setTintColor:[UIColor whiteColor]];
    [navigationBarAppearance setBarTintColor:XXTE_COLOR];
    [navigationBarAppearance setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont boldSystemFontOfSize:18.f]}];
    XXTE_START_IGNORE_PARTIAL
    if (@available(iOS 8.0, *)) {
        [navigationBarAppearance setTranslucent:NO];
    }
    XXTE_END_IGNORE_PARTIAL
    
    UIBarButtonItem *barButtonItemAppearance = [UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil];
    [barButtonItemAppearance setTintColor:[UIColor whiteColor]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBar.translucent = NO;
    [self.view addSubview:self.popupBar];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (!isFirstLoaded) {
        isFirstLoaded = YES;
        self.popupBar.frame = CGRectMake(0, self.view.bounds.size.height - (XXTPickerNavigationPreviewBarHeight + self.safeAreaInsets.bottom), self.view.bounds.size.width, XXTPickerNavigationPreviewBarHeight + self.safeAreaInsets.bottom);
    }
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIView Getters

- (XXTPickerPreviewBar *)popupBar {
    if (!_popupBar) {
        XXTPickerPreviewBar *popupBar = [[XXTPickerPreviewBar alloc] init];
        popupBar.userInteractionEnabled = YES;
        popupBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(previewBarTapped:)];
        [popupBar addGestureRecognizer:tapGesture];
        _popupBar = popupBar;
    }
    return _popupBar;
}

#pragma mark - Preview

- (void)previewBarTapped:(XXTPickerPreviewBar *)sender {
    
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (navigationController == self) {
        if ([viewController respondsToSelector:@selector(pickerFactory)]) {
            UIViewController *pickerController = viewController;
            [self.view bringSubviewToFront:self.popupBar];
            if ([pickerController respondsToSelector:@selector(tableView)]) {
                UITableViewController *tablePickerController = (UITableViewController *)viewController;
                UIEdgeInsets insets = tablePickerController.tableView.contentInset;
                insets.bottom = self.popupBar.bounds.size.height;
                tablePickerController.tableView.contentInset =
                tablePickerController.tableView.scrollIndicatorInsets = insets;
            }
        }
    }
    if ([viewController conformsToProtocol:@protocol(XXTBasePicker)]) {
        if (YES == self.popupBar.hidden) {
            self.popupBar.hidden = NO;
            [UIView animateWithDuration:.2f animations:^{
                self.popupBar.frame = CGRectMake(0, self.view.bounds.size.height - (XXTPickerNavigationPreviewBarHeight + self.safeAreaInsets.bottom), self.view.bounds.size.width, XXTPickerNavigationPreviewBarHeight + self.safeAreaInsets.bottom);
            } completion:^(BOOL finished) {
            }];
        }
    } else {
        if (NO == self.popupBar.hidden) {
            [UIView animateWithDuration:.2f animations:^{
                self.popupBar.frame = CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, XXTPickerNavigationPreviewBarHeight + self.safeAreaInsets.bottom);
            } completion:^(BOOL finished) {
                if (finished) self.popupBar.hidden = YES;
            }];
        }
    }
}

@end
