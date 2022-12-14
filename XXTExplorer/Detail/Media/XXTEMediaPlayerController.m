//
//  XXTEMediaPlayerController.m
//  XXTExplorer
//
//  Created by Zheng Wu on 05/12/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#import "XXTEMediaPlayerController.h"
#import "XXTExplorerEntryMediaReader.h"
#import "XXTEMediaPlayerController+NavigationBar.h"


@interface XXTEMediaPlayerController () <MWPhotoBrowserDelegate>
@property (nonatomic, strong) NSMutableArray <MWPhoto *> *videos;

@end

@implementation XXTEMediaPlayerController

@synthesize entryPath = _entryPath;

+ (NSString *)viewerName {
    return NSLocalizedString(@"Movie Player", nil);
}

+ (NSArray <NSString *> *)suggestedExtensions {
    return @[ @"m4a", @"m4v", @"mov", @"flv", @"fla", @"mp4", @"mp3", @"aac", @"wav" ];
}

+ (Class)relatedReader {
    return [XXTExplorerEntryMediaReader class];
}

- (instancetype)initWithPath:(NSString *)path {
    if (self = [super initWithDelegate:self]) {
        _entryPath = path;
        _videos = [[NSMutableArray alloc] init];
        [self setup];
    }
    return self;
}

- (void)setup {
    self.displayActionButton = YES;
    self.displayNavArrows = YES;
    self.displaySelectionButtons = NO;
    self.zoomPhotosToFill = NO;
    self.alwaysShowControls = NO;
    self.enableGrid = YES;
    self.startOnGrid = NO;
    self.autoPlayOnAppear = NO;
    
    [self prepareVideos];
}

- (void)prepareVideos {
    if (!self.entryPath) {
        return;
    }
    
    NSError *prepareError = nil;
    NSFileManager *prepareManager = [NSFileManager defaultManager];
    
    NSString *singlePath = self.entryPath;
    NSString *parentPath = [singlePath stringByDeletingLastPathComponent];
    
    NSArray <NSString *> *fileList = [prepareManager contentsOfDirectoryAtPath:parentPath error:&prepareError];
    if (!fileList) {
        return;
    }
    
    NSMutableArray <NSString *> *filteredFileList = [[NSMutableArray alloc] init];
    [fileList enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *fileExt = [[obj pathExtension] lowercaseString];
        if ([[[self class] suggestedExtensions] containsObject:fileExt])
        {
            [filteredFileList addObject:obj];
        }
    }];
    
    [filteredFileList sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
    }];
    
    for (NSString *filteredFile in filteredFileList) {
        NSString *singlePath = [parentPath stringByAppendingPathComponent:filteredFile];
        NSURL *singleURL = [NSURL fileURLWithPath:singlePath];
        MWPhoto *singlePhoto = [MWPhoto videoWithURL:singleURL];
        singlePhoto.caption = [singlePath lastPathComponent];
        [self.videos addObject:singlePhoto];
    }
    
    NSString *singleName = [singlePath lastPathComponent];
    NSUInteger selectedIndex = [filteredFileList indexOfObject:singleName];
    if (selectedIndex != NSNotFound) {
        [self setCurrentPhotoIndex:selectedIndex];
    }
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    XXTE_START_IGNORE_PARTIAL
    if (XXTE_COLLAPSED && [self.navigationController.viewControllers firstObject] == self) {
        [self.navigationItem setLeftBarButtonItems:self.splitButtonItems];
    }
    XXTE_END_IGNORE_PARTIAL
    
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self renderNavigationBarTheme:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIView animateWithDuration:.4f delay:.2f options:0 animations:^{
        [self renderNavigationBarTheme:NO];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    if (parent == nil) {
        [self renderNavigationBarTheme:YES];
    }
    [super willMoveToParentViewController:parent];
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.videos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < self.videos.count) {
        return [self.videos objectAtIndex:index];
    }
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    return [self photoBrowser:photoBrowser photoAtIndex:index];
}

#pragma mark - Memory

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"- [%@ dealloc]", NSStringFromClass([self class]));
#endif
}

@end
