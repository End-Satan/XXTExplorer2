//
//  XXTEMoreUserDefaultsOperationController.m
//  XXTExplorer
//
//  Created by Zheng on 08/07/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#import "XXTEMoreUserDefaultsOperationController.h"
#import "XXTEMoreLinkNoIconCell.h"
#import "XXTEDispatchDefines.h"

@interface XXTEMoreUserDefaultsOperationController ()

@end

@implementation XXTEMoreUserDefaultsOperationController

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    XXTE_START_IGNORE_PARTIAL
    if (@available(iOS 8.0, *)) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    }
    XXTE_END_IGNORE_PARTIAL
    
    self.title = self.userDefaultsEntry[@"title"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([XXTEMoreLinkNoIconCell class]) bundle:[NSBundle mainBundle]] forCellReuseIdentifier:XXTEMoreLinkNoIconCellReuseIdentifier];
    
    XXTE_START_IGNORE_PARTIAL
    if (@available(iOS 9.0, *)) {
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    XXTE_END_IGNORE_PARTIAL
    
    if (@available(iOS 11.0, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return ((NSArray *)self.userDefaultsEntry[@"options"]).count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return [self tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView) {
        return 44.f;
    }
    return 44.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUInteger selectedOperation = (NSUInteger)indexPath.row;
    if (_delegate && [_delegate respondsToSelector:@selector(userDefaultsOperationController:operationSelectedWithIndex:completion:)]) {
        @weakify(self);
        [_delegate userDefaultsOperationController:self operationSelectedWithIndex:selectedOperation completion:^(BOOL succeed) {
            @strongify(self);
            if (succeed) {
                self.selectedOperation = selectedOperation;
                for (UITableViewCell *cell in tableView.visibleCells) {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                UITableViewCell *selectCell = [tableView cellForRowAtIndexPath:indexPath];
                selectCell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XXTEMoreLinkNoIconCell *cell = [tableView dequeueReusableCellWithIdentifier:XXTEMoreLinkNoIconCellReuseIdentifier];
    if ((NSUInteger) indexPath.row == self.selectedOperation) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.titleLabel.text = ((NSArray *)self.userDefaultsEntry[@"options"])[(NSUInteger) indexPath.row];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return self.userDefaultsEntry[@"description"];
    }
    return @"";
}

#pragma mark - Memory

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"- [XXTEMoreUserDefaultsOperationController dealloc]");
#endif
}

@end