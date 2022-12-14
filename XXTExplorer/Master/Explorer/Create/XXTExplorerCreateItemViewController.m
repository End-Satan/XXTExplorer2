//
//  XXTExplorerCreateItemViewController.m
//  XXTExplorer
//
//  Created by Zheng on 11/06/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#import <sys/stat.h>
#import <PromiseKit/PromiseKit.h>
#import "XXTExplorerCreateItemViewController.h"

// Views
#import "XXTExplorerItemNameCell.h"
#import "XXTEMoreTitleDescriptionCell.h"
#import "XUIViewShaker.h"
#import "XXTEMoreAddressCell.h"
#import "XXTEMoreLinkCell.h"

// Defaults
#import "XXTEAppDefines.h"
#import "XXTExplorerDefaults.h"

// Helpers
#import "XXTEEncodingHelper.h"
#import "UIControl+BlockTarget.h"
#import "NSString+Template.h"

// Children
#import "XXTExplorerItemPicker.h"


typedef enum : NSUInteger {
    kXXTExplorerCreateItemViewSectionIndexName = 0,
    kXXTExplorerCreateItemViewSectionIndexType,
    kXXTExplorerCreateItemViewSectionIndexLocation,
    kXXTExplorerCreateItemViewSectionIndexMax
} kXXTExplorerCreateItemViewSectionIndex;
typedef enum : NSUInteger {
    kXXTExplorerCreateItemViewItemTypeTemplate = 0,
    kXXTExplorerCreateItemViewItemTypeLUA,
    kXXTExplorerCreateItemViewItemTypeTXT,
    kXXTExplorerCreateItemViewItemTypeFIL,
    kXXTExplorerCreateItemViewItemTypeDIR,
} kXXTExplorerCreateItemViewItemType;

@interface XXTExplorerCreateItemViewController () <UITextFieldDelegate, XXTExplorerItemPickerDelegate>

@property (nonatomic, strong) UIBarButtonItem *closeButtonItem;
@property (nonatomic, strong) UIBarButtonItem *doneButtonItem;
@property (nonatomic, strong) UITextField *nameField;
@property (nonatomic, assign) kXXTExplorerCreateItemViewItemType selectedItemType;
@property (nonatomic, strong) XUIViewShaker *itemNameShaker;
@property (nonatomic, assign) BOOL editingUponCreating;
@property (nonatomic, strong) NSString *selectedTemplatePath;
@property (nonatomic, strong) XXTEMoreTitleDescriptionCell *templateCell;

@end

@implementation XXTExplorerCreateItemViewController {
    NSArray <NSArray <UITableViewCell *> *> *staticCells;
    NSArray <NSString *> *staticSectionTitles;
    NSArray <NSString *> *staticSectionFooters;
    NSArray <NSNumber *> *staticSectionRowNum;
}

+ (NSDateFormatter *)itemTemplateDateFormatter {
    static NSDateFormatter *itemTemplateDateFormatter = nil;
    if (!itemTemplateDateFormatter) {
        itemTemplateDateFormatter = ({
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
            [dateFormatter setDateStyle:NSDateFormatterShortStyle];
            [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:XXTE_STANDARD_LOCALE]];
            dateFormatter;
        });
    }
    return itemTemplateDateFormatter;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (instancetype) initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithEntryPath:(NSString *)entryPath {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        _entryPath = entryPath;
        [self setup];
    }
    return self;
}

- (void)setup {
    _editingUponCreating = YES;
    if (self.selectedTemplatePath != nil) {
        BOOL templateExists = [[NSFileManager defaultManager] fileExistsAtPath:self.selectedTemplatePath];
        if (templateExists) {
            _selectedItemType = kXXTExplorerCreateItemViewItemTypeTemplate;
        } else {
            _selectedItemType = kXXTExplorerCreateItemViewItemTypeLUA;
        }
    } else {
        _selectedItemType = kXXTExplorerCreateItemViewItemTypeLUA;
    }
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.tableView.style == UITableViewStylePlain) {
        self.view.backgroundColor = XXTColorPlainBackground();
    } else {
        self.view.backgroundColor = XXTColorGroupedBackground();
    }
    
    XXTE_START_IGNORE_PARTIAL
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    XXTE_END_IGNORE_PARTIAL
    
    self.title = NSLocalizedString(@"Create Item", nil);
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    XXTE_START_IGNORE_PARTIAL
    self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    XXTE_END_IGNORE_PARTIAL
    
    if ([self.navigationController.viewControllers firstObject] == self) {
        self.navigationItem.leftBarButtonItem = self.closeButtonItem;
    }
    self.navigationItem.rightBarButtonItem = self.doneButtonItem;
    
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    
    [self reloadStaticTableViewData];
    [self reloadTemplatePathDisplay];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![self.nameField isFirstResponder]) {
        [self.nameField becomeFirstResponder];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChangeWithNotificaton:) name:UITextFieldTextDidChangeNotification object:self.nameField];
    }
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    [super viewWillDisappear:animated];
}

- (void)reloadStaticTableViewData {
    NSInteger encodingIndex = XXTEDefaultsInt(XXTExplorerDefaultEncodingKey, 0);
    CFStringEncoding encoding = [XXTEEncodingHelper encodingAtIndex:encodingIndex];
    NSString *encodingName = [XXTEEncodingHelper encodingNameForEncoding:encoding];
    
    staticSectionTitles = @[ NSLocalizedString(@"Filename", nil),
                             NSLocalizedString(@"Type", nil),
                             NSLocalizedString(@"Location", nil),
                             ];
    staticSectionFooters = @[ [NSString stringWithFormat:NSLocalizedString(@"Default Encoding: %@", nil), encodingName], @"", @"" ];
    
    XXTExplorerItemNameCell *cell1 = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([XXTExplorerItemNameCell class]) owner:nil options:nil] lastObject];
    cell1.nameField.delegate = self;
    self.nameField = cell1.nameField;
    self.itemNameShaker = [[XUIViewShaker alloc] initWithView:self.nameField];
    
    XXTEMoreLinkCell *cell1_2 = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([XXTEMoreLinkCell class]) owner:nil options:nil] lastObject];
    cell1_2.titleLabel.text = NSLocalizedString(@"Edit Upon Creating", nil);
    cell1_2.accessoryType = self.editingUponCreating ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    XXTEMoreTitleDescriptionCell *cell2_0 = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([XXTEMoreTitleDescriptionCell class]) owner:nil options:nil] lastObject];
    cell2_0.accessoryType = self.selectedTemplatePath == nil ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryCheckmark;
    cell2_0.titleLabel.text = NSLocalizedString(@"Generate From Template...", nil);
    cell2_0.descriptionLabel.text = @"...";
    cell2_0.descriptionLabel.lineBreakMode = NSLineBreakByTruncatingHead;
    _templateCell = cell2_0;
    
    XXTEMoreTitleDescriptionCell *cell2 = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([XXTEMoreTitleDescriptionCell class]) owner:nil options:nil] lastObject];
    cell2.accessoryType = UITableViewCellAccessoryNone;
    cell2.titleLabel.text = NSLocalizedString(@"Regular Lua File", nil);
    cell2.descriptionLabel.text = NSLocalizedString(@"A empty regular lua file. (text/lua)", nil);
    
    XXTEMoreTitleDescriptionCell *cell3 = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([XXTEMoreTitleDescriptionCell class]) owner:nil options:nil] lastObject];
    cell3.accessoryType = UITableViewCellAccessoryNone;
    cell3.titleLabel.text = NSLocalizedString(@"Regular Text File", nil);
    cell3.descriptionLabel.text = NSLocalizedString(@"An empty regular text file. (text/plain)", nil);
    
    XXTEMoreTitleDescriptionCell *cell4 = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([XXTEMoreTitleDescriptionCell class]) owner:nil options:nil] lastObject];
    cell4.accessoryType = UITableViewCellAccessoryNone;
    cell4.titleLabel.text = NSLocalizedString(@"Regular File", nil);
    cell4.descriptionLabel.text = NSLocalizedString(@"An empty regular file.", nil);
    
    XXTEMoreTitleDescriptionCell *cell5 = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([XXTEMoreTitleDescriptionCell class]) owner:nil options:nil] lastObject];
    cell5.accessoryType = UITableViewCellAccessoryNone;
    cell5.titleLabel.text = NSLocalizedString(@"Directory", nil);
    cell5.descriptionLabel.text = NSLocalizedString(@"A directory with nothing inside.", nil);
    
    XXTEMoreAddressCell *cell6 = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([XXTEMoreAddressCell class]) owner:nil options:nil] lastObject];
    cell6.addressLabel.text = self.entryPath;
    
    staticCells = @[
                    @[ cell1, cell1_2 ],
                    @[ cell2_0, cell2, cell3, cell4, cell5 ],
                    @[ cell6 ],
                    ];
}

- (void)reloadTemplatePathDisplay {
    self.templateCell.descriptionLabel.text =
    (self.selectedTemplatePath == nil || self.selectedItemType != kXXTExplorerCreateItemViewItemTypeTemplate) ? NSLocalizedString(@"Tap here to select a template", nil) : XXTTiledPath(self.selectedTemplatePath);
}

#pragma mark - Getters

- (BOOL)editImmediately {
    return (_editingUponCreating &&
            (
             self.selectedItemType == kXXTExplorerCreateItemViewItemTypeLUA ||
             self.selectedItemType == kXXTExplorerCreateItemViewItemTypeTXT ||
             self.selectedItemType == kXXTExplorerCreateItemViewItemTypeTemplate
             ));
}

- (NSString *)selectedTemplatePath {
    return XXTEDefaultsObject(XXTExplorerCreateItemTemplatePathKey, nil);
}

#pragma mark - Setters

- (void)setSelectedTemplatePath:(NSString *)selectedTemplatePath {
    XXTEDefaultsSetObject(XXTExplorerCreateItemTemplatePathKey, selectedTemplatePath);
}

#pragma mark - UIView Getters

- (UIBarButtonItem *)closeButtonItem {
    if (!_closeButtonItem) {
        UIBarButtonItem *closeButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissViewController:)];
        closeButtonItem.tintColor = XXTColorTint();
        _closeButtonItem = closeButtonItem;
    }
    return _closeButtonItem;
}

- (UIBarButtonItem *)doneButtonItem {
    if (!_doneButtonItem) {
        UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(submitViewController:)];
        doneButtonItem.tintColor = XXTColorTint();
        doneButtonItem.enabled = NO;
        _doneButtonItem = doneButtonItem;
    }
    return _doneButtonItem;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return kXXTExplorerCreateItemViewSectionIndexMax;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        return staticCells[(NSUInteger) section].count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (tableView == self.tableView) {
        if (indexPath.section == kXXTExplorerCreateItemViewSectionIndexName) {
            if (indexPath.row == 0) {
                return 52.f;
            }
        } else if (indexPath.section == kXXTExplorerCreateItemViewSectionIndexType) {
            return 66.f;
        }
    }
    return 44.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView) {
        if (indexPath.section == kXXTExplorerCreateItemViewSectionIndexName) {
            if (indexPath.row == 0) {
                return 52.f;
            }
        }
        else if (indexPath.section == kXXTExplorerCreateItemViewSectionIndexType) {
            return 66.f;
        }
        else if (indexPath.section == kXXTExplorerCreateItemViewSectionIndexLocation) {
            return UITableViewAutomaticDimension;
        }
    }
    return 44.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == self.tableView) {
        if (indexPath.section == kXXTExplorerCreateItemViewSectionIndexName) {
            if (indexPath.row == 1) {
                XXTEMoreLinkCell *cell = ((XXTEMoreLinkCell *)staticCells[indexPath.section][indexPath.row]);
                if (cell.accessoryType == UITableViewCellAccessoryNone) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    self.editingUponCreating = YES;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    self.editingUponCreating = NO;
                }
            }
        }
        else if (indexPath.section == kXXTExplorerCreateItemViewSectionIndexType) {
            if (indexPath.row == 0) {
                NSString *selectedTemplatePath = XXTEDefaultsObject(XXTExplorerCreateItemTemplatePathKey, nil);
                NSString *templatePath = [XXTERootPath() stringByAppendingPathComponent:@"templates"];
                [[NSFileManager defaultManager] createDirectoryAtPath:templatePath withIntermediateDirectories:YES attributes:nil error:nil];
                XXTExplorerItemPicker *itemPicker = [[XXTExplorerItemPicker alloc] initWithEntryPath:templatePath];
                itemPicker.delegate = self;
                itemPicker.allowedExtensions = @[ @"lua" ];
                itemPicker.selectedBootScriptPath = selectedTemplatePath;
                [self.navigationController pushViewController:itemPicker animated:YES];
            } else {
                self.selectedItemType = (NSUInteger) indexPath.row;
                for (UITableViewCell *cell in tableView.visibleCells) {
                    NSIndexPath *cellPath = [tableView indexPathForCell:cell];
                    if (cellPath.section == 1) {
                        if (cellPath.row == 0) {
                            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        } else {
                            cell.accessoryType = UITableViewCellAccessoryNone;
                        }
                    }
                }
                UITableViewCell *selectCell = [tableView cellForRowAtIndexPath:indexPath];
                selectCell.accessoryType = UITableViewCellAccessoryCheckmark;
                [self reloadTemplatePathDisplay];
            }
        }
        else if (indexPath.section == kXXTExplorerCreateItemViewSectionIndexLocation) {
            NSString *detailText = ((XXTEMoreAddressCell *)staticCells[indexPath.section][indexPath.row]).addressLabel.text;
            if (detailText && detailText.length > 0) {
                UIViewController *blockVC = blockInteractionsWithToastAndDelay(self, YES, YES, 1.0);
                [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                        [[UIPasteboard generalPasteboard] setString:detailText];
                        fulfill(nil);
                    });
                }].finally(^() {
                    toastMessage(self, NSLocalizedString(@"Path has been copied to the pasteboard.", nil));
                    blockInteractions(blockVC, NO);
                });
            }
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        return staticSectionTitles[(NSUInteger) section];
    }
    return @"";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        return staticSectionFooters[(NSUInteger) section];
    }
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView) {
        UITableViewCell *cell = staticCells[(NSUInteger) indexPath.section][(NSUInteger) indexPath.row];
        if (indexPath.section == kXXTExplorerCreateItemViewSectionIndexType) {
            if (indexPath.row == 0) {
                if (self.selectedItemType == kXXTExplorerCreateItemViewItemTypeTemplate &&
                    self.selectedTemplatePath != nil
                    )
                {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
            } else {
                if (indexPath.row == self.selectedItemType) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            }
        }
        return cell;
    }
    return [UITableViewCell new];
}

#pragma mark - UIControl Actions

- (void)dismissViewController:(id)sender {
    if ([self.nameField isFirstResponder]) {
        [self.nameField resignFirstResponder];
    }
    if ([_delegate respondsToSelector:@selector(createItemViewControllerDidDismiss:)]) {
        [_delegate createItemViewControllerDidDismiss:self];
    }
}

- (void)submitViewController:(id)sender {
    if ([self.nameField isFirstResponder]) {
        [self.nameField resignFirstResponder];
    }
    NSString *entryPath = self.entryPath;
    if (entryPath.length == 0) {
        return;
    }
    NSString *itemName = self.nameField.text;
    if (itemName.length == 0 || [itemName rangeOfString:@"/"].location != NSNotFound || [itemName rangeOfString:@"\0"].location != NSNotFound) {
        [self.itemNameShaker shake];
        return;
    }
    if (self.selectedItemType == kXXTExplorerCreateItemViewItemTypeLUA) {
        if (![[itemName pathExtension] isEqualToString:@"lua"]) {
            itemName = [itemName stringByAppendingPathExtension:@"lua"];
        }
    } else if (self.selectedItemType == kXXTExplorerCreateItemViewItemTypeTXT) {
        if (![[itemName pathExtension] isEqualToString:@"txt"]) {
            itemName = [itemName stringByAppendingPathExtension:@"txt"];
        }
    } else if (self.selectedItemType == kXXTExplorerCreateItemViewItemTypeTemplate) {
        NSString *templateExt = [self.selectedTemplatePath pathExtension];
        if (![[itemName pathExtension] isEqualToString:templateExt]) {
            itemName = [itemName stringByAppendingPathExtension:templateExt];
        }
    }
    NSString *itemExtension = [[itemName pathExtension] lowercaseString];
    NSFileManager *createItemManager = [[NSFileManager alloc] init];
    struct stat itemStat;
    NSString *itemPath = [entryPath stringByAppendingPathComponent:itemName];
    if (/* [createItemManager fileExistsAtPath:itemPath] */ 0 == lstat([itemPath UTF8String], &itemStat)) {
        toastMessage(self, ([NSString stringWithFormat:NSLocalizedString(@"File \"%@\" already exists.", nil), itemName]));
        [self.itemNameShaker shake];
        return;
    }
    if (self.selectedItemType == kXXTExplorerCreateItemViewItemTypeDIR) {
        NSError *createError = nil;
        BOOL createResult = [createItemManager createDirectoryAtPath:itemPath withIntermediateDirectories:NO attributes:nil error:&createError];
        if (!createResult) {
            toastMessage(self, ([NSString stringWithFormat:NSLocalizedString(@"Cannot create file \"%@\": %@.", nil), itemName, [createError localizedDescription]]));
            [self.itemNameShaker shake];
            return;
        }
    } else {
        
        NSError *createError = nil;
        NSData *templateData = [NSData data];
        NSString *templatePath = nil;
        if (self.selectedItemType == kXXTExplorerCreateItemViewItemTypeTemplate) {
            templatePath = self.selectedTemplatePath;
        } else {
            templatePath = [[NSBundle mainBundle] pathForResource:@"XXTEItemTemplate" ofType:itemExtension];
        }
        
        if ([createItemManager fileExistsAtPath:templatePath]) {
            NSString *newTemplate = [[NSString alloc] initWithContentsOfFile:templatePath encoding:NSUTF8StringEncoding error:&createError];
            
            if (createError) {
                toastMessage(self, ([NSString stringWithFormat:NSLocalizedString(@"Cannot read template \"%@\".", nil), templatePath]));
                return;
            }
            
            NSString *deviceName = [[UIDevice currentDevice] name];
            NSString *productString = [NSString stringWithFormat:@"%@ V%@", uAppDefine(@"PRODUCT_NAME"), uAppDefine(kXXTDaemonVersionKey)];
            NSString *longDateString = [self.class.itemTemplateDateFormatter stringFromDate:[NSDate date]];
            NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
            
            NSString *yearString = [@([dateComponents year]) stringValue];
            NSString *monthString = [@([dateComponents month]) stringValue];
            NSString *dayString = [@([dateComponents day]) stringValue];
            
            NSMutableDictionary <NSString *, NSString *> *tags = [[NSMutableDictionary alloc] init];
            if (itemName) tags[@"FILENAME"] = itemName;
            if (productString) tags[@"PRODUCT_STRING"] = productString;
            if (longDateString) tags[@"CREATED_AT"] = longDateString;
            if (yearString) tags[@"CURRENT_YEAR"] = yearString;
            if (monthString) tags[@"CURRENT_MONTH"] = monthString;
            if (dayString) tags[@"CURRENT_DAY"] = dayString;
            if (deviceName) tags[@"DEVICE_NAME"] = deviceName;
            tags[@"RANDOM_UUID"] = [[NSUUID UUID] UUIDString];
            
            NSInteger encodingIndex = XXTEDefaultsInt(XXTExplorerDefaultEncodingKey, 0);
            CFStringEncoding encoding = [XXTEEncodingHelper encodingAtIndex:encodingIndex];
            newTemplate = [newTemplate stringByReplacingTagsInDictionary:[tags copy]];
            templateData = CFBridgingRelease(CFStringCreateExternalRepresentation(kCFAllocatorDefault, (__bridge CFStringRef)newTemplate, encoding, 0));
        }
        promiseFixPermission(entryPath, NO);
        BOOL createResult = [createItemManager createFileAtPath:itemPath contents:templateData attributes:nil];
        if (!createResult) {
            toastMessage(self, ([NSString stringWithFormat:NSLocalizedString(@"Cannot create file \"%@\".", nil), itemName]));
            [self.itemNameShaker shake];
            return;
        }
    }
    if ([_delegate respondsToSelector:@selector(createItemViewController:didFinishCreatingItemAtPath:)]) {
        [_delegate createItemViewController:self didFinishCreatingItemAtPath:itemPath];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.nameField) {
        if ([string rangeOfString:@"/"].location != NSNotFound || [string rangeOfString:@"\0"].location != NSNotFound) {
            [self.itemNameShaker shake];
            return NO;
        }
        return YES;
    }
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.nameField) {
        if ([textField isFirstResponder]) {
            [textField resignFirstResponder];
        }
        return YES;
    }
    return NO;
}

- (void)textFieldDidChangeWithNotificaton:(NSNotification *)aNotification {
    UITextField *textField = (UITextField *)aNotification.object;
    if (textField.text.length > 0) {
        self.doneButtonItem.enabled = YES;
    } else {
        self.doneButtonItem.enabled = NO;
    }
}

#pragma mark - XXTExplorerItemPickerDelegate

- (void)itemPickerDidCancelSelectingItem:(XXTExplorerItemPicker *)picker {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)itemPicker:(XXTExplorerItemPicker *)picker didSelectItemAtPath:(NSString *)path {
    self.selectedItemType = kXXTExplorerCreateItemViewItemTypeTemplate;
    self.selectedTemplatePath = path;
    [self reloadTemplatePathDisplay];
    [self.tableView reloadData];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Memory

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"- [%@ dealloc]", NSStringFromClass([self class]));
#endif
}

@end
