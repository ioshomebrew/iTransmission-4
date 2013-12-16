//
//  ControlButton.m
//  iTransmission
//
//  Created by Mike Chen on 10/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ControlButton.h"
#import <CoreGraphics/CoreGraphics.h>

@implementation ControlButton
@synthesize gradientColors = fGradientColors;
@synthesize textLabel = fTextLabel;

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

- (void)useGrayStyle
{
	self.gradientColors = [NSArray arrayWithObjects:
						   [UIColor lightGrayColor],
						   [UIColor darkGrayColor],
						   [UIColor clearColor],
						   [UIColor clearColor],
						   nil];
	[self.textLabel setTextColor:[UIColor whiteColor]];	
}

- (void)useRedStyle
{
	self.gradientColors = [NSArray arrayWithObjects:
						   [UIColor colorWithRed:219.0f/255.0f green:122.0f/255.0f blue:129.0f/255.0f alpha:1.0f],
						   [UIColor colorWithRed:191.0f/255.0f green:20.0f/255.0f blue:28.0f/255.0f alpha:1.0f],
						   [UIColor colorWithRed:162.0f/255.0f green:87.0f/255.0f blue:93.0f/255.0f alpha:1.0f],
						   [UIColor colorWithRed:143.0f/255.0f green:4.0f/255.0f blue:15.0f/255.0f alpha:1.0f],
						   nil];
	[self.textLabel setTextColor:[UIColor whiteColor]];
}

- (void)useGreenStyle
{
	self.gradientColors = [NSArray arrayWithObjects:
						   [UIColor colorWithRed:109.0f/255.0f green:187.0f/255.0f blue:115.0f/255.0f alpha:1.0f],
						   [UIColor colorWithRed:0.0f/255.0f green:155.0f/255.0f blue:12.0f/255.0f alpha:1.0f],
						   [UIColor colorWithRed:74.0f/255.0f green:169.0f/255.0f blue:89.0f/255.0f alpha:1.0f],
						   [UIColor colorWithRed:4.0f/255.0f green:150.0f/255.0f blue:15.0f/255.0f alpha:1.0f],
						   nil];
	[self.textLabel setTextColor:[UIColor whiteColor]];
}

- (void)setFrame:(CGRect)f
{
	[super setFrame:f];
	properFrame = f;
}

- (void)setHidden:(BOOL)h
{
	if (h) {
		CGRect f = properFrame;
		f.size = CGSizeMake(0, f.size.height);
		[super setFrame:f];
	}
	else {
		[super setFrame:properFrame];
	}
	[super setHidden:h];
	[self setNeedsDisplay];
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
	[self useGreenStyle];
	self.textLabel.text = @"Resume";
}

- (void)setPauseStyle
{
	[self useRedStyle];
	self.textLabel.text = @"Pause";
}

- (void)_initViews
{
	self.backgroundColor = [UIColor clearColor];
	
	self.textLabel = [[[UILabel alloc] initWithFrame:self.bounds] autorelease];
	[self.textLabel setFont:[UIFont boldSystemFontOfSize:10.0f]];
	[self.textLabel setTextAlignment:UITextAlignmentCenter];
	[self.textLabel setBackgroundColor:[UIColor clearColor]];
	[self.textLabel setShadowOffset:CGSizeZero];
	[self setTitle:[NSString string] forState:UIControlStateNormal];	
	self.textLabel.text = @"Start";
	[self addSubview:self.textLabel];
	[self useGreenStyle];
}

- (void)clipCornersToOvalWidth:(float)ovalWidth height:(float)ovalHeight
{
    float fw, fh;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rect = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
	
    if (ovalWidth == 0 || ovalHeight == 0) {
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM (context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM (context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth (rect) / ovalWidth;
    fh = CGRectGetHeight (rect) / ovalHeight;
    CGContextMoveToPoint(context, fw, fh/2);
	CGContextAddLineToPoint(context, fw, fh);
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
	CGContextAddLineToPoint(context, fw, 0);
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

-(void)drawRect:(CGRect)rect {
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    [self clipCornersToOvalWidth:5.0f height:5.0f];
    CGContextClip(currentContext);
	
    CGGradientRef glossGradient;
    CGColorSpaceRef rgbColorspace;
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    
	CGColorRef startColor, endColor;
	
	if (self.state == UIControlStateNormal) {
		startColor = [(UIColor*)[self.gradientColors objectAtIndex:0] CGColor];
		endColor = [(UIColor*)[self.gradientColors objectAtIndex:1] CGColor];
	}
	else if (self.state == UIControlStateHighlighted) {
		startColor = [(UIColor*)[self.gradientColors objectAtIndex:2] CGColor];
		endColor = [(UIColor*)[self.gradientColors objectAtIndex:3] CGColor];
	}
	else {
		startColor = [(UIColor*)[self.gradientColors objectAtIndex:0] CGColor];
		endColor = [(UIColor*)[self.gradientColors objectAtIndex:1] CGColor];
	}

	CGFloat components[8]; // End color
	memcpy(components, CGColorGetComponents(startColor), sizeof(CGFloat)*4);
	memcpy(components + 4, 
		   CGColorGetComponents(endColor), sizeof(CGFloat)*4);

    rgbColorspace = CGColorSpaceCreateDeviceRGB();
    glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
	
    CGRect currentBounds = self.bounds;
    CGPoint topCenter = CGPointMake(CGRectGetMidX(currentBounds), 0.0f);
    CGPoint midCenter = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMaxY(currentBounds));
    CGContextDrawLinearGradient(currentContext, glossGradient, topCenter, midCenter, 0);

    CGGradientRelease(glossGradient);
    CGColorSpaceRelease(rgbColorspace); 
	
	CGContextSetLineWidth(currentContext, 1);
	CGContextSetRGBStrokeColor(currentContext, 20.0/255.0, 20.0/255.0, 20.0/255.0, 0.6);
    CGContextSetFillColorWithColor(currentContext, [UIColor clearColor].CGColor);
	[self clipCornersToOvalWidth:5.0f height:5.0f];
    CGContextDrawPath(currentContext, kCGPathFillStroke);
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

- (void)dealloc {
	self.gradientColors = nil;
	self.textLabel = nil;
    [super dealloc];
}


@end
