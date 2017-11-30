//
//  XXTEMoreSwitchCell.h
//  XXTExplorer
//
//  Created by Zheng on 28/06/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const XXTEMoreSwitchCellReuseIdentifier = @"XXTEMoreSwitchCellReuseIdentifier";

@interface XXTEMoreSwitchCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UISwitch *optionSwitch;
@property (nonatomic, strong) UIImage *iconImage;

@end
