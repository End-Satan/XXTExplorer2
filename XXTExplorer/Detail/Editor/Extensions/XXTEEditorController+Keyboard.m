//
//  XXTEEditorController+Keyboard.m
//  XXTExplorer
//
//  Created by Zheng on 17/08/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#import "XXTEEditorController+Keyboard.h"
#import "XXTEEditorTextView.h"
#import "XXTEEditorDefaults.h"
#import "XXTEEditorToolbar.h"


@implementation XXTEEditorController (Keyboard)

+ (BOOL)runningInForeground
{
    UIApplicationState state = [UIApplication sharedApplication].applicationState;
    return state == UIApplicationStateActive;
}

- (BOOL)isLocalKeyboard:(NSNotification *)aNotification {
    NSDictionary* info = [aNotification userInfo];
    BOOL isLocal = [info[UIKeyboardIsLocalUserInfoKey] boolValue];
    if (!isLocal) {
        return NO;
    }
    if (![[self class] runningInForeground]) {
        return NO;
    }
    
    return YES;
}

#pragma mark - Keyboard

// Call this method somewhere in your view controller setup code.
- (void)registerKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidAppear:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDisappear:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidDisappear:) name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrame:) name:UIKeyboardDidChangeFrameNotification object:nil];
}

- (void)dismissKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
}

- (void)keyboardWillChangeFrame:(NSNotification *)aNotification {
    if (self.presentedViewController) {
        return;
    }
    
    if (![self isLocalKeyboard:aNotification]) {
        return;
    }
    
    NSDictionary* info = [aNotification userInfo];
    self.keyboardFrame = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue];
}

- (void)keyboardDidChangeFrame:(NSNotification *)aNotification {
    if (self.presentedViewController) {
        return;
    }
    
    if (![self isLocalKeyboard:aNotification]) {
        return;
    }
    
    NSDictionary* info = [aNotification userInfo];
    self.keyboardFrame = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue];
}

- (void)keyboardWillAppear:(NSNotification *)aNotification {
    if (self.presentedViewController) {
        return;
    }
    
    if (![self isLocalKeyboard:aNotification]) {
        return;
    }
    
    if (XXTE_IS_IPAD) {
        
    } else {
        if (XXTEDefaultsBool(XXTEEditorFullScreenWhenEditing, NO)) {
            [self.navigationController setNavigationBarHidden:YES animated:YES];
        }
    }
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardDidAppear:(NSNotification *)aNotification
{
    if (self.presentedViewController) {
        return;
    }
    
    if (![self isLocalKeyboard:aNotification]) {
        return;
    }
    
    NSDictionary* info = [aNotification userInfo];
    
    CGSize kbSize = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    UIEdgeInsets insets = self.view.safeAreaInsets;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height - insets.bottom, 0.0);
    self.textView.contentInset = contentInsets;
    self.textView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    XXTEEditorTextView *textView = self.textView;
    if (textView.isFirstResponder) {
        CGRect aRect = self.view.frame;
        aRect.size.height -= kbSize.height;
        
        UITextRange *selectionRange = [textView selectedTextRange];
        CGRect selectionStartRect = [textView caretRectForPosition:selectionRange.start];
        CGRect selectionEndRect = [textView caretRectForPosition:selectionRange.end];
        CGPoint selectionCenterPoint = (CGPoint){(selectionStartRect.origin.x + selectionEndRect.origin.x) / 2,(selectionStartRect.origin.y + selectionStartRect.size.height / 2)};
        
        if (!CGRectContainsPoint(aRect, selectionCenterPoint) ) {
            [textView scrollRectToVisible:CGRectMake(selectionStartRect.origin.x, selectionStartRect.origin.y, selectionEndRect.origin.x - selectionStartRect.origin.x, selectionStartRect.size.height) animated:YES consideringInsets:YES];
        }
    }
    
    [self setNeedsStatusBarAppearanceUpdate];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillDisappear:(NSNotification *)aNotification
{
    if (self.presentedViewController) {
        return;
    }
    
    if (![self isLocalKeyboard:aNotification]) {
        return;
    }
    
    if (XXTE_IS_IPAD) {
        
    } else {
        if (XXTEDefaultsBool(XXTEEditorFullScreenWhenEditing, NO)) {
            [self.navigationController setNavigationBarHidden:NO animated:YES];
        }
    }
    
    UIEdgeInsets insets = UIEdgeInsetsZero;
    UITextView *textView = self.textView;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(insets.top, insets.left, insets.bottom + kXXTEEditorToolbarHeight, insets.right);
    textView.contentInset = contentInsets;
    textView.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardDidDisappear:(NSNotification *)aNotification
{
    if (self.presentedViewController) {
        return;
    }
    
    if (![self isLocalKeyboard:aNotification]) {
        return;
    }
    
    [self saveDocumentIfNecessary];
    [self setNeedsStatusBarAppearanceUpdate];
}

@end
