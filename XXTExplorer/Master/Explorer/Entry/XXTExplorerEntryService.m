//
//  XXTExplorerEntryService.m
//  XXTExplorer
//
//  Created by Zheng on 11/06/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#import "XXTExplorerEntryService.h"
#import "XXTExplorerDefaults.h"
#import "XXTEViewer.h"
#import "XXTEEditor.h"
#import "XXTExplorerEntryReader.h"
#import "XXTExplorerEntryOpenWithViewController.h"

@interface XXTExplorerEntryService ()

@end

@implementation XXTExplorerEntryService

@synthesize bindingDictionary = _bindingDictionary, registeredViewers = _registeredViewers;

+ (instancetype)sharedInstance {
    static XXTExplorerEntryService *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    
}

- (NSArray <Class> *)registeredViewers {
    if (!_registeredViewers) {
        NSArray <NSString *> *registeredNames = uAppDefine(@"AVAILABLE_VIEWER");
        NSMutableArray <Class> *registeredMutableViewers = [[NSMutableArray alloc] initWithCapacity:registeredNames.count];
        for (NSString *className in registeredNames) {
            [registeredMutableViewers addObject:NSClassFromString(className)];
        }
        _registeredViewers = [[NSArray alloc] initWithArray:registeredMutableViewers];
    }
    return _registeredViewers;
}

- (NSDictionary *)bindingDictionary {
    if (!_bindingDictionary) {
        // Register binding
        NSDictionary *originalBindingDictionary = XXTEDefaultsObject(XXTExplorerViewEntryBindingKey, nil);
        NSMutableDictionary *newBindingDictionary = [[NSMutableDictionary alloc] initWithDictionary:originalBindingDictionary];
        for (Class registeredViewerClass in self.registeredViewers) {
            Class <XXTEViewer> viewerClass = registeredViewerClass;
            NSArray <NSString *> *suggestedExtensions = [viewerClass suggestedExtensions];
            for (NSString *suggestExtension in suggestedExtensions) {
                if (!originalBindingDictionary[suggestExtension] && !newBindingDictionary[suggestExtension]) { // if no binding, set default binding
                    newBindingDictionary[suggestExtension] = NSStringFromClass(viewerClass);
                    continue;
                }
            }
        }
        NSDictionary *saveBindingDictionary = [[NSDictionary alloc] initWithDictionary:newBindingDictionary];
        XXTEDefaultsSetObject(XXTExplorerViewEntryBindingKey, saveBindingDictionary);
        _bindingDictionary = saveBindingDictionary;
    }
    return _bindingDictionary;
}

- (void)bindExtension:(NSString *)extension toViewer:(NSString *)viewerName {
    Class testClass = (extension.length > 0 && viewerName.length > 0) ? NSClassFromString(viewerName) : nil;
    NSMutableDictionary *mutableBindingDictionary = [[NSMutableDictionary alloc] initWithDictionary:self.bindingDictionary];
    if (testClass) {
        mutableBindingDictionary[extension] = viewerName;
    } else { // remove binding
        [mutableBindingDictionary removeObjectForKey:extension];
    }
    NSDictionary *saveBindingDictionary = [[NSDictionary alloc] initWithDictionary:mutableBindingDictionary];
    XXTEDefaultsSetObject(XXTExplorerViewEntryBindingKey, saveBindingDictionary);
    _bindingDictionary = nil; // clear binding cache
}

- (BOOL)isRegisteredExtension:(NSString *)ext {
    if (ext.length == 0) return NO;
    return [self.bindingDictionary.allKeys containsObject:ext];
}

- (BOOL)hasViewerForEntry:(XXTExplorerEntry *)entry {
    NSString *entryBaseExtension = entry.entryExtension;
    NSDictionary *bindingDictionary = XXTEDefaultsObject(XXTExplorerViewEntryBindingKey, nil);
    NSString *viewerName = bindingDictionary[entryBaseExtension];
    Class testClass = viewerName.length > 0 ? NSClassFromString(viewerName) : nil;
    return testClass && [testClass isSubclassOfClass:[UIViewController class]];
}

- (BOOL)hasEditorForEntry:(XXTExplorerEntry *)entry {
    XXTExplorerEntryReader *reader = entry.entryReader;
    if (reader && [reader isKindOfClass:[XXTExplorerEntryReader class]] && reader.editable) {
        Class testClass = [[reader class] relatedEditor];
        if (testClass && [testClass isSubclassOfClass:[UIViewController class]]) {
            return YES;
        }
    }
    return NO;
}

- (UIViewController <XXTEViewer> *)viewerForEntry:(XXTExplorerEntry *)entry {
    NSString *entryPath = entry.entryPath;
    NSString *entryBaseExtension = entry.entryExtension;
    NSString *viewerName = self.bindingDictionary[entryBaseExtension];
    return [self viewerWithName:viewerName forEntryPath:entryPath];
}

- (UIViewController <XXTEViewer> *)viewerWithName:(NSString *)viewerName forEntry:(XXTExplorerEntry *)entry {
    NSString *entryPath = entry.entryPath;
    return [self viewerWithName:viewerName forEntryPath:entryPath];
}

- (UIViewController <XXTEEditor> *)editorForEntry:(XXTExplorerEntry *)entry {
    NSString *entryPath = entry.entryPath;
    XXTExplorerEntryReader *reader = entry.entryReader;
    if (reader && [reader isKindOfClass:[XXTExplorerEntryReader class]] && reader.editable) {
        Class editorClass = [[reader class] relatedEditor];
        if (editorClass && [editorClass isSubclassOfClass:[UIViewController class]]) {
            if ([editorClass instancesRespondToSelector:@selector(initWithPath:)]) {
                UIViewController <XXTEEditor> *editor = [[editorClass alloc] initWithPath:entryPath];
                return editor;
            }
        }
    }
    return nil;
}

- (UIViewController <XXTEViewer> *)viewerWithName:(NSString *)controllerName forEntryPath:(NSString *)entryPath {
    if (controllerName) {
        Class controllerClass = controllerName.length > 0 ? NSClassFromString(controllerName) : nil;
        if (controllerClass && [controllerClass isSubclassOfClass:[UIViewController class]]) {
            if ([controllerClass instancesRespondToSelector:@selector(initWithPath:)]) {
                UIViewController <XXTEViewer> *viewer = [[controllerClass alloc] initWithPath:entryPath];
                return viewer;
            }
        }
    }
    return nil;
}

- (void)setNeedsReload {
    _bindingDictionary = nil;
    _registeredViewers = nil;
#ifdef DEBUG
    NSLog(@"+ [%@ sharedInstance] needs reload...", NSStringFromClass([self class]));
#endif
}

@end
