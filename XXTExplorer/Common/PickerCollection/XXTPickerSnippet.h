//
//  XXTPickerSnippet.h
//  XXTExplorer
//
//  Created by Zheng on 26/08/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XXTBasePicker.h"

@protocol XUIAdapter;

@interface XXTPickerSnippet : NSObject <NSCoding, NSCopying>

@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *output;
@property (nonatomic, strong) NSArray <NSDictionary *> *flags;

- (instancetype)initWithContentsOfFile:(NSString *)path Error:(NSError **)errorPtr;
- (instancetype)initWithContentsOfFile:(NSString *)path Adapter:(id <XUIAdapter>)adapter Error:(NSError **)errorPtr;
- (id)generateWithError:(NSError **)error;

- (void)addResult:(id)result;
- (UIViewController <XXTBasePicker> *)nextPicker;
- (BOOL)taskFinished;
- (float)currentProgress;

- (NSUInteger)currentStep;
- (NSUInteger)totalStep;

- (NSArray *)getResults;

@end
