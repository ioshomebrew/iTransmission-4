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

- (void)dealloc {
	self.flexibleLabel = nil;
    [super dealloc];
}

- (void)resizeToFitText
{
	CGSize constraint = CGSizeMake(self.flexibleLabel.bounds.size.width, 20000.0f);
	CGSize size = [self.flexibleLabel.text sizeWithFont:self.flexibleLabel.font constrainedToSize:constraint lineBreakMode:self.flexibleLabel.lineBreakMode];
	self.flexibleLabel.bounds = CGRectMake(0.0f, 0.0f, size.width, size.height);
	self.bounds = CGRectMake(0.0f, 0.0f, self.bounds.size.width, MAX(size.height + 20.0f, 44.0f));
}

@end
