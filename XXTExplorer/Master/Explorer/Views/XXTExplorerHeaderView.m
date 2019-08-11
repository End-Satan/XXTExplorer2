//
//  XXTExplorerHeaderView.m
//  XXTExplorer
//
//  Created by Zheng on 25/05/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#import "XXTExplorerHeaderView.h"
#import "XXTEInsetsLabel.h"

@implementation XXTExplorerHeaderView

@synthesize headerLabel = _headerLabel;

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [self addSubview:self.headerLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.headerLabel setFrame:self.contentView.bounds];
}

- (UILabel *)headerLabel {
    if (!_headerLabel) {
        XXTEInsetsLabel *textLabel = [[XXTEInsetsLabel alloc] initWithFrame:self.contentView.bounds];
        if (@available(iOS 13.0, *)) {
            textLabel.textColor = [UIColor labelColor];
            textLabel.backgroundColor = [UIColor secondarySystemBackgroundColor];
        } else {
            textLabel.textColor = [UIColor blackColor];
            textLabel.backgroundColor = [UIColor colorWithWhite:.96f alpha:.9f];
        }
        textLabel.font = [UIFont italicSystemFontOfSize:14.f];
        textLabel.edgeInsets = UIEdgeInsetsMake(0, 12.f, 0, 12.f);
        textLabel.numberOfLines = 1;
        textLabel.lineBreakMode = NSLineBreakByTruncatingHead;
        _headerLabel = textLabel;
    }
    return _headerLabel;
}

@end
