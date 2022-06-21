//
//  XXTExplorerEntryService.h
//  XXTExplorer
//
//  Created by Zheng on 11/06/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XXTExplorerEntry.h"

@protocol XXTEViewer, XXTEEditor;

@interface XXTExplorerEntryService : NSObject

@property (nonatomic, strong, readonly) NSDictionary *bindingDictionary;
@property (nonatomic, strong, readonly) NSArray <Class> *registeredViewers;

+ (instancetype)sharedInstance;
- (void)setNeedsReload;

- (void)bindExtension:(NSString *)extension toViewer:(NSString *)viewerName;

- (BOOL)hasViewerForEntry:(XXTExplorerEntry *)entry;
- (BOOL)hasEditorForEntry:(XXTExplorerEntry *)entry;

#pragma mark - Controller Methods

- (UIViewController <XXTEViewer> *)viewerForEntry:(XXTExplorerEntry *)entry;
- (UIViewController <XXTEViewer> *)viewerWithName:(NSString *)viewerName forEntry:(XXTExplorerEntry *)entry;
- (UIViewController <XXTEEditor> *)editorForEntry:(XXTExplorerEntry *)entry;
- (UIViewController <XXTEViewer> *)viewerWithName:(NSString *)controllerName forEntryPath:(NSString *)entryPath;

@end
