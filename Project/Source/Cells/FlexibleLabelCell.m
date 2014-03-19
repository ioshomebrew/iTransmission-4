//
//  FlexibleLabelCell.m
//  iTransmission
//
//  Created by Mike Chen on 10/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FlexibleLabelCell.h"


@implementation FlexibleLabelCell
@synthesize flexibleLabel = fLabel;

- (void)resizeToFitText
{
	CGSize constraint = CGSizeMake(self.flexibleLabel.bounds.size.width, 20000.0f);
    CGRect textRect = [self.flexibleLabel.text boundingRectWithSize:constraint
                                                            options:NSStringDrawingUsesLineFragmentOrigin
                                                         attributes:@{NSFontAttributeName:self.flexibleLabel.font}
                                                            context:nil];
    CGSize size = textRect.size;
	self.flexibleLabel.bounds = CGRectMake(0.0f, 0.0f, size.width, size.height);
	self.bounds = CGRectMake(0.0f, 0.0f, self.bounds.size.width, MAX(size.height + 20.0f, 44.0f));
}

@end
