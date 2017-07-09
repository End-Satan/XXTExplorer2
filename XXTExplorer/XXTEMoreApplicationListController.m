//
// Created by Zheng on 02/05/2017.
// Copyright (c) 2017 Zheng. All rights reserved.
//

#include <objc/runtime.h>
#import "XXTEMoreApplicationListController.h"
#import "LSApplicationProxy.h"
#import "LSApplicationWorkspace.h"
#import "XXTEMoreApplicationCell.h"
#import "XXTEMoreApplicationDetailController.h"
#import "UINavigationController+XXTEFullscreenPopGesture.h"

enum {
    kXXTEMoreApplicationListControllerCellSection = 0,
};

enum {
    kXXTEMoreApplicationSearchTypeName = 0,
    kXXTEMoreApplicationSearchTypeBundleID
};

CFArrayRef SBSCopyApplicationDisplayIdentifiers(bool onlyActive, bool debuggable);
CFStringRef SBSCopyLocalizedApplicationNameForDisplayIdentifier(CFStringRef displayIdentifier);
CFDataRef SBSCopyIconImagePNGDataForDisplayIdentifier(CFStringRef displayIdentifier);

@interface XXTEMoreApplicationListController ()
        <
        UITableViewDelegate,
        UITableViewDataSource,
        UISearchControllerDelegate,
        UISearchResultsUpdating,
        UIScrollViewDelegate,
        UISearchBarDelegate
        >
@property(nonatomic, strong, readonly) UITableView *tableView;
@property(nonatomic, strong, readonly) NSArray <NSDictionary *> *allApplications;
@property(nonatomic, strong, readonly) NSArray <NSDictionary *> *displayApplications;
@property(nonatomic, strong, readonly) UISearchController *searchController;
@property(nonatomic, strong, readonly) LSApplicationWorkspace *applicationWorkspace;

@end

@implementation XXTEMoreApplicationListController

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (void)setup {
//    self.hidesBottomBarWhenPushed = YES;
}

#pragma mark - Default Style

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (self.searchController.active) {
        return UIStatusBarStyleDefault;
    }
    return UIStatusBarStyleLightContent;
}

- (BOOL)xxte_prefersNavigationBarHidden {
    if (self.searchController.active) {
        return YES;
    }
    return NO;
}

- (NSString *)title {
    return NSLocalizedString(@"Applications", nil);
}

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];

    self.definesPresentationContext = YES;
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    _applicationWorkspace = ({
        Class LSApplicationWorkspace_class = objc_getClass("LSApplicationWorkspace");
        SEL selector = NSSelectorFromString(@"defaultWorkspace");
        LSApplicationWorkspace *applicationWorkspace = [LSApplicationWorkspace_class performSelector:selector];
        applicationWorkspace;
    });
    
    _allApplications = ({
        NSArray <NSString *> *applicationIdentifiers = (NSArray *)CFBridgingRelease(SBSCopyApplicationDisplayIdentifiers(false, false));
        NSMutableArray <LSApplicationProxy *> *allApplications = nil;
        if (applicationIdentifiers) {
            allApplications = [NSMutableArray arrayWithCapacity:applicationIdentifiers.count];
            [applicationIdentifiers enumerateObjectsUsingBlock:^(NSString * _Nonnull bid, NSUInteger idx, BOOL * _Nonnull stop) {
                LSApplicationProxy *proxy = [LSApplicationProxy applicationProxyForIdentifier:bid];
                [allApplications addObject:proxy];
            }];
        } else {
            SEL selectorAll = NSSelectorFromString(@"allApplications");
            allApplications = [self.applicationWorkspace performSelector:selectorAll];
        }
        NSString *whiteIconListPath = [[NSBundle mainBundle] pathForResource:@"xxte-white-icons" ofType:@"plist"];
        NSSet <NSString *> *blacklistApplications = [NSDictionary dictionaryWithContentsOfFile:whiteIconListPath][@"xxte-white-icons"];
        NSMutableArray <NSDictionary *> *filteredApplications = [NSMutableArray arrayWithCapacity:allApplications.count];
        for (LSApplicationProxy *appProxy in allApplications) {
            BOOL shouldAdd = YES;
            for (NSString *appId in blacklistApplications) {
                if ([appId isEqualToString:[appProxy applicationIdentifier]]) {
                    shouldAdd = NO;
                }
            }
            if (shouldAdd) {
                NSString *applicationBundleID = appProxy.applicationIdentifier;
                NSString *applicationBundlePath = [appProxy.resourcesDirectoryURL path];
                NSString *applicationContainerPath = nil;
                NSString *applicationName = CFBridgingRelease(SBSCopyLocalizedApplicationNameForDisplayIdentifier((__bridge CFStringRef)(applicationBundleID)));
                if (!applicationName) {
                    applicationName = appProxy.localizedName;
                }
                UIImage *applicationIconImage = [UIImage imageWithData:CFBridgingRelease(SBSCopyIconImagePNGDataForDisplayIdentifier((__bridge CFStringRef)(applicationBundleID)))];
                if (XXTE_SYSTEM_8) {
                    applicationContainerPath = [[appProxy dataContainerURL] path];
                } else {
                    applicationContainerPath = [[appProxy containerURL] path];
                }
                NSMutableDictionary *applicationDetail = [[NSMutableDictionary alloc] init];
                if (applicationBundleID) {
                    applicationDetail[kXXTEMoreApplicationDetailKeyBundleID] = applicationBundleID;
                }
                if (applicationName) {
                    applicationDetail[kXXTEMoreApplicationDetailKeyName] = applicationName;
                }
                if (applicationBundlePath) {
                    applicationDetail[kXXTEMoreApplicationDetailKeyBundlePath] = applicationBundlePath;
                }
                if (applicationContainerPath) {
                    applicationDetail[kXXTEMoreApplicationDetailKeyContainerPath] = applicationContainerPath;
                }
                if (applicationIconImage) {
                    applicationDetail[kXXTEMoreApplicationDetailKeyIconImage] = applicationIconImage;
                }
                [filteredApplications addObject:[applicationDetail copy]];
            }
        }
        filteredApplications;
    });
    
    _tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [tableView registerNib:[UINib nibWithNibName:@"XXTEMoreApplicationCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kXXTEMoreApplicationCellReuseIdentifier];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        XXTE_START_IGNORE_PARTIAL
        if (XXTE_SYSTEM_9) {
            tableView.cellLayoutMarginsFollowReadableWidth = NO;
        }
        XXTE_END_IGNORE_PARTIAL
        [self.view addSubview:tableView];
        tableView;
    });
    
    _searchController = ({
        UISearchController *searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        searchController.searchResultsUpdater = self;
        searchController.delegate = self;
        searchController.dimsBackgroundDuringPresentation = NO;
        searchController;
    });
    
    XXTE_START_IGNORE_PARTIAL
    if (XXTE_SYSTEM_9) {
        [self.searchController loadViewIfNeeded];
    }
    XXTE_END_IGNORE_PARTIAL

    self.tableView.tableHeaderView = ({
        UISearchBar *searchBar = self.searchController.searchBar;
        searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        searchBar.placeholder = NSLocalizedString(@"Search Application", nil);
        searchBar.scopeButtonTitles = @[
                                        NSLocalizedString(@"Name", nil),
                                        NSLocalizedString(@"Bundle ID", nil)
                                        ];
        searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
        searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
        searchBar.spellCheckingType = UITextSpellCheckingTypeNo;
        searchBar.backgroundColor = [UIColor whiteColor];
        searchBar.barTintColor = [UIColor whiteColor];
        searchBar.tintColor = XXTE_COLOR;
        searchBar.delegate = self;
        searchBar;
    });
}

#pragma mark - Data Source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kXXTEMoreApplicationListControllerCellSection) {
        return 66.f;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchController.active == NO) {
        if (section == kXXTEMoreApplicationListControllerCellSection) {
            return self.allApplications.count;
        }
    } else {
        if (section == kXXTEMoreApplicationListControllerCellSection) {
            return self.displayApplications.count;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XXTEMoreApplicationCell *cell = [tableView dequeueReusableCellWithIdentifier:kXXTEMoreApplicationCellReuseIdentifier];
    if (cell == nil) {
        cell = [[XXTEMoreApplicationCell alloc] initWithStyle:UITableViewCellStyleDefault
                                         reuseIdentifier:kXXTEMoreApplicationCellReuseIdentifier];
    }
    NSDictionary *applicationDetail = nil;
    if (self.searchController.active == NO) {
        if (indexPath.section == kXXTEMoreApplicationListControllerCellSection) {
            applicationDetail = self.allApplications[(NSUInteger) indexPath.row];
        }
    } else {
        if (indexPath.section == kXXTEMoreApplicationListControllerCellSection) {
            applicationDetail = self.displayApplications[(NSUInteger) indexPath.row];
        }
    }
    [cell setApplicationName:applicationDetail[kXXTEMoreApplicationDetailKeyName]];
    [cell setApplicationBundleID:applicationDetail[kXXTEMoreApplicationDetailKeyBundleID]];
    [cell setApplicationIconImage:applicationDetail[kXXTEMoreApplicationDetailKeyIconImage]];
    [cell setTintColor:XXTE_COLOR];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSDictionary *applicationDetail = nil;
    if (self.searchController.active == NO) {
        if (indexPath.section == kXXTEMoreApplicationListControllerCellSection) {
            applicationDetail = self.allApplications[(NSUInteger) indexPath.row];
        }
    } else {
        if (indexPath.section == kXXTEMoreApplicationListControllerCellSection) {
            applicationDetail = self.displayApplications[(NSUInteger) indexPath.row];
        }
    }

    XXTEMoreApplicationDetailController *applicationDetailController = [[XXTEMoreApplicationDetailController alloc] initWithStyle:UITableViewStyleGrouped];
    applicationDetailController.applicationDetail = applicationDetail;
    [self.navigationController pushViewController:applicationDetailController animated:YES];
}

#pragma mark - UISearchControllerDelegate

- (void)willPresentSearchController:(UISearchController *)searchController {
//    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
//    self.navigationController.xxte_fullscreenPopGestureRecognizer.enabled = NO;
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    
}

- (void)didDismissSearchController:(UISearchController *)searchController {
//    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
//    self.navigationController.xxte_fullscreenPopGestureRecognizer.enabled = YES;
}

#pragma mark - UISearchResultsUpdating

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self reloadSearchByContent:searchText andCategory:searchBar.selectedScopeButtonIndex];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    [self reloadSearchByContent:searchBar.text andCategory:searchBar.selectedScopeButtonIndex];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.tableView setContentOffset:CGPointMake(0.0f, -self.tableView.contentInset.top) animated:NO];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    [self reloadSearchByContent:searchController.searchBar.text andCategory:searchController.searchBar.selectedScopeButtonIndex];
}

- (void)reloadSearchByContent:(NSString *)searchText andCategory:(NSUInteger)category {
    NSPredicate *predicate = nil;
    if (category == kXXTEMoreApplicationSearchTypeName) {
        predicate = [NSPredicate predicateWithFormat:@"kXXTEMoreApplicationDetailKeyName CONTAINS[cd] %@", searchText];
    } else if (category == kXXTEMoreApplicationSearchTypeBundleID) {
        predicate = [NSPredicate predicateWithFormat:@"kXXTEMoreApplicationDetailKeyBundleID CONTAINS[cd] %@", searchText];
    }
    if (predicate) {
        _displayApplications = [[NSArray alloc] initWithArray:[self.allApplications filteredArrayUsingPredicate:predicate]];
    }
    [self.tableView reloadData];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.searchController.searchBar.text.length == 0) {
        [self.searchController setActive:NO];
    } else {
        [self.searchController.searchBar resignFirstResponder];
    }
}

#pragma mark - Memory

- (void)dealloc {
    [self.searchController.view removeFromSuperview];
#ifdef DEBUG
    NSLog(@"[XXTEMoreApplicationListController dealloc]");
#endif
}

@end