//
//  ControlButton.m
//  iTransmission
//
//  Created by Mike Chen on 10/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ControlButton.h"
#import <CoreGraphics/CoreGraphics.h>
#import "Controller.h"
#import "ALAlertBanner.h"

@implementation ControlButton
@synthesize textLabel;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		[self _initViews];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder])) {
		[self _initViews];
	}
	return self;
}

- (void)setBackgroundColor:(UIColor *)c
{
	//[super setBackgroundColor:[UIColor clearColor]];
}

- (UILabel*)titleLabel
{
	return self.textLabel;
}

- (void)setEnabled:(BOOL)e
{
	[super setEnabled:e];
	[self setNeedsDisplay];
}

- (void)setResumeStyle
{
    UIImage *image = [UIImage imageNamed:@"play_icon-ios7@2x.png"];
    [self setImage:image forState:UIControlStateNormal];
}

- (void)setPauseStyle
{
    UIImage *image = [UIImage imageNamed:@"pause_icon-ios7@2x.png"];
    [self setImage:image forState:UIControlStateNormal];
}

- (void)_initViews
{
    UIImage *image = [UIImage imageNamed:@"pause_icon-ios7@2x.png"];
    [self setImage:image forState:UIControlStateNormal];
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	[self setNeedsDisplay];
	return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	[self hesitateUpdate];
	return;
}

- (void)hesitateUpdate
{
    [self performSelector:@selector(setNeedsDisplay) withObject:nil afterDelay:0.1f];
	[self performSelector:@selector(setNeedsDisplay) withObject:nil afterDelay:0.2f];
}

@end
