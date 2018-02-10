//
//  XXTEDetailViewController.h
//  XXTExplorer
//
//  Created by Zheng on 22/07/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#ifndef XXTEDetailViewController_h
#define XXTEDetailViewController_h

#import <UIKit/UIKit.h>
#import "UIViewController+DetailCloseItem.h"

@protocol XXTEDetailViewController <NSObject>

@property (nonatomic, copy, readonly) NSString *entryPath;
- (instancetype)initWithPath:(NSString *)path;

- (NSArray <UIBarButtonItem *> *)splitButtonItems;
- (UIBarButtonItem *)splitDetailCloseItem;

@end

#endif /* XXTEDetailViewController_h */
