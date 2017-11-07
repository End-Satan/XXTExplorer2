//
//  XXTExplorerToolbar.m
//  XXTExplorer
//
//  Created by Zheng on 28/05/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#import "XXTExplorerToolbar.h"

@interface XXTExplorerToolbar ()

@property (nonatomic, strong, readonly) NSArray <UIBarButtonItem *> *defaultButtons;
@property (nonatomic, strong, readonly) NSArray <UIBarButtonItem *> *editingButtons;
@property (nonatomic, strong, readonly) NSArray <UIBarButtonItem *> *readonlyButtons;
@property (nonatomic, strong, readonly) NSDictionary <NSString *, NSArray <UIBarButtonItem *> *> *statusSeries;

@end

@implementation XXTExplorerToolbar

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [[UIBarButtonItem appearanceWhenContainedIn:[self class], nil] setTintColor:XXTE_COLOR];
    
    self.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    NSArray <NSString *> *buttonTypes =
    @[
      XXTExplorerToolbarButtonTypeScan,
      XXTExplorerToolbarButtonTypeCompress,
      XXTExplorerToolbarButtonTypeAddItem,
      XXTExplorerToolbarButtonTypeSort,
      XXTExplorerToolbarButtonTypeShare,
      XXTExplorerToolbarButtonTypePaste,
      XXTExplorerToolbarButtonTypeTrash
      ];
    
    NSMutableDictionary <NSString *, UIBarButtonItem *> *buttons = [[NSMutableDictionary alloc] initWithCapacity:buttonTypes.count];
    for (NSString *buttonType in buttonTypes) {
        UIImage *itemImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@-%@", buttonType, XXTExplorerToolbarButtonStatusNormal]];
        itemImage = [itemImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIButton *newButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 26.0, 26.0)];
        [newButton addTarget:self action:@selector(toolbarButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [newButton setImage:itemImage forState:UIControlStateNormal];
        UIBarButtonItem *newButtonItem = [[UIBarButtonItem alloc] initWithCustomView:newButton];
        [buttons setObject:newButtonItem
                    forKey:buttonType];
    }
    _buttons = buttons;
    
    _defaultButtons =
    @[
      buttons[XXTExplorerToolbarButtonTypeScan],
      flexibleSpace,
      buttons[XXTExplorerToolbarButtonTypeAddItem],
      flexibleSpace,
      buttons[XXTExplorerToolbarButtonTypeSort],
      flexibleSpace,
      buttons[XXTExplorerToolbarButtonTypePaste],
      ];
    
    _editingButtons =
    @[
      buttons[XXTExplorerToolbarButtonTypeShare],
      flexibleSpace,
      buttons[XXTExplorerToolbarButtonTypeCompress],
      flexibleSpace,
      buttons[XXTExplorerToolbarButtonTypeTrash],
      flexibleSpace,
      buttons[XXTExplorerToolbarButtonTypePaste],
      ];
    
    _readonlyButtons =
    @[
      flexibleSpace,
      buttons[XXTExplorerToolbarButtonTypeSort],
      flexibleSpace,
      ];
    
    _statusSeries =
    @{
      XXTExplorerToolbarStatusDefault: self.defaultButtons,
      XXTExplorerToolbarStatusEditing: self.editingButtons,
      XXTExplorerToolbarStatusReadonly: self.readonlyButtons
      };
    
    [self updateStatus:XXTExplorerToolbarStatusDefault];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(ctx, 0.85, 0.85, 0.85, 1.0);
    CGContextSetLineWidth(ctx, 1.0f);
    CGPoint aPoint[2] = {
        CGPointMake(0.0, self.frame.size.height),
        CGPointMake(self.frame.size.width, self.frame.size.height)
    };
    CGContextAddLines(ctx, aPoint, 2);
    CGContextStrokePath(ctx);
}

- (void)updateStatus:(NSString *)status {
    for (NSString *buttonItemName in self.buttons) {
        UIBarButtonItem *button = self.buttons[buttonItemName];
        button.enabled = NO;
    }
    [self setItems:self.statusSeries[status] animated:YES];
}

- (void)updateButtonType:(NSString *)buttonType enabled:(BOOL)enabled {
    [self updateButtonType:buttonType status:nil enabled:enabled];
}

- (void)updateButtonType:(NSString *)buttonType status:(NSString *)buttonStatus enabled:(BOOL)enabled {
    UIBarButtonItem *buttonItem = self.buttons[buttonType];
    if (buttonStatus) {
        UIImage *statusImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@-%@", buttonType, buttonStatus]];
        statusImage = [statusImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        if (statusImage) {
            UIButton *button = [buttonItem customView];
            [button setImage:statusImage forState:UIControlStateNormal];
        }
    }
    if (buttonItem.enabled != enabled) {
        [buttonItem setEnabled:enabled];
    }
}

#pragma mark - Button Tapped

- (void)toolbarButtonTapped:(UIButton *)button {
    if (_tapDelegate && [_tapDelegate respondsToSelector:@selector(toolbar:buttonTypeTapped:buttonItem:)]) {
        NSString *buttonType = nil;
        for (NSString *buttonKey in self.buttons) {
            UIBarButtonItem *buttonItem = self.buttons[buttonKey];
            if (buttonItem.customView == button) {
                buttonType = buttonKey;
                break;
            }
        }
        if (buttonType) {
            [_tapDelegate toolbar:self buttonTypeTapped:buttonType buttonItem:self.buttons[buttonType]];
        }
    }
}

@end