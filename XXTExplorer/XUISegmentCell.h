//
//  XUISegmentCell.h
//  XXTExplorer
//
//  Created by Zheng on 30/07/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#import "XUIBaseCell.h"

@interface XUISegmentCell : XUIBaseCell

@property (nonatomic, strong) NSArray <NSString *> *xui_validTitles;
@property (nonatomic, strong) NSArray *xui_validValues;

@end
