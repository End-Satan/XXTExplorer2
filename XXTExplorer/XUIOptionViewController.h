//
//  XUIOptionViewController.h
//  XXTExplorer
//
//  Created by Zheng on 17/07/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#import "XUIViewController.h"
#import "XUILinkListCell.h"

@class XUIOptionViewController;

@protocol XUIOptionViewControllerDelegate <NSObject>

- (void)optionViewController:(XUIOptionViewController *)controller didSelectOption:(NSInteger)optionIndex;

@end

@interface XUIOptionViewController : XUIViewController

@property (nonatomic, weak) id <XUIOptionViewControllerDelegate> delegate;
@property (nonatomic, strong, readonly) XUILinkListCell *cell;
- (instancetype)initWithCell:(XUILinkListCell *)cell;

@end
