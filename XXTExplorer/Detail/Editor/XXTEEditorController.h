//
//  XXTEEditorController.h
//  XXTExplorer
//
//  Created by Zheng Wu on 10/08/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#import "XXTEEditor.h"

@class SKAttributedParser, XXTEEditorTextView, XXTEEditorToolbar, XXTEEditorTheme, XXTEEditorLanguage, XXTPickerFactory, XXTEEditorMaskView;

@interface XXTEEditorController : UIViewController <XXTEEditor>

@property (nonatomic, strong) XXTEEditorTheme *theme;
@property (nonatomic, strong) XXTEEditorLanguage *language;

@property (nonatomic, strong) XXTEEditorTextView *textView;
@property (nonatomic, strong) XXTEEditorMaskView *maskView;
@property (nonatomic, strong) XXTEEditorToolbar *toolbar;

- (void)setNeedsReload;
- (void)setNeedsSoftReload;
- (void)setNeedsReloadAttributes;
- (void)setNeedsSaveDocument;
- (void)setNeedsFocusTextView;
- (void)setNeedsHighlightRange:(NSRange)range;

- (void)reloadAttributesIfNecessary;

- (void)invalidateSyntaxCaches;
- (void)saveDocumentIfNecessary;

#pragma mark - Search

- (void)toggleSearchBar:(UIBarButtonItem *)sender animated:(BOOL)animated;
@property (nonatomic, assign, getter=isSearchMode) BOOL searchMode;

@end
