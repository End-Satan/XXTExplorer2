//
//  XXTEMasterViewController.m
//  XXTExplorer
//
//  Created by Zheng on 25/05/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#import "XXTEMasterViewController.h"
#import <LGAlertView/LGAlertView.h>
#import "XXTEMasterViewController+Notifications.h"

#import "UIView+XXTEToast.h"

#import "XXTExplorerNavigationController.h"

#ifndef APPSTORE

#import "XXTERespringAgent.h"
#import "XXTEDaemonAgent.h"

#import "XXTEUpdateHelper.h"
#import "XXTEUpdatePackage.h"
#import "XXTEUpdateAgent.h"

#endif

#ifndef APPSTORE
@interface XXTEMasterViewController () <XXTEDaemonAgentDelegate, XXTEUpdateHelperDelegate, XXTEUpdateAgentDelegate, LGAlertViewDelegate>

@property(nonatomic, assign) BOOL checkUpdateInBackground;
@property(nonatomic, weak) LGAlertView *alertView;
@property(nonatomic, strong) XXTEDaemonAgent *daemonAgent;

@property (nonatomic, strong) XXTEUpdateHelper *jsonHelper;
@property (nonatomic, strong) XXTEUpdateAgent *updateAgent;

@end
#endif

@implementation XXTEMasterViewController {
    BOOL firstTimeLoaded;
}

#pragma mark - Initializers

- (instancetype)init {
    if (self = [super init]) {
        // UITabBarController is different
        static BOOL alreadyInitialized = NO;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSAssert(NO == alreadyInitialized, @"XXTEMasterViewController is a singleton.");
            alreadyInitialized = YES;
#ifndef APPSTORE
            [self setupAgents];
#endif
            [self setupAppearance];
        });
    }
    return self;
}

- (void)setupAppearance {
    UITabBar *tabBarAppearance = [UITabBar appearanceWhenContainedIn:[self class], nil];
    [tabBarAppearance setTintColor:XXTColorDefault()];
    
    if (@available(iOS 11.0, *)) {
        self.tabBar.translucent = YES;
    } else {
        self.tabBar.translucent = NO;
    }
    
    LGAlertView *alertAppearance = [LGAlertView appearanceWhenContainedIn:[self class], nil];
    alertAppearance.coverColor = [UIColor colorWithWhite:1.0 alpha:0.25];
    XXTE_START_IGNORE_PARTIAL
    if (@available(iOS 8.0, *)) {
        alertAppearance.coverBlurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    }
    XXTE_END_IGNORE_PARTIAL
    alertAppearance.coverAlpha = 0.85;
    alertAppearance.layerShadowColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    alertAppearance.layerShadowRadius = 4.0;
    alertAppearance.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    alertAppearance.buttonsHeight = 44.0;
    alertAppearance.titleFont = [UIFont boldSystemFontOfSize:16.0];
    alertAppearance.titleTextColor = [UIColor blackColor];
    alertAppearance.messageTextColor = [UIColor blackColor];
    alertAppearance.activityIndicatorViewColor = XXTColorDefault();
    alertAppearance.progressViewProgressTintColor = XXTColorDefault();
    alertAppearance.buttonsFont = [UIFont systemFontOfSize:16.0];
    alertAppearance.buttonsTitleColor = XXTColorDefault();
    alertAppearance.buttonsBackgroundColorHighlighted = XXTColorDefault();
    alertAppearance.cancelButtonFont = [UIFont systemFontOfSize:16.0];
    alertAppearance.cancelButtonTitleColor = XXTColorDefault();
    alertAppearance.cancelButtonBackgroundColorHighlighted = XXTColorDefault();
    alertAppearance.destructiveButtonFont = [UIFont systemFontOfSize:16.0];
    alertAppearance.destructiveButtonTitleColor = XXTColorDanger();
    alertAppearance.destructiveButtonBackgroundColorHighlighted = XXTColorDanger();
    alertAppearance.progressLabelFont = [UIFont italicSystemFontOfSize:14.f];
    alertAppearance.progressLabelLineBreakMode = NSLineBreakByTruncatingHead;
    alertAppearance.dismissOnAction = NO;
    alertAppearance.buttonsIconPosition = LGAlertViewButtonIconPositionLeft;
    alertAppearance.buttonsTextAlignment = NSTextAlignmentCenter;
    if (@available(iOS 11.0, *)) {
        CGFloat bottomOffset = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
        alertAppearance.cancelButtonOffsetY = bottomOffset;
    }
    
    [XXTEToastManager setTapToDismissEnabled:YES];
    [XXTEToastManager setDefaultDuration:2.4f];
    [XXTEToastManager setQueueEnabled:NO];
    [XXTEToastManager setDefaultPosition:XXTEToastPositionCenter];
    
    XXTEToastStyle *toastStyle = [XXTEToastManager sharedStyle];
    toastStyle.backgroundColor = [UIColor colorWithWhite:0.f alpha:.6f];
    toastStyle.titleFont = [UIFont boldSystemFontOfSize:14.f];
    toastStyle.messageFont = [UIFont systemFontOfSize:14.f];
    toastStyle.activitySize = CGSizeMake(80.f, 80.f);
    toastStyle.verticalMargin = 16.f;
    toastStyle.horizontalPadding = 16.f;
    
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setFont:[UIFont systemFontOfSize:16.0]];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.selectedViewController.preferredStatusBarStyle;
}

- (BOOL)prefersStatusBarHidden {
    return self.selectedViewController.prefersStatusBarHidden;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.selectedViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.selectedViewController;
}

- (BOOL)shouldAutorotate {
    return self.selectedViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.selectedViewController.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return self.selectedViewController.preferredInterfaceOrientationForPresentation;
}

- (void)viewDidLoad {
    [super viewDidLoad];
} // do not write any stuff inside this method...

- (void)viewWillAppear:(BOOL)animated {
    [self registerNotifications];
    [super viewWillAppear:animated];
#ifndef APPSTORE
    if (!firstTimeLoaded) {
        [self launchAgents];
        firstTimeLoaded = YES;
    }
#endif
}

- (void)viewWillDisappear:(BOOL)animated {
    [self removeNotifications];
    [super viewWillDisappear:animated];
}

#pragma mark - Agents

#ifndef APPSTORE
- (void)setupAgents {
    NSString *productName = uAppDefine(@"UPDATE_PRODUCT");
    NSString *repositoryURLString = uAppDefine(@"UPDATE_API");
    NSURL *repositoryURL = [NSURL URLWithString:[NSString stringWithFormat:repositoryURLString, productName]];
    
    XXTEUpdateHelper *jsonHelper = [[XXTEUpdateHelper alloc] initWithRepositoryURL:repositoryURL];
    jsonHelper.delegate = self;
    self.jsonHelper = jsonHelper;
    
    XXTEUpdateAgent *updateAgent = [[XXTEUpdateAgent alloc] initWithBundleIdentifier:productName];
    updateAgent.delegate = self;
    self.updateAgent = updateAgent;
    
    XXTEDaemonAgent *daemonAgent = [[XXTEDaemonAgent alloc] init];
    daemonAgent.delegate = self;
    self.daemonAgent = daemonAgent;
}
#endif

#ifndef APPSTORE
- (void)launchAgents {
    BOOL shouldRespring = [XXTERespringAgent shouldPerformRespring];
    if (shouldRespring) {
        LGAlertView *alertView = [[LGAlertView alloc] initWithTitle:NSLocalizedString(@"Needs Respring", nil)
                                                            message:NSLocalizedString(@"You should respring your device to continue using this application.", nil)
                                                              style:LGAlertViewStyleAlert
                                                       buttonTitles:@[ NSLocalizedString(@"Troubleshooting", nil) ]
                                                  cancelButtonTitle:nil
                                             destructiveButtonTitle:NSLocalizedString(@"Respring Now", nil)
                                                      actionHandler:^(LGAlertView * _Nonnull alertView, NSUInteger index, NSString * _Nullable title) {
                                                          [alertView dismissAnimated];
                                                          if (index == 0) {
                                                              NSURL *faqURL = [NSURL URLWithString:uAppDefine(@"XXTOUCH_FAQ_0018")];
                                                              if (faqURL) {
                                                                  [self presentWebViewControllerWithURL:faqURL];
                                                              }
                                                          }
                                                      }
                                                      cancelHandler:nil
                                                 destructiveHandler:^(LGAlertView * _Nonnull alertView) {
                                                     [alertView dismissAnimated];
                                                     UIViewController *blockVC = blockInteractions(self, YES);
                                                     [XXTERespringAgent performRespring];
                                                     blockInteractions(blockVC, NO);
                                                 }];
        if (self.alertView && self.alertView.isShowing) {
            [self.alertView transitionToAlertView:alertView completionHandler:nil];
        } else {
            self.alertView = alertView;
            [alertView showAnimated];
        }
    } else {
        [self.daemonAgent sync];
    }
}
#endif

#pragma mark - XXTEUpdateHelperDelegate

#ifndef APPSTORE
- (void)jsonHelperDidSyncReady:(XXTEUpdateHelper *)helper {
    dispatch_async_on_main_queue(^{
        NSString *currentVersion = uAppDefine(kXXTDaemonVersionKey);
        XXTEUpdatePackage *packageModel = helper.respPackage;
        NSString *packageVersion = packageModel.latestVersion;
        NSString *packageDescription = packageModel.updateDescription;
        if ([currentVersion isEqualToString:packageVersion]) {
            if (YES == self.checkUpdateInBackground) {
                
            } else {
                LGAlertView *alertView = [[LGAlertView alloc] initWithTitle:NSLocalizedString(@"Latest Version", nil)
                                                                    message:[NSString stringWithFormat:NSLocalizedString(@"Your version v%@ is up-to-date with remote.", nil), currentVersion]
                                                                      style:LGAlertViewStyleActionSheet
                                                               buttonTitles:@[ ]
                                                          cancelButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                                     destructiveButtonTitle:nil
                                                                   delegate:self];
                if (self.alertView && self.alertView.isShowing) {
                    [self.alertView transitionToAlertView:alertView completionHandler:nil];
                } else {
                    self.alertView = alertView;
                    [alertView showAnimated];
                }
            }
            return;
        }
        BOOL shouldRemind = [self.updateAgent shouldRemindWithVersion:packageVersion];
        if (NO == self.checkUpdateInBackground || shouldRemind) {
            NSString *channelId = uAppDefine(@"CHANNEL_ID");
            LGAlertView *alertView = [[LGAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"New Version: %@", nil), packageVersion]
                                                                message:[NSString stringWithFormat:@"%@", packageDescription]
                                                                  style:LGAlertViewStyleActionSheet
                                                           buttonTitles:@[
                                                                          [NSString stringWithFormat:NSLocalizedString(@"Install via %@", nil), channelId], NSLocalizedString(@"Remind me tomorrow", nil)
                                                                          ]
                                                      cancelButtonTitle:NSLocalizedString(@"Remind me later", nil)
                                                 destructiveButtonTitle:NSLocalizedString(@"Ignore this version", nil) delegate:self];
            if (self.alertView && self.alertView.isShowing) {
                [self.alertView transitionToAlertView:alertView completionHandler:nil];
            } else {
                self.alertView = alertView;
                [alertView showAnimated];
            }
        }
    });
}
#endif

#ifndef APPSTORE
- (void)jsonHelper:(XXTEUpdateHelper *)helper didSyncFailWithError:(NSError *)error {
    dispatch_async_on_main_queue(^{
        if (NO == self.checkUpdateInBackground) {
            LGAlertView *alertView = [[LGAlertView alloc] initWithTitle:NSLocalizedString(@"Operation Failed", nil)
                                                                message:[NSString stringWithFormat:NSLocalizedString(@"Cannot check update: %@", nil), error.localizedDescription]
                                                                  style:LGAlertViewStyleActionSheet
                                                           buttonTitles:@[ ]
                                                      cancelButtonTitle:NSLocalizedString(@"Retry", nil)
                                                 destructiveButtonTitle:nil
                                                               delegate:self];
            if (self.alertView && self.alertView.isShowing) {
                [self.alertView transitionToAlertView:alertView completionHandler:nil];
            } else {
                self.alertView = alertView;
                [alertView showAnimated];
            }
        }
    });
}
#endif

#pragma mark - XXTEDaemonAgentDelegate

#ifndef APPSTORE
- (void)daemonAgentDidSyncReady:(XXTEDaemonAgent *)agent {
    if (agent == self.daemonAgent) {
        [self checkUpdateBackground];
    }
}
#endif

#ifndef APPSTORE
- (void)daemonAgent:(XXTEDaemonAgent *)agent didFailWithError:(NSError *)error {
    LGAlertView *alertView = [[LGAlertView alloc] initWithTitle:NSLocalizedString(@"Sync Failed", nil)
                                                        message:[NSString stringWithFormat:NSLocalizedString(@"Cannot sync with daemon: %@", nil), error.localizedDescription]
                                                          style:LGAlertViewStyleActionSheet
                                                   buttonTitles:@[ NSLocalizedString(@"Troubleshooting", nil) ]
                                              cancelButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                         destructiveButtonTitle:nil
                                                  actionHandler:^(LGAlertView * _Nonnull alertView, NSUInteger index, NSString * _Nullable title) {
                                                      [alertView dismissAnimated];
                                                      if (index == 0) {
                                                          NSURL *faqURL = [NSURL URLWithString:uAppDefine(@"XXTOUCH_FAQ_0017")];
                                                          if (faqURL) {
                                                              [self presentWebViewControllerWithURL:faqURL];
                                                          }
                                                      }
                                                  } cancelHandler:^(LGAlertView * _Nonnull alertView) {
                                                      [alertView dismissAnimated];
                                                  } destructiveHandler:nil];
    if (self.alertView && self.alertView.isShowing) {
        [self.alertView transitionToAlertView:alertView completionHandler:nil];
    } else {
        self.alertView = alertView;
        [alertView showAnimated];
    }
}
#endif

#pragma mark - LGAlertViewDelegate

#ifndef APPSTORE
- (void)alertView:(LGAlertView *)alertView clickedButtonAtIndex:(NSUInteger)index title:(NSString *)title {
    if (index == 0) {
        XXTEUpdateHelper *helper = self.jsonHelper;
        XXTEUpdatePackage *packageModel = helper.respPackage;
        NSString *urlString = nil;
        NSString *cydiaTemplatePath = packageModel.templatePath;
        if (cydiaTemplatePath)
        {
            NSString *cydiaURLString = uAppDefine(@"CYDIA_URL");
            if (cydiaURLString) {
                urlString = [NSString stringWithFormat:cydiaURLString, cydiaTemplatePath];
            }
        }
        else
        {
            urlString = packageModel.cydiaURLString;
        }
        if (urlString)
        {
            NSURL *cydiaUrl = [NSURL URLWithString:urlString];
            if ([[UIApplication sharedApplication] canOpenURL:cydiaUrl])
            {
                [[UIApplication sharedApplication] openURL:cydiaUrl];
            }
            else
            {
                toastMessage(self, ([NSString stringWithFormat:NSLocalizedString(@"Cannot open \"%@\".", nil), urlString]));
            }
        }
    } else if (index == 1) {
        [self.updateAgent ignoreThisDay];
    }
    [alertView dismissAnimated];
}
#endif

#ifndef APPSTORE
- (void)alertViewDestructed:(LGAlertView *)alertView {
    [alertView dismissAnimated];
    XXTEUpdateHelper *helper = self.jsonHelper;
    XXTEUpdatePackage *packageModel = helper.respPackage;
    NSString *packageVersion = packageModel.latestVersion;
    [self.updateAgent ignoreVersion:packageVersion];
    [self.updateAgent ignoreThisDay];
}
#endif

#ifndef APPSTORE
- (void)alertViewCancelled:(LGAlertView *)alertView {
    [alertView dismissAnimated];
}
#endif

#ifndef APPSTORE
- (void)checkUpdateBackground {
    self.checkUpdateInBackground = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self.jsonHelper sync];
    });
}
#endif

#ifndef APPSTORE
- (void)checkUpdate {
    self.checkUpdateInBackground = NO;
    LGAlertView *alertView = [[LGAlertView alloc] initWithActivityIndicatorAndTitle:NSLocalizedString(@"Check Update", nil)
                                                                            message:nil
                                                                              style:LGAlertViewStyleActionSheet
                                                                  progressLabelText:NSLocalizedString(@"Connect to the update server...", nil)
                                                                       buttonTitles:nil
                                                                  cancelButtonTitle:nil
                                                             destructiveButtonTitle:nil
                                                                           delegate:self];
    if (self.alertView && self.alertView.isShowing) {
        [self.alertView transitionToAlertView:alertView completionHandler:nil];
    } else {
        self.alertView = alertView;
        [alertView showAnimated];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self.jsonHelper sync];
    });
}
#endif

#pragma mark - Getters

- (XXTExplorerViewController *)topmostExplorerViewController {
    UIViewController *firstFirstVC = [self.viewControllers firstObject];
    if ([firstFirstVC isKindOfClass:[XXTExplorerNavigationController class]]) {
        XXTExplorerNavigationController *navVC = (XXTExplorerNavigationController *)firstFirstVC;
        return [navVC topmostExplorerViewController];
    }
    return nil;
}

#pragma mark - Memory

- (void)dealloc {
    
}

@end
