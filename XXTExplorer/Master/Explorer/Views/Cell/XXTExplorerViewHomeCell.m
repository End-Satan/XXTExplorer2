//
//  XXTExplorerViewCell.m
//  XXTExplorer
//
//  Created by Zheng on 25/05/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#import "XXTExplorerViewHomeCell.h"

@interface XXTExplorerViewHomeCell ()

@end

@implementation XXTExplorerViewHomeCell

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    UIView *selectionBackground = [[UIView alloc] init];
    selectionBackground.backgroundColor = [XXTE_COLOR colorWithAlphaComponent:0.1f];
    self.selectedBackgroundView = selectionBackground;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self setup];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

@end
