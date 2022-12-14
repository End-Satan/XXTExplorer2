//
//  XXTExplorerEntryParser.m
//  XXTExplorer
//
//  Created by Zheng on 28/05/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#import <sys/stat.h>

#import "XXTExplorerDefaults.h"
#import "XXTExplorerEntryParser.h"
#import "XXTExplorerEntryReader.h"
#import "XXTExplorerEntryService.h"
#import "XXTEViewer.h"
#import "XXTExplorerEntryLauncher.h"
#import "XXTExplorerEntryUnarchiver.h"

#import "XXTExplorerEntry.h"

@interface XXTExplorerEntryParser ()
@property (nonatomic, strong, readonly) NSFileManager *parserFileManager;

@end

@implementation XXTExplorerEntryParser {
    
}

+ (XXTExplorerEntryService *)parserEntryService {
    static XXTExplorerEntryService *parserEntryService = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        if (!parserEntryService) {
            parserEntryService = [XXTExplorerEntryService sharedInstance];
        }
    });
    return parserEntryService;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    _parserFileManager = [[NSFileManager alloc] init];
}

- (XXTExplorerEntry *)entryOfPath:(NSString *)entrySubdirectoryPath withError:(NSError *__autoreleasing *)error {
    NSError *localError = nil;
    NSDictionary <NSString *, id> *entrySubdirectoryAttributes = [self.parserFileManager attributesOfItemAtPath:entrySubdirectoryPath error:&localError];
    if (localError)
    {
        if (error) {
            *error = localError;
        }
        return nil;
    }
    NSString *entryNSFileType = entrySubdirectoryAttributes[NSFileType];
    UIImage *entryIconImage = nil;
    NSString *entryBaseType = nil;
    if ([entryNSFileType isEqualToString:NSFileTypeRegular]) {
        entryBaseType = EntryTypeRegular;
    } else if ([entryNSFileType isEqualToString:NSFileTypeDirectory]) {
        entryBaseType = EntryTypeDirectory;
    } else if ([entryNSFileType isEqualToString:NSFileTypeSymbolicLink]) {
        entryBaseType = EntryTypeSymlink;
    } else {
        entryBaseType = EntryTypeUnsupported;
    }
    NSString *entryRealPath = entrySubdirectoryPath;
    NSString *entryMaskType = entryBaseType;
    if ([entryBaseType isEqualToString:EntryTypeSymlink])
    {
        const char *entrySubdirectoryPathCString = [entrySubdirectoryPath fileSystemRepresentation];
        struct stat entrySubdirectoryPathCStatStruct;
        bzero(&entrySubdirectoryPathCStatStruct, sizeof(struct stat));
        if (0 == stat(entrySubdirectoryPathCString, &entrySubdirectoryPathCStatStruct))
        {
            char entryRealPathBuffer[PATH_MAX] = {'\0'};
            char *entryRealPathC = realpath(entrySubdirectoryPathCString, entryRealPathBuffer);
            if (entryRealPathC != NULL) {
                entryRealPath = [[NSString alloc] initWithUTF8String:entryRealPathC];
            }
            if (S_ISDIR(entrySubdirectoryPathCStatStruct.st_mode))
            {
                entryMaskType = EntryMaskTypeDirectory;
            }
            else if (S_ISREG(entrySubdirectoryPathCStatStruct.st_mode))
            {
                entryMaskType = EntryMaskTypeRegular;
            }
            else
            {
                entryMaskType = EntryMaskTypeUnsupported;
            }
            // MaskType cannot be symlink
        } else {
            if (errno == ENOENT || errno == EMLINK) {
                entryMaskType = EntryMaskTypeBrokenSymlink;
            }
        }
    }
    if (!entryIconImage) {
        if ([entryMaskType isEqualToString:EntryMaskTypeRegular]) {
            entryIconImage = [UIImage imageNamed:EntryMaskTypeRegular];
        } else if ([entryMaskType isEqualToString:EntryMaskTypeDirectory]) {
            entryIconImage = [UIImage imageNamed:EntryMaskTypeDirectory];
        } else if ([entryMaskType isEqualToString:EntryMaskTypeSymlink]) {
            entryIconImage = [UIImage imageNamed:EntryMaskTypeSymlink];
        } else if ([entryMaskType isEqualToString:EntryMaskTypeBrokenSymlink]) {
            entryIconImage = [UIImage imageNamed:EntryMaskTypeBrokenSymlink];
        } else {
            entryIconImage = [UIImage imageNamed:EntryMaskTypeUnsupported];
        }
    }
    XXTExplorerEntry *entryDetail = [[XXTExplorerEntry alloc] init];
    entryDetail.iconImage = entryIconImage;
    entryDetail.entryPath = XXTStrippedPath(entrySubdirectoryPath);
    entryDetail.entryRealPath = XXTStrippedPath(entryRealPath);
    entryDetail.creationDate = entrySubdirectoryAttributes[NSFileCreationDate];
    entryDetail.modificationDate = entrySubdirectoryAttributes[NSFileModificationDate];
    entryDetail.entrySize = entrySubdirectoryAttributes[NSFileSize];
    entryDetail.entryType = entryBaseType;
    entryDetail.entryMaskType = entryMaskType;
    XXTExplorerEntry *extraEntryDetail = [self parseExternalEntry:entryDetail];
    return extraEntryDetail;
}

- (XXTExplorerEntry *)parseExternalEntry:(XXTExplorerEntry *)entry {
    NSDictionary *bindingDictionary = [self.class.parserEntryService bindingDictionary];
    NSString *entryMaskType = entry.entryMaskType;
    NSString *entryPath = entry.entryPath;
    NSString *entryBaseExtension = entry.entryExtension;
    if ([entryMaskType isEqualToString:EntryMaskTypeRegular])
    {
        // Find binded viewers
        NSString *bindedViewerName = bindingDictionary[entryBaseExtension];
        if (bindedViewerName) {
            Class bindedViewerClass = NSClassFromString(bindedViewerName);
            if ([bindedViewerClass respondsToSelector:@selector(relatedReader)]) {
                Class relatedReaderClass = [((Class <XXTEViewer>)bindedViewerClass) relatedReader];
                if (relatedReaderClass) {
                    XXTExplorerEntryReader *relatedReader = [[relatedReaderClass alloc] initWithPath:entryPath];
                    entry.entryReader = relatedReader;
                }
            }
        }
    }
    return entry;
}

@end
