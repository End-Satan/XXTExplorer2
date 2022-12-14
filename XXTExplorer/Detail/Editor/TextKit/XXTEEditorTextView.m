//
//  XXTEEditorTextView.m
//  XXTExplorer
//
//  Created by Zheng Wu on 11/08/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#import "XXTEEditorTextView.h"

#import "XXTEEditorTextStorage.h"
#import "XXTEEditorLayoutManager.h"
#import "UITextView+TextRange.h"


// static CGFloat kXXTEEditorTextViewGutterExtraHeight = 150.0;

@interface XXTEEditorTextView ()

@property (nonatomic, assign) BOOL shouldReloadContainerInsets;

@end

@implementation XXTEEditorTextView

- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer {
    self = [super initWithFrame:frame textContainer:textContainer];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.bounces = YES;
    self.alwaysBounceVertical = YES;
    self.contentMode = UIViewContentModeRedraw;
    self.textContainerInset = UIEdgeInsetsMake(8, 8, 8, 8);
    self.layoutManager.allowsNonContiguousLayout = NO;
    
    self.gutterBackgroundColor = [UIColor clearColor];
    self.gutterLineColor = [UIColor clearColor];
}

- (void)drawRect:(CGRect)rect {
    [self reloadContainerInsetsIfNeeded];
    
    if (!self.showLineNumbers) {
        [super drawRect:rect];
        return;
    }
    
    XXTEEditorLayoutManager *manager = self.vLayoutManager;
    
    // Why we draw such a large area before? fuck...
    CGContextRef context = UIGraphicsGetCurrentContext();

    // Draw Gutter Background
    CGContextSetFillColorWithColor(context, self.gutterBackgroundColor.CGColor);
    CGRect backgroundRect = CGRectMake(rect.origin.x, rect.origin.y, manager.gutterWidth, rect.size.height);
    CGContextFillRect(context, backgroundRect);
    
    // Draw Gutter Line
    CGContextSetFillColorWithColor(context, self.gutterLineColor.CGColor);
    CGRect lineRect = CGRectMake(manager.gutterWidth, rect.origin.y, 1.0, rect.size.height);
    CGContextFillRect(context, lineRect);
    
    [super drawRect:rect];
}

#pragma mark - Setters

- (void)setText:(NSString *)text {
    UITextRange *textRange = [self textRangeFromPosition:self.beginningOfDocument toPosition:self.endOfDocument];
    [self replaceRange:textRange withText:text];
}

- (void)setGutterLineColor:(UIColor *)gutterLineColor {
    _gutterLineColor = gutterLineColor;
//    [self setNeedsDisplay];
}

- (void)setGutterBackgroundColor:(UIColor *)gutterBackgroundColor {
    _gutterBackgroundColor = gutterBackgroundColor;
//    [self setNeedsDisplay];
}

- (void)replaceRange:(UITextRange *)range
            withText:(NSString *)text {
    [super replaceRange:range withText:text];
}

- (void)setShowLineNumbers:(BOOL)showLineNumbers {
    _showLineNumbers = showLineNumbers;
}

- (void)setNeedsReloadContainerInsets {
    self.shouldReloadContainerInsets = YES;
}

- (void)reloadContainerInsetsIfNeeded {
    if (self.shouldReloadContainerInsets) {
        [self setTextContainerInset:[self xxteTextContainerInset]];
        self.shouldReloadContainerInsets = NO;
    }
}

- (UIEdgeInsets)xxteTextContainerInset {
    UIEdgeInsets insets = UIEdgeInsetsZero;
    if (self.showLineNumbers) {
        insets = UIEdgeInsetsMake(16.0, (self.vLayoutManager).gutterWidth + 2.0, 16.0, 8.0);
    } else {
        insets = UIEdgeInsetsMake(16.0, 8.0, 16.0, 8.0);
    }
    return insets;
}

@end
