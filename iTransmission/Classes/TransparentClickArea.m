//
//  TransparentClickArea.m
//  iTransmission
//
//  Created by Mike Chen on 10/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TransparentClickArea.h"


@implementation TransparentClickArea
@synthesize eventsForwardView = fEventsForwardView;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor clearColor];
		self.opaque = NO;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder])) {
		self.backgroundColor = [UIColor clearColor];
		self.opaque = NO;
	}
	return self;
}

- (id)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	if (CGRectContainsPoint(self.bounds, point))
		return self.eventsForwardView ? self.eventsForwardView : [super hitTest:point withEvent:event];
	return [super hitTest:point withEvent:event];
}
		

- (void)dealloc {
	self.eventsForwardView = nil;
    [super dealloc];
}


@end
