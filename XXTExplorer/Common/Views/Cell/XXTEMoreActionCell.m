//
//  XXTEMoreActionCell.m
//  XXTExplorer
//
//  Created by Zheng Wu on 30/06/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#import "XXTEMoreActionCell.h"

@implementation XXTEMoreActionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.actionNameLabel.textColor = XXTColorDanger();
    
    UIView *selectionBackground = [[UIView alloc] init];
    selectionBackground.backgroundColor = XXTColorCellSelected();
    self.selectedBackgroundView = selectionBackground;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
