//
//  XXTExplorerEntryReader.m
//  XXTExplorer
//
//  Created by Zheng on 13/11/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#import "XXTExplorerEntryReader.h"

@implementation XXTExplorerEntryReader

- (instancetype)init {
    self = [super init];
    if (self)
    {
        [self configure];
    }
    return self;
}

- (instancetype)initWithPath:(NSString *)filePath {
    self = [super init];
    if (self)
    {
        _entryPath = filePath;
        [self configure];
    }
    return self;
}

- (void)configure {
    
}

+ (UIImage *)defaultImage {
    return nil;
}

+ (NSArray <NSString *> *)supportedExtensions {
    return @[];
}

+ (Class)relatedEditor {
    return nil;
}

- (BOOL)isSupportedDaemon {
    return YES;
}

- (BOOL)isSupportedSystem {
    return YES;
}

- (BOOL)isSupportedResolution {
    return YES;
}

- (BOOL)isSupported {
    return [self isSupportedSystem] && [self isSupportedDaemon] && [self isSupportedResolution];
}

- (NSString *)localizedUnsupportedReason {
    return nil;
}

@end
