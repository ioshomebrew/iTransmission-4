//
//  TransparentBackgroundCell.m
//  iTransmission
//
//  Created by Mike Chen on 10/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TransparentBackgroundCell.h"


@implementation TransparentBackgroundCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:aDecoder]) {
		UIView *transparentBackground = [[[UIView alloc] init] autorelease];
		transparentBackground.backgroundColor = [UIColor clearColor];
		self.backgroundView = transparentBackground;
	}
	return self;
}

@end
