//
//  XXTExplorerItemPicker.m
//  XXTExplorer
//
//  Created by Zheng on 09/07/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#import "XXTExplorerItemPicker.h"

#import "XXTExplorerDefaults.h"

#import "XXTExplorerToolbar.h"
#import "XXTESwipeTableCell.h"
#import "XXTExplorerViewCell.h"
#import "XXTExplorerFooterView.h"

@interface XXTExplorerItemPicker () <XXTESwipeTableCellDelegate>

@property (nonatomic, strong) UIBarButtonItem *closeButtonItem;

@end

@implementation XXTExplorerItemPicker {
    
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.title.length == 0) {
        if (self == [self.navigationController.viewControllers firstObject] && !self.isPreviewed) {
            
        } else {
            NSString *entryPath = self.entryPath;
            if (entryPath) {
                NSString *entryName = [entryPath lastPathComponent];
                self.title = entryName;
            }
        }
    }
    
    self.navigationItem.rightBarButtonItem = nil;
    if ([self.navigationController.viewControllers firstObject] == self && !self.isPreviewed) {
        self.navigationItem.leftBarButtonItem = self.closeButtonItem;
    }
    
    if (@available(iOS 11.0, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
    
    [self.toolbar updateStatus:XXTExplorerToolbarStatusReadonly];
    [self.footerView setEmptyMode:NO];
}

- (BOOL)showsHomeSeries {
    return NO;
}

- (BOOL)shouldDisplayEntry:(XXTExplorerEntry *)entryDetail {
    NSString *entryBaseExtension = entryDetail.entryExtension;
    if (entryDetail.isBundle ||
        entryDetail.isMaskedRegular) {
        if ([self.allowedExtensions containsObject:entryBaseExtension] == NO) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == self.tableView) {
        if (XXTExplorerViewSectionIndexList == indexPath.section)
        {
            XXTExplorerEntry *entryDetail = self.entryList[indexPath.row];
            NSString *entryPath = entryDetail.entryPath;
            if (entryDetail.isMaskedDirectory)
            { // Directory or Symbolic Link Directory
                // We'd better try to access it before we enter it.
                NSError *accessError = nil;
                [self.class.explorerFileManager contentsOfDirectoryAtPath:entryPath error:&accessError];
                if (accessError) {
                    toastMessage(self, [accessError localizedDescription]);
                }
                else {
                    XXTExplorerItemPicker *explorerViewController = [[XXTExplorerItemPicker alloc] initWithEntryPath:entryPath];
                    explorerViewController.delegate = self.delegate;
                    explorerViewController.allowedExtensions = self.allowedExtensions;
                    explorerViewController.selectedBootScriptPath = self.selectedBootScriptPath;
                    [self.navigationController pushViewController:explorerViewController animated:YES];
                }
            }
            else if (
                     entryDetail.isBundle ||
                     entryDetail.isMaskedRegular
                     )
            { // Bundle or Regular
                NSString *entryBaseExtension = entryDetail.entryExtension;
                BOOL extensionPermitted = NO;
                for (NSString *obj in self.allowedExtensions) {
                    if ([entryBaseExtension isEqualToString:obj]) {
                        extensionPermitted = YES;
                        break;
                    }
                }
                if (extensionPermitted) {
                    NSString *selectedPath = entryDetail.entryPath;
                    if (_delegate && [_delegate respondsToSelector:@selector(itemPicker:didSelectItemAtPath:)]) {
                        [_delegate itemPicker:self didSelectItemAtPath:selectedPath];
                    }
                } else {
                    toastMessage(self, ([NSString stringWithFormat:NSLocalizedString(@"Allowed file extensions: %@.", nil), self.allowedExtensions]));
                }
            }
            else if (entryDetail.isBrokenSymlink)
            {
                toastMessage(self, ([NSString stringWithFormat:NSLocalizedString(@"The alias \"%@\" can't be opened because the original item can't be found.", nil), entryDetail.localizedDisplayName]));
            }
            else
            {
                toastMessage(self, NSLocalizedString(@"Only regular file, directory and symbolic link are supported.", nil));
            }
        }
        else if (XXTExplorerViewSectionIndexHome == indexPath.section)
        {
            // impossible
        }
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    // nothing to do
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView) {
        if (indexPath.section == XXTExplorerViewSectionIndexList) {
            XXTExplorerViewCell *cell = (XXTExplorerViewCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
            XXTExplorerEntry *entryDetail = self.entryList[indexPath.row];
            NSString *entryPath = entryDetail.entryPath;
            if ([entryPath isEqualToString:self.selectedBootScriptPath]) {
                cell.entryTitleLabel.textColor = XXTColorDefault();
                cell.entrySubtitleLabel.textColor = XXTColorDefault();
                cell.flagType = XXTExplorerViewCellFlagTypeSelectedBootScript;
            }
            else if ([self.selectedBootScriptPath hasPrefix:entryPath]) {
                cell.entryTitleLabel.textColor = XXTColorDefault();
                cell.entrySubtitleLabel.textColor = XXTColorDefault();
                cell.flagType = XXTExplorerViewCellFlagTypeSelectedBootScriptInside;
            }
            else {
                cell.entryTitleLabel.textColor = [UIColor blackColor];
                cell.entrySubtitleLabel.textColor = [UIColor darkGrayColor];
                cell.flagType = XXTExplorerViewCellFlagTypeNone;
            }
            cell.accessoryType = UITableViewCellAccessoryNone;
            return cell;
        }
    }
    return [UITableViewCell new];
}

- (void)setSelectedBootScriptPath:(NSString *)selectedBootScriptPath {
    _selectedBootScriptPath = selectedBootScriptPath;
    if ([self isViewLoaded]) {
        [self.tableView reloadData];
    }
}

#pragma mark - Prevent editing methods

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return NO;
}

- (BOOL)swipeTableCell:(XXTESwipeTableCell *) cell canSwipe:(XXTESwipeDirection) direction fromPoint:(CGPoint) point {
    return NO;
}

#pragma mark - UIViewController (UIViewControllerEditing)

- (BOOL)isEditing {
    return NO;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    // nothing to do
}

#pragma mark - UIView Getters

- (UIBarButtonItem *)closeButtonItem {
    if (!_closeButtonItem) {
        UIBarButtonItem *closeButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(closeButtonItemTapped:)];
        _closeButtonItem = closeButtonItem;
    }
    return _closeButtonItem;
}

#pragma mark - UIControl Actions

- (void)closeButtonItemTapped:(UIBarButtonItem *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(itemPickerDidCancelSelectingItem:)]) {
        [_delegate itemPickerDidCancelSelectingItem:self];
    }
}

#pragma mark - Item Picker Inherit

- (void)reloadFooterView {
    [self updateFooterView];
}

- (void)refreshControlTriggered:(UIRefreshControl *)refreshControl {
    [refreshControl endRefreshing];
}

- (XXTExplorerViewEntryListSortField)explorerSortField {
    return XXTEDefaultsEnum(XXTExplorerViewItemPickerSortFieldKey, XXTExplorerViewEntryListSortFieldDisplayName);
}

- (XXTExplorerViewEntryListSortOrder)explorerSortOrder {
    return XXTEDefaultsEnum(XXTExplorerViewItemPickerSortOrderKey, XXTExplorerViewEntryListSortOrderAsc);
}

- (void)setExplorerSortField:(XXTExplorerViewEntryListSortField)explorerSortField {
    XXTEDefaultsSetBasic(XXTExplorerViewItemPickerSortFieldKey, explorerSortField);
}

- (void)setExplorerSortOrder:(XXTExplorerViewEntryListSortOrder)explorerSortOrder {
    XXTEDefaultsSetBasic(XXTExplorerViewItemPickerSortOrderKey, explorerSortOrder);
}

@end
