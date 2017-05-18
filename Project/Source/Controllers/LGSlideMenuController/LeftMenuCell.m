//
//  LeftMenuCell.m
//  iTransmission
//
//  Created by Beecher Adams on 5/2/17.
//
//

#import "LeftMenuCell.h"

@implementation LeftMenuCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    self.titleLabel.alpha = highlighted ? 0.5 : 1.0;
}

@end
