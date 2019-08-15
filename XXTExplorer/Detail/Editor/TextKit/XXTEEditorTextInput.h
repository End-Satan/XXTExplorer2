//
//  XXTEEditorTextInput.h
//  XXTExplorer
//
//  Created by Zheng on 07/09/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XXTEEditorLanguage, XXTEEditorMaskView;

@interface XXTEEditorTextInput : NSObject <UITextViewDelegate>

@property (nonatomic, weak) XXTEEditorLanguage *inputLanguage;
@property (nonatomic, weak) XXTEEditorMaskView *inputMaskView;

@property (nonatomic, assign) BOOL autoIndent;
@property (nonatomic, assign) BOOL autoBrackets;
@property (nonatomic, strong) NSString *tabWidthString;

@property (nonatomic, weak) id <UIScrollViewDelegate> scrollViewDelegate;

@end
