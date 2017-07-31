//
//  XUITitleValueCell.m
//  XXTExplorer
//
//  Created by Zheng on 30/07/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#import "XUITitleValueCell.h"
#import "XUI.h"

@implementation XUITitleValueCell

+ (BOOL)xibBasedLayout {
    return YES;
}

+ (BOOL)layoutNeedsTextLabel {
    return YES;
}

+ (BOOL)layoutNeedsImageView {
    return NO;
}

+ (BOOL)layoutRequiresDynamicRowHeight {
    return YES;
}

+ (BOOL)checkEntry:(NSDictionary *)cellEntry withError:(NSError **)error {
    BOOL superResult = [super checkEntry:cellEntry withError:error];
    return superResult;
}

- (void)setupCell {
    [super setupCell];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    XUI_START_IGNORE_PARTIAL
    if (XUI_SYSTEM_9) {
        self.detailTextLabel.font = [UIFont systemFontOfSize:17.f weight:UIFontWeightLight];
    }
    XUI_END_IGNORE_PARTIAL
    self.detailTextLabel.textColor = UIColor.grayColor;
    self.detailTextLabel.text = nil;
}

- (void)setXui_value:(id)xui_value {
    [super setXui_value:xui_value];
    self.detailTextLabel.text = xui_value;
}

@end