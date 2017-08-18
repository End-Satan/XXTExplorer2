//
//  XXTEEditorController.h
//  XXTExplorer
//
//  Created by Zheng Wu on 10/08/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#import "XXTEEditor.h"

@class XXTEEditorTextView;

@interface XXTEEditorController : UIViewController <XXTEEditor>

@property (nonatomic, strong, readonly) XXTEEditorTextView *textView;

@end
